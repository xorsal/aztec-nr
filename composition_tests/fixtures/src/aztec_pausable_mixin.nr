use aztec::macros::{aztec, contract_template};

/// Pausable contract template. Adds an emergency-stop surface (`pause`, `unpause`, `paused`) plus an
/// `_initialize_pausable()` internal and the `_assert_not_paused` library helper hosts use to gate their
/// own functions while paused.
///
/// Composition with `aztec_ownable`: this template's `owner` slot dedupes with the ownable template's via
/// the storage merger's same-name+same-type rule, so `_initialize_ownable(owner)` initializes both. The
/// pause admin helper is intentionally named `_assert_pausable_admin` (not `_assert_only_owner`) so it
/// doesn't collide with `aztec_ownable_mixin`'s identically-named library method when both are composed.
#[contract_template("aztec_pausable")]
#[aztec]
pub contract AztecPausableMixin {
    use aztec::{
        macros::{functions::{external, internal, view}, storage::storage},
        protocol::address::AztecAddress,
        state_vars::PublicMutable,
    };

    #[storage]
    struct Storage<Context> {
        owner: PublicMutable<AztecAddress, Context>,
        paused: PublicMutable<bool, Context>,
    }

    #[view]
    #[external("public")]
    fn paused() -> bool {
        self.storage.paused.read()
    }

    #[external("public")]
    fn pause() {
        _assert_pausable_admin(self.msg_sender(), self.storage.owner.read());
        assert(!self.storage.paused.read(), "already paused");
        self.storage.paused.write(true);
    }

    #[external("public")]
    fn unpause() {
        _assert_pausable_admin(self.msg_sender(), self.storage.owner.read());
        assert(self.storage.paused.read(), "not paused");
        self.storage.paused.write(false);
    }

    #[internal("public")]
    fn _initialize_pausable() {
        self.storage.paused.write(false);
    }

    #[contract_library_method]
    fn _assert_pausable_admin(caller: AztecAddress, current_owner: AztecAddress) {
        assert(current_owner.eq(caller), "caller is not owner");
    }

    #[contract_library_method]
    fn _assert_not_paused(paused: bool) {
        assert(!paused, "contract is paused");
    }
}
