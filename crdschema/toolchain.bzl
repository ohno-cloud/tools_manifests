load(":providers.bzl", "CrdSchemaToolchainInfo")

def _crdschema_toolchain(ctx):
    return [
        platform_common.ToolchainInfo(
            crdschema = CrdSchemaToolchainInfo(
                cli = ctx.attr.cli,
            ),
        ),
        DefaultInfo(
            files = ctx.attr.cli.files,
            runfiles = ctx.runfiles(collect_data = True),
        ),
    ]

crdschema_toolchain = rule(
    implementation = _crdschema_toolchain,
    attrs = {
        "cli": attr.label(
            doc = "The crdschema binary",
            cfg = "exec",
            executable = True,
            allow_single_file = True,
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
