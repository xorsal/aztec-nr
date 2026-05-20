pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Host declares `counter` with the SAME name AND type as the composed template's `counter` field. The soft-dedup
/// path should treat this as a single field in `ComposedStorage` (the host's declaration "wins" but the slot/type
/// is identical so there is nothing to choose). The composed template's `counter_inc()` and the host's own writer
/// must observe the same backing storage.
#[aztec(AztecConfig::new().compose("storage_merge_single_field"))]
pub contract StorageMergeDedupHost {
    use aztec::{macros::{functions::{external, view}, storage::storage}, state_vars::PublicMutable};

    #[storage]
    struct Storage<Context> {
        counter: PublicMutable<u64, Context>,
    }

    #[view]
    #[external("public")]
    fn host_counter_get() -> u64 {
        self.storage.counter.read()
    }

    #[external("public")]
    fn host_counter_write(value: u64) {
        self.storage.counter.write(value);
    }
}
