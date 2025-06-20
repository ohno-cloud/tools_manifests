load(":providers.bzl", "ConftestPolicyInfo")

_TOOLCHAIN = "//conftest:toolchain_type"

def _conftest_test_impl(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN].conftest

    args = ["test", "--combine"]

    runfiles = [
        ctx.runfiles(files = [toolchain.cli[DefaultInfo].files_to_run.executable]),
        ctx.runfiles(files = ctx.files.policy),
        ctx.runfiles(files = ctx.files.input),
    ]

    for inn in ctx.files.policy:
        args.extend(["--policy", "'" + inn.short_path + "'"])

    for data_file in ctx.files.input:
        args.extend(["'" + data_file.short_path + "'"])

    ctx.actions.write(
        output = ctx.outputs.executable,
        content = "{conftest} {args}".format(
            conftest = toolchain.cli[DefaultInfo].files_to_run.executable.short_path,
            args = " ".join(args),
        ),
    )

    runfiles = ctx.runfiles(collect_data = True).merge_all(runfiles)
    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]

conftest_test = rule(
    implementation = _conftest_test_impl,
    test = True,
    attrs = {
        "policy": attr.label_list(
            mandatory = True,
        ),
        "input": attr.label(
            mandatory = True,
            allow_files = [".json", ".yaml"],
        ),
    },
    toolchains = [_TOOLCHAIN],
)

def _conftest_policy_impl(ctx):
    return [
        ConftestPolicyInfo(files = depset(ctx.files.srcs)),
    ]

conftest_policy = rule(
    implementation = _conftest_policy_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".rego"],
            mandatory = True,
        ),
    },
    provides = [ConftestPolicyInfo],
    toolchains = [_TOOLCHAIN],
)
