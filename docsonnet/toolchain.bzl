load(":providers.bzl", "DocsonnetToolchainInfo")

def _docsonnet_toolchain(ctx):
    return [
        platform_common.ToolchainInfo(
            crdschema = DocsonnetToolchainInfo(
                cli = ctx.attr.cli,
            ),
        ),
        DefaultInfo(
            files = ctx.attr.cli.files,
            runfiles = ctx.runfiles(collect_data = True),
        ),
    ]

docsonnet_toolchain = rule(
    implementation = _docsonnet_toolchain,
    attrs = {
        "cli": attr.label(
            doc = "The docsonnet binary",
            cfg = "exec",
            executable = True,
            allow_single_file = True,
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
