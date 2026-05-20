use aztec::macros::{aztec, contract_template};

/// Second of a pair of templates with non-overlapping storage. See `storage_merge_pair_a_template`.
#[contract_template("storage_merge_pair_b")]
#[aztec]
pub contract StorageMergePairBTemplate {
    use aztec::{macros::{functions::{external, view}, storage::storage}, state_vars::PublicMutable};

    #[storage]
    struct Storage<Context> {
        pair_b: PublicMutable<u64, Context>,
    }

    #[view]
    #[external("public")]
    fn pair_b_get() -> u64 {
        self.storage.pair_b.read()
    }

    #[external("public")]
    fn pair_b_set(value: u64) {
        self.storage.pair_b.write(value);
    }
}
