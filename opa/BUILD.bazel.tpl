load("@tools_manifests//opa:toolchain_type", "opa_toolchain")

exports_files([
    "opa",
])

filegroup(
    name = "files",
    srcs = ["opa"],
)

opa_toolchain(
    name = "opa_toolchain",
    cli = ":files",
)
