use crate::utils::cmap::CHashMap;

/// Registers the functions that have the `#[authorize_once(...)]` macro, and the parameters the macro was invoked
/// with. This is used to later inject the authorization check (see ./utils.nr -> create_authorize_once_check) via the
/// #[external("private")] or #[external("public")] macros. The `#[authorize_once(...)]` macro is not used directly to
/// inject the check because it has to be placed after context instantiation but before the function body, which only
/// the aforementioned macros can do.
pub(crate) comptime mut global AUTHORIZE_ONCE_REGISTRY: CHashMap<FunctionDefinition, (CtString, CtString)> =
    CHashMap::new();

/// Registers the functions that have the `#[only_owner]` attribute. The owner check itself is injected later by the
/// `#[external("public")]` macro (see ./external/helpers.nr -> `create_only_owner_check`) for the same reason as
/// authorize_once: the check has to live after context instantiation but before the user's body. The injected check
/// is `_assert_only_owner(self.msg_sender(), self.storage.owner.read())`. Both symbols are expected to come from a
/// composed `aztec_ownable_mixin` template, which contributes the `owner` storage field via the storage merger and
/// migrates `_assert_only_owner` as a contract library method.
pub(crate) comptime mut global ONLY_OWNER_REGISTRY: CHashMap<FunctionDefinition, ()> = CHashMap::new();
