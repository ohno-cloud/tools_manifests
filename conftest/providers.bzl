ConftestPolicyInfo = provider(
    doc = "Contains information about a conftest policy files.",
    fields = {
        "files": "conftest Rego files",
    },
)

ConftestToolchainInfo = provider(
    doc = "Contains information about a conftest toolchain.",
    fields = {
        "cli": "The binary of conftest.",
    },
)
