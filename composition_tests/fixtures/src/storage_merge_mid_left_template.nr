use aztec::macros::{AztecConfig, aztec, contract_template};

/// Left arm of a diamond: composes `storage_merge_leaf` transitively. Paired with `storage_merge_mid_right_template`
/// so a host composing both arms exercises the dedup path on the shared leaf field.
#[contract_template("storage_merge_mid_left")]
#[aztec(AztecConfig::new().compose("storage_merge_leaf"))]
pub contract StorageMergeMidLeftTemplate {
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
    fn left_leaf_plus(n: u32) -> u32 {
        self.storage.leaf_value.read() + n
    }
}
