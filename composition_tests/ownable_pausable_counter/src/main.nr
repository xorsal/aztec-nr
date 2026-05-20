pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Demo host: a public counter that composes `aztec_ownable` and `aztec_pausable`. The host's only domain-specific
/// state is `count`. The two mixins both declare `owner: PublicMutable<AztecAddress, _>` in their `#[storage]` -
/// the storage merger's same-name+same-type dedup collapses them to a single slot, so one `_initialize_ownable(owner)`
/// authenticates admin paths on both templates.
///
/// Exercises every pillar of the storage-merge + only-owner POC end-to-end:
/// - storage merge across two templates with overlap (`owner` dedupes; `paused` is template-only),
/// - composed externals (`get_owner`, `transfer_ownership`, `pause`, `unpause`, `paused`),
/// - `#[only_owner]` attribute on a host-authored function reading the composed `owner` slot via the merger,
/// - composed `#[contract_library_method]` (`_assert_not_paused`) called from a host-authored function body.
#[aztec(AztecConfig::new().compose("aztec_ownable").compose("aztec_pausable"))]
pub contract OwnablePausableCounter {
    use aztec::{
        macros::{functions::{external, initializer, only_owner, view}, storage::storage},
        protocol::address::AztecAddress,
        state_vars::PublicMutable,
    };

    #[storage]
    struct Storage<Context> {
        count: PublicMutable<u64, Context>,
    }

    #[initializer]
    #[external("public")]
    fn constructor(owner: AztecAddress) {
        self.internal._initialize_ownable(owner);
        self.internal._initialize_pausable();
        self.storage.count.write(0);
    }

    /// Anyone can increment, but only while the contract is not paused.
    #[external("public")]
    fn increment() {
        _assert_not_paused(self.storage.paused.read());
        self.storage.count.write(self.storage.count.read() + 1);
    }

    /// Owner-gated reset to demonstrate `#[only_owner]` injection on a host-authored function. The check
    /// `_assert_only_owner(self.msg_sender(), self.storage.owner.read())` is woven in by the macro and reads the
    /// composed `owner` slot through `ComposedStorage`.
    #[only_owner]
    #[external("public")]
    fn reset() {
        self.storage.count.write(0);
    }

    #[view]
    #[external("public")]
    fn get_count() -> u64 {
        self.storage.count.read()
    }
}
