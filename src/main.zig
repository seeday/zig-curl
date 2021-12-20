const std = @import("std");
const testing = std.testing;
const log = std.log;
const c = @import("c.zig").c;
const cerr = @import("errors.zig");
const CurlError = cerr.CurlError;

inline fn curlEasyPerform(handle: *c.CURL) CurlError!void {
    try cerr.translateError(c.curl_easy_perform(handle));
}

inline fn curlEasySetOpt(handle: *c.CURL, opt: c_uint, data: anytype) CurlError!void {
    try cerr.translateError(c.curl_easy_setopt(handle, opt, data));
}

/// Curl errors not from the library, but from the zig wrapper
const EasierCurlError = error{IncorrectContentLength};

const CurlErrors = CurlError || EasierCurlError;

const Method = enum { GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD, CONNECT, TRACE };

fn curlSmartSetopt(handle: *c.CURL, comptime opt: c.CURLoption, value: anytype) CurlError!void {
    // well this doesn't work because easy_option_by_id doesn't. Maybe if we find the table
    // that it's generated into we can reproduce that function, but who knows
    var o: ?*const c.curl_easyoption = c.curl_easy_option_by_id(opt);
    if (o) |oo| {
        switch (oo.type) {
            c.CURLOT_STRING => return if (@TypeOf(value) == [*]const u8) (try curlEasySetOpt(handle, opt, value)) else @compileError("this opt takes strings"),
            c.CURLOT_LONG => return if (@TypeOf(value) == c_long) (try curlEasySetOpt(handle, opt, value)) else @compileError("this opt takes longs"),
            else => unreachable,
        }
    }
}

const Curl = struct {
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

    pub fn get(self: *const Self, url: []const u8) CurlErrors!std.ArrayList(u8) {
        var lst = std.ArrayList(u8).init(self.alloc);
        errdefer lst.deinit();

        c.curl_easy_reset(self.handle);
        try curlSmartSetopt(self.handle, c.CURLOPT_URL, url.ptr);
        //try curlEasySetOpt(self.handle, c.CURLOPT_URL, url.ptr);
        try curlEasySetOpt(self.handle, c.CURLOPT_WRITEFUNCTION, downloadFn);
        try curlEasySetOpt(self.handle, c.CURLOPT_WRITEDATA, &lst);

        try curlEasyPerform(self.handle);
        var size: c.curl_off_t = undefined;
        _ = c.curl_easy_getinfo(self.handle, c.CURLINFO_CONTENT_LENGTH_DOWNLOAD_T, &size);
        if (size != lst.items.len) {
            //std.log.warn("content-length {} != response size {}", .{ size, lst.items.len });
            return EasierCurlError.IncorrectContentLength;
        }
        return lst;
    }

    pub fn post(self: *const Self, url: []const u8, payload: ?[]const u8) CurlErrors!std.ArrayList(u8) {
        var lst = std.ArrayList(u8).init(self.alloc);
        errdefer lst.deinit();

        c.curl_easy_reset(self.handle);
        try curlEasySetOpt(self.handle, c.CURLOPT_URL, url.ptr);
        try curlEasySetOpt(self.handle, c.CURLOPT_WRITEFUNCTION, downloadFn);
        try curlEasySetOpt(self.handle, c.CURLOPT_WRITEDATA, &lst);

        try curlEasySetOpt(self.handle, c.CURLOPT_POST, @as(usize, 1));
        if (payload) |p| {
            var upl = CurlUploadProgress{ .data = p, .prog = 0 };
            try curlEasySetOpt(self.handle, c.CURLOPT_READFUNCTION, uploadFn);
            try curlEasySetOpt(self.handle, c.CURLOPT_READDATA, &upl);

            // if we want to post form data, use c.CURLOPT_POSTFIELDSIZE
            // if you want to do raw data, use CURLOPT_UPLOAD and CURLOPT_INFILESIZE
            try curlEasySetOpt(self.handle, c.CURLOPT_UPLOAD, @as(c_long, 1));
            try curlEasySetOpt(self.handle, c.CURLOPT_INFILESIZE, p.len);
        }
        try curlEasyPerform(self.handle);
        return lst;
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
    _ = c.curl_easy_setopt(curl.handle, c.CURLOPT_VERBOSE, @as(usize, 1));

    var res = try curl.get("https://example.net");
    defer res.deinit();
    try testing.expectEqual(@as(u8, '<'), res.items[0]);
    try testing.expectStringEndsWith(res.items, ">\n");
    try testing.expectEqual(@as(u8, '\n'), res.items[res.items.len - 1]);
}

test "post" {
    const curl = try Curl.init(std.testing.allocator);
    defer curl.deinit();

    var res = try curl.post("https://httpbin.org/anything", "hello, world!");
    defer res.deinit();
    try testing.expectEqualStrings("hello, world", res.items);
}
