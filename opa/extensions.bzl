load("//opa:repo.bzl", "opa_register_toolchains")

def _opa_extension_impl(mctx):
    opa_register_toolchains(name="opa", version="1.1.0", register = False)

opa_extension = module_extension(implementation = _opa_extension_impl)
