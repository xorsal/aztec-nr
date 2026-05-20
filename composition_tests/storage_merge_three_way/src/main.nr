pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Three-way dedup: the host declares `owner` in its own `#[storage]`, AND composes two templates
/// (`aztec_ownable` + `aztec_pausable`) that both also declare `owner: PublicMutable<AztecAddress, _>`.
/// The merger's same-name+same-type rule must collapse all three declarations into a single slot in
/// `ComposedStorage`. Tests cover:
/// - the host's own `owner` setter writes to the slot composed externals read,
/// - `_initialize_ownable` (composed internal) writes to the slot the host's own reader observes,
/// - `pause()` (composed external) authenticates against the same slot the host writes through,
/// - `transfer_ownership` (composed external) rotates the slot all three views agree on,
/// - the host's domain field `treasury_balance` lives at a separate slot and is not perturbed by
///   any owner manipulation (slot layout: owner @ 1, paused @ 2, treasury_balance @ 3).
#[aztec(AztecConfig::new().compose("aztec_ownable").compose("aztec_pausable"))]
pub contract StorageMergeThreeWayHost {
    use aztec::{
        macros::{functions::{external, initializer, view}, storage::storage},
        protocol::address::AztecAddress,
        state_vars::PublicMutable,
    };

    #[storage]
    struct Storage<Context> {
        owner: PublicMutable<AztecAddress, Context>,
        treasury_balance: PublicMutable<u64, Context>,
    }

    #[initializer]
    #[external("public")]
    fn constructor(owner: AztecAddress, initial_treasury: u64) {
        self.internal._initialize_ownable(owner);
        self.internal._initialize_pausable();
        self.storage.treasury_balance.write(initial_treasury);
    }

    /// Host-side reader for `owner`. Same slot the composed `get_owner()` reads.
    #[view]
    #[external("public")]
    fn host_owner_view() -> AztecAddress {
        self.storage.owner.read()
    }

    /// Host-side writer for `owner` (unauthenticated by design - the test asserts slot identity, not access
    /// control). Writes through host storage; composed externals like `pause()` should authenticate against
    /// the value written here.
    #[external("public")]
    fn host_owner_overwrite(new_owner: AztecAddress) {
        self.storage.owner.write(new_owner);
    }

    #[view]
    #[external("public")]
    fn treasury_get() -> u64 {
        self.storage.treasury_balance.read()
    }

    #[external("public")]
    fn treasury_set(amount: u64) {
        self.storage.treasury_balance.write(amount);
    }
}
