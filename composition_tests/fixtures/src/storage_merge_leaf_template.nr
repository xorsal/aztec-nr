use aztec::macros::{aztec, contract_template};

/// Leaf template used in transitive/diamond storage-merge scenarios. A host that transitively composes this template
/// via one or more intermediate templates should still see `leaf_value` in its merged `ComposedStorage`.
#[contract_template("storage_merge_leaf")]
#[aztec]
pub contract StorageMergeLeafTemplate {
    use aztec::{macros::{functions::{external, view}, storage::storage}, state_vars::PublicMutable};

    #[storage]
    struct Storage<Context> {
        leaf_value: PublicMutable<u32, Context>,
    }

    #[view]
    #[external("public")]
    fn leaf_value_get() -> u32 {
        self.storage.leaf_value.read()
    }

    #[external("public")]
    fn leaf_value_set(value: u32) {
        self.storage.leaf_value.write(value);
    }
}
