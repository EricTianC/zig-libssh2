const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "ssh2",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(b.path("libssh2/include"));
    lib.addIncludePath(b.path("config"));
    lib.addCSourceFiles(.{ .files = srcs, .flags = &.{} });
    lib.linkLibC();

    lib.root_module.addCMacro("LIBSSH2_MBEDTLS", "");
    if (target.result.os.tag == .windows) {
        lib.root_module.addCMacro("_CRT_SECURE_NO_DEPRECATE", "1");
        lib.root_module.addCMacro("HAVE_LIBCRYPT32", "");
        lib.root_module.addCMacro("HAVE_WINSOCK2_H", "");
        lib.root_module.addCMacro("HAVE_IOCTLSOCKET", "");
        lib.root_module.addCMacro("HAVE_SELECT", "");
        lib.root_module.addCMacro("LIBSSH2_DH_GEX_NEW", "1");

        if (target.result.abi.isGnu()) {
            lib.root_module.addCMacro("HAVE_UNISTD_H", "");
            lib.root_module.addCMacro("HAVE_INTTYPES_H", "");
            lib.root_module.addCMacro("HAVE_SYS_TIME_H", "");
            lib.root_module.addCMacro("HAVE_GETTIMEOFDAY", "");
        }
    } else {
        lib.root_module.addCMacro("HAVE_UNISTD_H", "");
        lib.root_module.addCMacro("HAVE_INTTYPES_H", "");
        lib.root_module.addCMacro("HAVE_STDLIB_H", "");
        lib.root_module.addCMacro("HAVE_SYS_SELECT_H", "");
        lib.root_module.addCMacro("HAVE_SYS_UIO_H", "");
        lib.root_module.addCMacro("HAVE_SYS_SOCKET_H", "");
        lib.root_module.addCMacro("HAVE_SYS_IOCTL_H", "");
        lib.root_module.addCMacro("HAVE_SYS_TIME_H", "");
        lib.root_module.addCMacro("HAVE_SYS_UN_H", "");
        lib.root_module.addCMacro("HAVE_LONGLONG", "");
        lib.root_module.addCMacro("HAVE_GETTIMEOFDAY", "");
        lib.root_module.addCMacro("HAVE_INET_ADDR", "");
        lib.root_module.addCMacro("HAVE_POLL", "");
        lib.root_module.addCMacro("HAVE_SELECT", "");
        lib.root_module.addCMacro("HAVE_SOCKET", "");
        lib.root_module.addCMacro("HAVE_STRTOLL", "");
        lib.root_module.addCMacro("HAVE_SNPRINTF", "");
        lib.root_module.addCMacro("HAVE_O_NONBLOCK", "");
    }

    const mbedtls = b.dependency("mbedtls", .{ .target = target, .optimize = optimize });
    lib.linkLibrary(mbedtls.artifact("mbedtls"));

    lib.installHeader(b.path("libssh2/include/libssh2.h"), "libssh2.h");

    b.installArtifact(lib);

    const test_step = b.step("test", "fake test step for now");
    _ = test_step;
}

const srcs = &.{
    "libssh2/src/channel.c",
    "libssh2/src/comp.c",
    "libssh2/src/crypt.c",
    "libssh2/src/hostkey.c",
    "libssh2/src/kex.c",
    "libssh2/src/mac.c",
    "libssh2/src/misc.c",
    "libssh2/src/packet.c",
    "libssh2/src/publickey.c",
    "libssh2/src/scp.c",
    "libssh2/src/session.c",
    "libssh2/src/sftp.c",
    "libssh2/src/userauth.c",
    "libssh2/src/transport.c",
    "libssh2/src/version.c",
    "libssh2/src/knownhost.c",
    "libssh2/src/agent.c",
    "libssh2/src/mbedtls.c",
    "libssh2/src/pem.c",
    "libssh2/src/keepalive.c",
    "libssh2/src/global.c",
    "libssh2/src/blowfish.c",
    "libssh2/src/bcrypt_pbkdf.c",
    "libssh2/src/agent_win.c",
};
