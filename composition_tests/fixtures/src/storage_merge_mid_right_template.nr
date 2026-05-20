use aztec::macros::{AztecConfig, aztec, contract_template};

/// Right arm of a diamond: composes `storage_merge_leaf` transitively. See `storage_merge_mid_left_template`.
#[contract_template("storage_merge_mid_right")]
#[aztec(AztecConfig::new().compose("storage_merge_leaf"))]
pub contract StorageMergeMidRightTemplate {
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
    fn right_leaf_minus(n: u32) -> u32 {
        self.storage.leaf_value.read() - n
    }
}
