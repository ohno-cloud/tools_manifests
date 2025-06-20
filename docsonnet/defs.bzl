_TOOLCHAIN = "//docsonnet:toolchain_type"

def _docsonnet_markdown(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN].crdschema

    path = ctx.label.name
    output = ctx.actions.declare_directory(path)

    args = ctx.actions.args()

    if ctx.files.src[0].is_directory:
        args.add(ctx.files.src[0].path + '/main.libsonnet')
        args.add("-J", ctx.files.src[0].path)
    else:
        args.add(ctx.files.src[0])
        args.add("-J", ctx.files.src[0].dirname)

    args.add("--output", output.path)
    args.add("--urlPrefix", ctx.attr.url_prefix)

    ctx.actions.run(
        mnemonic = "DocsonnetMarkdown",
        executable = toolchain.cli[DefaultInfo].files_to_run.executable,
        inputs = ctx.files.src + [toolchain.cli[DefaultInfo].files_to_run.executable],
        outputs = [output],
        arguments = [args],
        toolchain = None,
    )

    return [
        DefaultInfo(files = depset([output])),
    ]

docsonnet_markdown = rule(
    implementation = _docsonnet_markdown,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_files = True,
        ),
        "url_prefix": attr.string(
            mandatory = False,
            default = "/",
            doc = "Regular expression to match CRDs with",
        ),
    },
    toolchains = [_TOOLCHAIN],
)
