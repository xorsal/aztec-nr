use aztec::macros::{aztec, contract_template};

/// Ownable contract template. Contributes a single-owner access-control surface (`get_owner`,
/// `transfer_ownership`, `_initialize_ownable`) plus the `_assert_only_owner` library helper that
/// `#[only_owner]` expands to. Storage merger contributes the `owner` field; `_assert_only_owner`
/// migrates into the host scope at composition time as a `#[contract_library_method]`.
///
/// Hosts opt in with `#[aztec(AztecConfig::new().compose("aztec_ownable"))]`. Combined with
/// `#[only_owner] #[external("public")] fn foo() { ... }`, the host gets owner-gated functions
/// without writing the boilerplate inline.
#[contract_template("aztec_ownable")]
#[aztec]
pub contract AztecOwnableMixin {
    use aztec::{
        macros::{functions::{external, internal, view}, storage::storage},
        protocol::address::AztecAddress,
        state_vars::PublicMutable,
    };

    #[storage]
    struct Storage<Context> {
        owner: PublicMutable<AztecAddress, Context>,
    }

    #[view]
    #[external("public")]
    fn get_owner() -> AztecAddress {
        self.storage.owner.read()
    }

    #[external("public")]
    fn transfer_ownership(new_owner: AztecAddress) {
        _assert_only_owner(self.msg_sender(), self.storage.owner.read());
        assert(
            !new_owner.eq(aztec::protocol::address::AztecAddress::zero()),
            "new owner is zero",
        );
        self.storage.owner.write(new_owner);
    }

    #[internal("public")]
    fn _initialize_ownable(owner: AztecAddress) {
        self.storage.owner.write(owner);
    }

    #[contract_library_method]
    fn _assert_only_owner(caller: AztecAddress, current_owner: AztecAddress) {
        assert(current_owner.eq(caller), "caller is not owner");
    }
}
