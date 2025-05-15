load(":providers.bzl", "ConftestToolchainInfo")



# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _conftest_toolchain_impl(ctx):
    tool_files = ctx.attr.cli.files.to_list()
    target_tool_path = _to_manifest_path(ctx, tool_files[0])

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "CONFTEST_BIN": target_tool_path,
    })
    default = DefaultInfo(
        files = depset(tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )
    conftestinfo = ConftestToolchainInfo(
        cli = ctx.attr.cli,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        conftest = conftestinfo,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

conftest_toolchain = rule(
    implementation = _conftest_toolchain_impl,
    attrs = {
        "cli": attr.label(
            doc = "The conftest binary",
            cfg = "exec",
            executable = True,
            allow_single_file = True,
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
