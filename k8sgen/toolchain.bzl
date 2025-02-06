load(":providers.bzl", "K8sGenToolchainInfo")

def _k8sgen_toolchain(ctx):
    return [
        platform_common.ToolchainInfo(
            crdschema = K8sGenToolchainInfo(
                cli = ctx.attr.cli,
            ),
        ),
        DefaultInfo(
            files = ctx.attr.cli.files,
            runfiles = ctx.runfiles(collect_data = True),
        ),
    ]

k8sgen_toolchain = rule(
    implementation = _k8sgen_toolchain,
    attrs = {
        "cli": attr.label(
            doc = "The k8s-gen binary",
            cfg = "exec",
            executable = True,
            allow_single_file = True,
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
