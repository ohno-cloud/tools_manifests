K8sGenConfigInfo = provider(
    doc = "Contains information about a k8s-gen config.",
    fields = {
        "crds": "CustomResourceDefintion files",
    },
)

K8sGenToolchainInfo = provider(
    doc = "Contains information about a k8s-gen toolchain.",
    fields = {
        "cli": "The binary of k8s-gen.",
    },
)
