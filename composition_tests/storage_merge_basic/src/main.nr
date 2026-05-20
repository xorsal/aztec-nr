pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Host with its own storage field PLUS a composed template that contributes a field. Proves the basic union case:
/// the merged `ComposedStorage` carries both, host-only operations still work, and composed-template operations
/// observe the same backing storage that the template body originally wrote to.
#[aztec(AztecConfig::new().compose("storage_merge_single_field"))]
pub contract StorageMergeBasicHost {
    use aztec::{macros::{functions::{external, view}, storage::storage}, state_vars::PublicMutable};

    #[storage]
    struct Storage<Context> {
        host_only: PublicMutable<Field, Context>,
    }

    #[view]
    #[external("public")]
    fn host_only_get() -> Field {
        self.storage.host_only.read()
    }

    #[external("public")]
    fn host_only_set(value: Field) {
        self.storage.host_only.write(value);
    }
}
