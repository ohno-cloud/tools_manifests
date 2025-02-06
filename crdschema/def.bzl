_TOOLCHAIN = "//crdschema:toolchain_type"

def _crd_schema_impl(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN].crdschema

    path = "_crd_schema/" + ctx.label.name
    output = ctx.actions.declare_directory(path)

    args = ctx.actions.args()
    args.add("--output-dir", output.path)
    args.add_all(ctx.files.srcs, before_each = "-m")

    ctx.actions.run(
        executable = toolchain.cli[DefaultInfo].files_to_run,
        inputs = ctx.files.srcs,
        outputs = [output],
        arguments = [args],
    )

    return [
        DefaultInfo(files = depset([output])),
    ]

crd_schema = rule(
    implementation = _crd_schema_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Kubernetes CustomResourceDefintion files",
        ),
    },
    toolchains = [_TOOLCHAIN],
)
