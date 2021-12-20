const c = @import("c.zig").c;

/// Zigified error enum
pub const CurlError = error {
    UnsupportedProtocol,
    FailedInit,
    UrlMalformat,

    /// 4 - was obsoleted in August 2007 for 7.17.0, reused in April 2011 for 7.21.5
    NotBuiltIn,
    CouldntResolveProxy,
    CouldntResolveHost,
    CouldntConnect,
    WeirdServerReply,

    /// 9 a service was denied by the server
    /// due to lack of access - when login fails
    /// this is not returned.
    RemoteAccessDenied,

    /// 10 - [was obsoleted in April 2006 for
    /// 7.15.4, reused in Dec 2011 for 7.24.0]
    FtpAcceptFailed,
    FtpWeirdPassReply,
    /// 12 - timeout occurred accepting server
    /// [was obsoleted in August 2007 for 7.17.0,
    /// reused in Dec 2011 for 7.24.0]
    FtpAcceptTimeout,
    FtpWeirdPasvReply,
    FtpWeird227Format,
    FtpCantGetHost,
    /// 16 - A problem in the http2 framing layer.
    /// [was obsoleted in August 2007 for 7.17.0,
    /// reused in July 2014 for 7.38.0]
    Http2,
    FtpCouldntSetType,
    PartialFile,
    FtpCouldntRetrFile,
    /// 20 - NOT USED
    Obsolete20,
    /// 21 - quote command failure
    QuoteError,
    HttpReturnedError,
    WriteError,
    /// 24 - NOT USED
    Obsolete24,
    /// 25 - failed upload "command"
    UploadFailed,
    /// 26 - couldn't open/read from file
    ReadError,
    /// CURLE_OUT_OF_MEMORY ma//sometimes indicate a conversion error
    /// instead of a memory al//cation error if CURL_DOES_CONVERSIONS
    /// is defined
    OutOfMemory,
    /// 28 - the timeout time was reached
    OperationTimedout,
    /// 29 - NOT USED
    Obsolete29,
    /// 30 - FTP PORT operation failed
    FtpPortFailed,
    /// 31 - the REST command failed
    FtpCouldntUseRest,
    /// 32 - NOT USED
    Obsolete32,
    /// 33 - RANGE "command" didn't work
    RangeError,
    HttpPostError,
    /// 35 - wrong when connecting with SSL
    SslConnectError,
    /// 36 - couldn't resume download
    BadDownloadResume,
    FileCouldntReadFile,
    LdapCannotBind,
    LdapSearchFailed,
    /// 40 - NOT USED
    Obsolete40,
    /// 41 - NOT USED starting with 7.53.0
    FunctionNotFound,
    AbortedByCallback,
    BadFunctionArgument,
    /// 44 - NOT USED
    Obsolete44,
    /// 45 - CURLOPT_INTERFACE failed
    InterfaceFailed,
    /// 46 - NOT USED
    Obsolete46,
    /// 47 - catch endless re-direct loops
    TooManyRedirects,
    /// 48 - User specified an unknown option
    UnknownOption,
    /// 49 - Malformed setopt option
    SetoptOptionSyntax,
    /// 50 - NOT USED
    Obsolete50,
    /// 51 - NOT USED
    Obsolete51,
    /// 52 - when this is a specific error
    GotNothing,
    /// 53 - SSL crypto engine not found
    SslEngineNotfound,
    /// 54 - can not set SSL crypto engine as
    SslEngineSetfailed,
    SendError, // 55 - failed sending network data
    RecvError, // 56 - failure in receiving network data
    Obsolete57, // 57 - NOT IN USE
    SslCertproblem, // 58 - problem with the local certificate
    SslCipher, // 59 - couldn't use specified cipher
    PeerFailedVerification, //* 60 - peer's certificate or fingerprint
    //  wasn't verified fine
    BadContentEncoding, // 61 - Unrecognized/bad encoding
    LdapInvalidUrl, // 62 - Invalid LDAP URL
    FilesizeExceeded, // 63 - Maximum file size exceeded
    UseSslFailed, // 64 - Requested FTP SSL level failed
    SendFailRewind, // 65 - Sending the data requires a rewind that failed
    SslEngineInitfailed, // 66 - failed to initialise ENGINE
    LoginDenied, // 67 - user, password or similar was not accepted and we failed to login
    TftpNotfound, // 68 - file not found on server
    TftpPerm, // 69 - permission problem on server
    RemoteDiskFull, // 70 - out of disk space on server
    TftpIllegal, // 71 - Illegal TFTP operation
    TftpUnknownid, // 72 - Unknown transfer ID
    RemoteFileExists, // 73 - File already exists
    TftpNosuchuser, // 74 - No such user
    ConvFailed, // 75 - conversion failed
    ConvReqd, // 76 - caller must register conversion
    // callbacks using curl_easy_setopt options
    // CURLOPT_CONV_FROM_NETWORK_FUNCTION,
    // CURLOPT_CONV_TO_NETWORK_FUNCTION, and
    // CURLOPT_CONV_FROM_UTF8_FUNCTION
    /// 77 - could not load CACERT file, missing or wrong format
    SslCacertBadfile,
    /// 78 - remote file not found
    RemoteFileNotFound,
    /// 79 - error from the SSH layer, somewhat
    /// generic so the error message will be of
    /// interest when this has happened
    Ssh,
    /// 80 - Failed to shut down the SSL connection
    SslShutdownFailed,
    /// 81 - socket is not ready for send/recv, wait till it's ready and try again (Added in 7.18.2)
    Again,
    /// 82 - could not load CRL file, missing or
    /// wrong format (Added in 7.19.0)
    SslCrlBadfile,
    /// 83 - Issuer check failed.  (Added in 7.19.0)
    SslIssuerError,
    /// 84 - a PRET command failed
    FtpPretFailed,
    /// 85 - mismatch of RTSP CSeq numbers
    RtspCseqError,
    /// 86 - mismatch of RTSP Session Ids
    RtspSessionError,
    FtpBadFileList, // 87 - unable to parse FTP file list
    ChunkFailed, // 88 - chunk callback reported error
    NoConnectionAvailable, // 89 - No connection available, the
    // session will be queued
    SslPinnedpubkeynotmatch, //* 90 - specified pinned public key did not
    //  match
    SslInvalidcertstatus, // 91 - invalid certificate status
    Http2Stream, // 92 - stream error in HTTP/2 framing layer
    //
    RecursiveApiCall, // 93 - an api function was called from
    // inside a callback
    AuthError, // 94 - an authentication function returned an
    // error
    Http3, // 95 - An HTTP/3 layer problem
    QuicConnectError, // 96 - QUIC connection error
    Proxy, // 97 - proxy handshake error
    SslClientcert // 98 - client-side certificate required
};

