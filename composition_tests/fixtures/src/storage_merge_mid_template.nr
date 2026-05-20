use aztec::macros::{AztecConfig, aztec, contract_template};

/// Intermediate template that itself composes `storage_merge_leaf`. A host that composes *this* template gets
/// the leaf's `leaf_value` field transitively merged into its `ComposedStorage`.
#[contract_template("storage_merge_mid")]
#[aztec(AztecConfig::new().compose("storage_merge_leaf"))]
pub contract StorageMergeMidTemplate {
    use aztec::macros::{functions::{external, view}, storage::storage_no_init};

    #[storage_no_init]
    struct Storage<Context> {}

    impl<Context> Storage<Context> {
        fn init(_context: Context) -> Self {
            Self {}
        }
    }

    #[view]
    #[external("public")]
    fn mid_double_leaf() -> u32 {
        self.storage.leaf_value.read() * 2
    }
}
