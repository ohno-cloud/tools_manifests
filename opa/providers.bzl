OpaRegoInfo = provider(
    doc = "Contains information about a OPA rego files.",
    fields = {
        "files": "OPA Rego files",
    },
)

OpaToolchainInfo = provider(
    doc = "Contains information about a OPA toolchain.",
    fields = {
        "cli": "The binary of OPA.",
    },
)