pub fn translateError(e: c.CURLcode) CurlError!void {
    return switch (e) {
        c.CURLE_OK => {},
        c.CURLE_UNSUPPORTED_PROTOCOL => CurlError.UnsupportedProtocol,
        c.CURLE_FAILED_INIT => CurlError.FailedInit,
        c.CURLE_URL_MALFORMAT => CurlError.UrlMalformat,
        c.CURLE_NOT_BUILT_IN => CurlError.NotBuiltIn,
        c.CURLE_COULDNT_RESOLVE_PROXY => CurlError.CouldntResolveProxy,
        c.CURLE_COULDNT_RESOLVE_HOST => CurlError.CouldntResolveHost,
        c.CURLE_COULDNT_CONNECT => CurlError.CouldntConnect,
        c.CURLE_WEIRD_SERVER_REPLY => CurlError.WeirdServerReply,
        c.CURLE_REMOTE_ACCESS_DENIED => CurlError.RemoteAccessDenied,
        c.CURLE_FTP_ACCEPT_FAILED => CurlError.FtpAcceptFailed,
        c.CURLE_FTP_WEIRD_PASS_REPLY => CurlError.FtpWeirdPassReply,
        c.CURLE_FTP_ACCEPT_TIMEOUT => CurlError.FtpAcceptTimeout,
        c.CURLE_FTP_WEIRD_PASV_REPLY => CurlError.FtpWeirdPasvReply,
        c.CURLE_FTP_WEIRD_227_FORMAT => CurlError.FtpWeird227Format,
        c.CURLE_FTP_CANT_GET_HOST => CurlError.FtpCantGetHost,
        c.CURLE_HTTP2 => CurlError.Http2,
        c.CURLE_FTP_COULDNT_SET_TYPE => CurlError.FtpCouldntSetType,
        c.CURLE_PARTIAL_FILE => CurlError.PartialFile,
        c.CURLE_FTP_COULDNT_RETR_FILE => CurlError.FtpCouldntRetrFile,
        c.CURLE_OBSOLETE20 => CurlError.Obsolete20,
        c.CURLE_QUOTE_ERROR => CurlError.QuoteError,
        c.CURLE_HTTP_RETURNED_ERROR => CurlError.HttpReturnedError,
        c.CURLE_WRITE_ERROR => CurlError.WriteError,
        c.CURLE_OBSOLETE24 => CurlError.Obsolete24,
        c.CURLE_UPLOAD_FAILED => CurlError.UploadFailed,
        c.CURLE_READ_ERROR => CurlError.ReadError,
        c.CURLE_OUT_OF_MEMORY => CurlError.OutOfMemory,
        c.CURLE_OPERATION_TIMEDOUT => CurlError.OperationTimedout,
        c.CURLE_OBSOLETE29 => CurlError.Obsolete29,
        c.CURLE_FTP_PORT_FAILED => CurlError.FtpPortFailed,
        c.CURLE_FTP_COULDNT_USE_REST => CurlError.FtpCouldntUseRest,
        c.CURLE_OBSOLETE32 => CurlError.Obsolete32,
        c.CURLE_RANGE_ERROR => CurlError.RangeError,
        c.CURLE_HTTP_POST_ERROR => CurlError.HttpPostError,
        c.CURLE_SSL_CONNECT_ERROR => CurlError.SslConnectError,
        c.CURLE_BAD_DOWNLOAD_RESUME => CurlError.BadDownloadResume,
        c.CURLE_FILE_COULDNT_READ_FILE => CurlError.FileCouldntReadFile,
        c.CURLE_LDAP_CANNOT_BIND => CurlError.LdapCannotBind,
        c.CURLE_LDAP_SEARCH_FAILED => CurlError.LdapSearchFailed,
        c.CURLE_OBSOLETE40 => CurlError.Obsolete40,
        c.CURLE_FUNCTION_NOT_FOUND => CurlError.FunctionNotFound,
        c.CURLE_ABORTED_BY_CALLBACK => CurlError.AbortedByCallback,
        c.CURLE_BAD_FUNCTION_ARGUMENT => CurlError.BadFunctionArgument,
        c.CURLE_OBSOLETE44 => CurlError.Obsolete44,
        c.CURLE_INTERFACE_FAILED => CurlError.InterfaceFailed,
        c.CURLE_OBSOLETE46 => CurlError.Obsolete46,
        c.CURLE_TOO_MANY_REDIRECTS => CurlError.TooManyRedirects,
        c.CURLE_UNKNOWN_OPTION => CurlError.UnknownOption,
        c.CURLE_SETOPT_OPTION_SYNTAX => CurlError.SetoptOptionSyntax,
        c.CURLE_OBSOLETE50 => CurlError.Obsolete50,
        c.CURLE_OBSOLETE51 => CurlError.Obsolete51,
        c.CURLE_GOT_NOTHING => CurlError.GotNothing,
        c.CURLE_SSL_ENGINE_NOTFOUND => CurlError.SslEngineNotfound,
        c.CURLE_SSL_ENGINE_SETFAILED => CurlError.SslEngineSetfailed,
        c.CURLE_SEND_ERROR => CurlError.SendError,
        c.CURLE_RECV_ERROR => CurlError.RecvError,
        c.CURLE_OBSOLETE57 => CurlError.Obsolete57,
        c.CURLE_SSL_CERTPROBLEM => CurlError.SslCertproblem,
        c.CURLE_SSL_CIPHER => CurlError.SslCipher,
        c.CURLE_PEER_FAILED_VERIFICATION => CurlError.PeerFailedVerification,
        c.CURLE_BAD_CONTENT_ENCODING => CurlError.BadContentEncoding,
        c.CURLE_LDAP_INVALID_URL => CurlError.LdapInvalidUrl,
        c.CURLE_FILESIZE_EXCEEDED => CurlError.FilesizeExceeded,
        c.CURLE_USE_SSL_FAILED => CurlError.UseSslFailed,
        c.CURLE_SEND_FAIL_REWIND => CurlError.SendFailRewind,
        c.CURLE_SSL_ENGINE_INITFAILED => CurlError.SslEngineInitfailed,
        c.CURLE_LOGIN_DENIED => CurlError.LoginDenied,
        c.CURLE_TFTP_NOTFOUND => CurlError.TftpNotfound,
        c.CURLE_TFTP_PERM => CurlError.TftpPerm,
        c.CURLE_REMOTE_DISK_FULL => CurlError.RemoteDiskFull,
        c.CURLE_TFTP_ILLEGAL => CurlError.TftpIllegal,
        c.CURLE_TFTP_UNKNOWNID => CurlError.TftpUnknownid,
        c.CURLE_REMOTE_FILE_EXISTS => CurlError.RemoteFileExists,
        c.CURLE_TFTP_NOSUCHUSER => CurlError.TftpNosuchuser,
        c.CURLE_CONV_FAILED => CurlError.ConvFailed,
        c.CURLE_CONV_REQD => CurlError.ConvReqd,
        c.CURLE_SSL_CACERT_BADFILE => CurlError.SslCacertBadfile,
        c.CURLE_REMOTE_FILE_NOT_FOUND => CurlError.RemoteFileNotFound,
        c.CURLE_SSH => CurlError.Ssh,
        c.CURLE_SSL_SHUTDOWN_FAILED => CurlError.SslShutdownFailed,
        c.CURLE_AGAIN => CurlError.Again,
        c.CURLE_SSL_CRL_BADFILE => CurlError.SslCrlBadfile,
        c.CURLE_SSL_ISSUER_ERROR => CurlError.SslIssuerError,
        c.CURLE_FTP_PRET_FAILED => CurlError.FtpPretFailed,
        c.CURLE_RTSP_CSEQ_ERROR => CurlError.RtspCseqError,
        c.CURLE_RTSP_SESSION_ERROR => CurlError.RtspSessionError,
        c.CURLE_FTP_BAD_FILE_LIST => CurlError.FtpBadFileList,
        c.CURLE_CHUNK_FAILED => CurlError.ChunkFailed,
        c.CURLE_NO_CONNECTION_AVAILABLE => CurlError.NoConnectionAvailable,
        c.CURLE_SSL_PINNEDPUBKEYNOTMATCH => CurlError.SslPinnedpubkeynotmatch,
        c.CURLE_SSL_INVALIDCERTSTATUS => CurlError.SslInvalidcertstatus,
        c.CURLE_HTTP2_STREAM => CurlError.Http2Stream,
        c.CURLE_RECURSIVE_API_CALL => CurlError.RecursiveApiCall,
        c.CURLE_AUTH_ERROR => CurlError.AuthError,
        c.CURLE_HTTP3 => CurlError.Http3,
        c.CURLE_QUIC_CONNECT_ERROR => CurlError.QuicConnectError,
        c.CURLE_PROXY => CurlError.Proxy,
        c.CURLE_SSL_CLIENTCERT => CurlError.SslClientcert,
        c.CURL_LAST => unreachable,
        else => unreachable
    };
}
