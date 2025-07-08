load("@rules_jsonnet//jsonnet:jsonnet.bzl", "JsonnetLibraryInfo")

_TOOLCHAIN = "//k8sgen:toolchain_type"

def _k8s_gen_crd(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN].crdschema

    config = "_k8sgen_crds_config_" + ctx.label.name + ".yaml"
    path = ctx.label.name

    config_file = ctx.actions.declare_file(config)
    output = ctx.actions.declare_directory(path)

    ctx.actions.write(config_file, json.encode({
        "specs": [{
            "crds": [x.path for x in ctx.files.crds],
            "prefix": ctx.attr.prefix,
            "localName": ctx.label.name,
        }],
    }))

    args = ctx.actions.args()
    # Compability flags introduced in github.com/ohno-cloud/k8s-gen-libsonnet/
    args.add("--chdir=false")
    args.add("--mixin-self=false")
    args.add("--quiet")
    args.add("--chdir=false")
    args.add("--config", config_file)
    args.add("--output", output.path)

    ctx.actions.run(
        mnemonic = "K8sGen",
        executable = toolchain.cli[DefaultInfo].files_to_run.executable,
        inputs = ctx.files.crds + [config_file, toolchain.cli[DefaultInfo].files_to_run.executable],
        outputs = [output],
        arguments = [args],
        toolchain = None,
    )

    outputs = depset([output])
    return [
        DefaultInfo(files = depset([output])),
        JsonnetLibraryInfo(
            imports = depset([output.dirname]),
            short_imports = depset([output.dirname]),
            transitive_jsonnet_files = outputs,
            transitive_sources = outputs,
        ),
    ]

k8s_gen_crd = rule(
    implementation = _k8s_gen_crd,
    attrs = {
        "crds": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "prefix": attr.string(
            mandatory = True,
            doc = "Regular expression to match CRDs with",
        ),
    },
    toolchains = [_TOOLCHAIN],
)

def _k8s_gen_openapi(ctx):
    toolchain = ctx.toolchains[_TOOLCHAIN].crdschema

    config = "_k8sgen_openapi_config_" + ctx.label.name + ".yaml"
    path = ctx.label.name

    config_file = ctx.actions.declare_file(config)
    output = ctx.actions.declare_directory(path)

    ctx.actions.write(config_file, json.encode({
        "specs": [{
            "openapi": [x.path for x in ctx.files.openapi],
            "prefix": ctx.attr.prefix,
            "localName": ctx.label.name,
        }],
    }))

    args = ctx.actions.args()
    # Compability flags introduced in github.com/ohno-cloud/k8s-gen-libsonnet/
    args.add("--chdir=false")
    args.add("--mixin-self=false")
    args.add("--quiet")
    args.add("--chdir=false")
    args.add("--config", config_file)
    args.add( "--output", output.path)

    ctx.actions.run(
        mnemonic = "K8sGen",
        executable = toolchain.cli[DefaultInfo].files_to_run.executable,
        inputs = ctx.files.openapi + [config_file, toolchain.cli[DefaultInfo].files_to_run.executable],
        outputs = [output],
        arguments = [args],
        toolchain = None,
    )

    outputs = depset([output])
    return [
        DefaultInfo(files = depset([output])),
        JsonnetLibraryInfo(
            short_imports = depset([output.dirname]),
            imports = depset([output.dirname]),
            transitive_jsonnet_files = outputs,
            transitive_sources = outputs,
        ),
    ]

k8s_gen_openapi = rule(
    implementation = _k8s_gen_openapi,
    attrs = {
        "openapi": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "prefix": attr.string(
            mandatory = True,
            doc = "Regular expression to match CRDs with",
        ),
    },
    toolchains = [_TOOLCHAIN],
)
