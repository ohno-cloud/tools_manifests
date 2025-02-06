load(":providers.bzl", "OpaRegoInfo")

_TOOLCHAIN = "//tools/bazel/rules_opa:toolchain_type"

def _opa_eval_test_impl(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN].opa

    args = ["eval", "'" + ctx.attr.query + "'", "--format=json", "--explain", "notes"]

    if ctx.attr.fail_defined:
        args.append("--fail-defined")

    runfiles = [
        ctx.runfiles(files = [toolchain.cli[DefaultInfo].files_to_run.executable]),
        ctx.runfiles(files = ctx.attr.input[DefaultInfo].files.to_list()),
    ]

    for data in ctx.attr.data:
        runfiles.append(ctx.runfiles(files = data[OpaRegoInfo].files.to_list()))
        runfiles.append(data[DefaultInfo].default_runfiles)

        for file in data[OpaRegoInfo].files.to_list():
            args.extend(["--data", "'" + file.short_path + "'"])

    for inn in ctx.attr.input.files.to_list():
        args.extend(["--input", "'" + inn.short_path + "'"])

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "{opa} {args}".format(
            opa = toolchain.cli[DefaultInfo].files_to_run.executable.short_path,
            args = " ".join(args),
        ),
    )

    runfiles = ctx.runfiles(collect_data = True).merge_all(runfiles)
    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]

opa_eval_test = rule(
    implementation = _opa_eval_test_impl,
    test = True,
    attrs = {
        "query": attr.string(
            mandatory = True,
        ),
        "data": attr.label_list(
            mandatory = True,
        ),
        "input": attr.label(
            mandatory = True,
            allow_files = [".json", ".yaml"],
        ),
        "fail_defined": attr.bool(default = True),
    },
    toolchains = [_TOOLCHAIN],
)

def _opa_rego_impl(ctx):
    return [
        OpaRegoInfo(files = depset(ctx.files.srcs)),
    ]

opa_rego = rule(
    implementation = _opa_rego_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".rego"],
            mandatory = True,
        ),
    },
    provides = [OpaRegoInfo],
    toolchains = [_TOOLCHAIN],
)
