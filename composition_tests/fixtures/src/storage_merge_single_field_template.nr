use aztec::macros::{aztec, contract_template};

/// Template with a single storage field plus an external read/write pair. Used by happy-path storage-merge fixtures
/// to prove that a host composing this template gets `counter` in its merged `ComposedStorage` without redeclaring
/// it, and that the composed functions (`counter_get`, `counter_inc`) operate on the host's runtime state.
#[contract_template("storage_merge_single_field")]
#[aztec]
pub contract StorageMergeSingleFieldTemplate {
    use aztec::{macros::{functions::{external, view}, storage::storage}, state_vars::PublicMutable};

    #[storage]
    struct Storage<Context> {
        counter: PublicMutable<u64, Context>,
    }

    #[view]
    #[external("public")]
    fn counter_get() -> u64 {
        self.storage.counter.read()
    }

    #[external("public")]
    fn counter_inc() {
        let cur = self.storage.counter.read();
        self.storage.counter.write(cur + 1);
    }
}
