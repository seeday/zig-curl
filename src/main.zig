const std = @import("std");
const testing = std.testing;
const log = std.log;
pub const c = @import("c.zig").c;
const cerr = @import("errors.zig");
const CurlError = cerr.CurlError;

inline fn curlEasyPerform(handle: *c.CURL) CurlError!void {
    try cerr.translateError(c.curl_easy_perform(handle));
}

inline fn curlEasySetOpt(handle: *c.CURL, opt: c_uint, data: *const anyopaque) CurlError!void {
    try cerr.translateError(c.curl_easy_setopt(handle, opt, data));
}

/// Curl errors not from the library, but from the zig wrapper
pub const EasierCurlError = error{IncorrectContentLength};

pub const CurlErrors = CurlError || EasierCurlError;

pub const Method = enum { GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD, CONNECT, TRACE };

pub const Request = struct {
    pub const Option = struct { id: c_uint, val: *const anyopaque };
    method: Method = .GET,
    url: []const u8,
    headers: ?std.StringHashMap([]const u8) = null,
    body: ?[]const u8 = null,
    options: ?[]const Option = null,
};

pub const Response = struct {
    code: c_long,
    data: ?std.ArrayList(u8),

    /// Conveniently deinit the data array
    pub fn deinit(self: *const Response) void {
        if (self.data) |d| {
            d.deinit();
        }
    }
};

pub const Curl = struct {
    alloc: std.mem.Allocator,
    handle: *c.CURL,

    const Self = @This();

    const CurlUploadProgress = struct {
        data: []const u8,
        prog: usize,
    };

    pub fn init(alloc: std.mem.Allocator) CurlError!Self {
        var handle: *c.CURL = undefined;
        if (c.curl_easy_init()) |crl| {
            handle = crl;
        } else {
            return CurlError.FailedInit;
        }

        return Self{ .alloc = alloc, .handle = handle };
    }

    pub fn deinit(self: *const Self) void {
        c.curl_easy_cleanup(self.handle);
    }

    fn uploadFn(dest: [*]u8, size: usize, nmemb: usize, userp: *CurlUploadProgress) callconv(.C) usize {
        const realsize = size * nmemb;
        var written: usize = 0;
        while (userp.prog < @minimum(realsize, userp.data.len)) : (userp.prog += 1) {
            dest[written] = userp.data[userp.prog];
            written += 1;
        }
        return written;
    }

    fn downloadFn(contents: [*]u8, size: usize, nmemb: usize, ctx: *std.ArrayList(u8)) callconv(.C) usize {
        log.info("hit the buffer", .{});
        const realsize = size * nmemb;
        ctx.ensureUnusedCapacity(realsize) catch |err| {
            std.log.err("error preallocating buffer: {}", .{err});
            return 0;
        };
        std.mem.copy(u8, ctx.unusedCapacitySlice(), contents[0 .. size * nmemb]);
        ctx.items.len += realsize; // according to the documentation of ctx.uCP
        return realsize;
    }

    pub fn execute(self: *const Self, req: *const Request) CurlErrors!Response {
        var lst = std.ArrayList(u8).init(self.alloc);
        errdefer lst.deinit();

        c.curl_easy_reset(self.handle);

        switch (req.method) {
            .GET => {},
            .POST => {
                try curlEasySetOpt(self.handle, c.CURLOPT_POST, @intToPtr(*anyopaque, 1));
            },
            else => {
                // there's some set custom header option in libcurl
                unreachable;
            },
        }
        try curlEasySetOpt(self.handle, c.CURLOPT_URL, req.url.ptr);
        try curlEasySetOpt(self.handle, c.CURLOPT_WRITEFUNCTION, downloadFn);
        try curlEasySetOpt(self.handle, c.CURLOPT_WRITEDATA, &lst);
        if (req.options) |oo| {
            for (oo) |o| {
                try curlEasySetOpt(self.handle, o.id, o.val);
            }
        }
        if (req.body) |b| {
            var upl = CurlUploadProgress{ .data = b, .prog = 0 };
            try curlEasySetOpt(self.handle, c.CURLOPT_READFUNCTION, uploadFn);
            try curlEasySetOpt(self.handle, c.CURLOPT_READDATA, &upl);
            try curlEasySetOpt(self.handle, c.CURLOPT_UPLOAD, @intToPtr(*anyopaque, 1));
            try curlEasySetOpt(self.handle, c.CURLOPT_INFILESIZE, @intToPtr(*anyopaque, b.len));
        }
        try curlEasyPerform(self.handle);
        var resp = Response{ .code = undefined, .data = undefined };
        _ = c.curl_easy_getinfo(self.handle, c.CURLINFO_RESPONSE_CODE, &resp.code);
        if (lst.items.len != 0) {
            resp.data = lst;
        } else {
            resp.data = null;
            lst.deinit();
        }
        return resp;
    }
};

test "init deinit" {
    var curl = try Curl.init(std.testing.allocator);
    curl.deinit();
    curl = try Curl.init(std.testing.allocator);
    curl.deinit();
}

test "get" {
    const curl = try Curl.init(std.testing.allocator);
    defer curl.deinit();
    _ = c.curl_easy_setopt(curl.handle, c.CURLOPT_VERBOSE, @intToPtr(*anyopaque, 1));

    var req = Request{ .method = .GET, .url = "https://example.net" };
    var res = try curl.execute(&req);
    defer res.deinit();
    try testing.expectEqual(@as(c_long, 200), res.code);
    try testing.expectEqual(@as(u8, '<'), res.data.?.items[0]);
    try testing.expectStringEndsWith(res.data.?.items, ">\n");
    try testing.expectEqual(@as(u8, '\n'), res.data.?.items[res.data.?.items.len - 1]);
}

test "post" {
    const curl = try Curl.init(std.testing.allocator);
    defer curl.deinit();
    const payload = "hello, world!";

    const req = Request{ .method = .POST, .url = "https://httpbin.org/anything", .body = payload, .options = &.{.{ .id = c.CURLOPT_VERBOSE, .val = @intToPtr(*anyopaque, 1) }} };
    var res = try curl.execute(&req);
    defer res.deinit();
    try testing.expectEqual(@as(c_long, 200), res.code);

    var p = std.json.Parser.init(std.testing.allocator, false);
    defer p.deinit();
    var j = try p.parse(res.data.?.items);
    defer j.deinit();
    try testing.expectEqualStrings(payload, j.root.Object.get("data").?.String);
}
