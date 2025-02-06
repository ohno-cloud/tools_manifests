load("@rules_jsonnet//jsonnet:jsonnet.bzl", "JsonnetLibraryInfo")

_TOOLCHAIN = "//k8sgen:toolchain_type"

def _k8s_gen_crd(ctx):
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

    ctx.actions.run(
        mnemonic = "K8sGen",
        executable = ctx.file.k8s_gen,
        inputs = ctx.files.crds + [config_file],
        outputs = [output],
        arguments = [
            "--config",
            config_file.path,
            "--output",
            output.path,
        ],
    )

    runfiles = ctx.runfiles(files = ctx.files.crds).merge_all([
        ctx.runfiles(files = [config_file]),
    ])
    outputs = depset([output])
    return [
        DefaultInfo(files = depset([output])),
        JsonnetLibraryInfo(
            imports = depset([output.dirname]),
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
        "k8s_gen": attr.label(
            default = "//go/tools:k8s-gen",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        toolchains = [_TOOLCHAIN],
    },
)

def _k8s_gen_openapi(ctx):
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

    ctx.actions.run(
        mnemonic = "K8sGen",
        executable = ctx.file.k8s_gen,
        inputs = ctx.files.openapi + [config_file],
        outputs = [output],
        arguments = [
            "--config",
            config_file.path,
            "--output",
            output.path,
        ],
    )

    runfiles = ctx.runfiles(files = ctx.files.openapi).merge_all([
        ctx.runfiles(files = [config_file]),
    ])
    outputs = depset([output])
    return [
        DefaultInfo(files = depset([output])),
        JsonnetLibraryInfo(
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
        "k8s_gen": attr.label(
            default = "//go/tools:k8s-gen",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    toolchains = [_TOOLCHAIN],
)
