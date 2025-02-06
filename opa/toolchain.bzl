load(":providers.bzl", "OpaToolchainInfo")

def _opa_toolchain(ctx):
    return [
        platform_common.ToolchainInfo(
            opa = OpaToolchainInfo(
                cli = ctx.attr.cli,
            ),
        ),
        DefaultInfo(
            files = ctx.attr.cli.files,
            runfiles = ctx.runfiles(collect_data = True),
        ),
    ]

opa_toolchain = rule(
    implementation = _opa_toolchain,
    attrs = {
        "cli": attr.label(
            doc = "The opa binary",
            cfg = "exec",
            executable = True,
            allow_single_file = True,
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
