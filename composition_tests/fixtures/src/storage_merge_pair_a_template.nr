use aztec::macros::{aztec, contract_template};

/// First of a pair of templates with non-overlapping storage. Used to prove that composing multiple templates
/// unions their fields and assigns slots deterministically by compose-invocation order.
#[contract_template("storage_merge_pair_a")]
#[aztec]
pub contract StorageMergePairATemplate {
    use aztec::{macros::{functions::{external, view}, storage::storage}, state_vars::PublicMutable};

    #[storage]
    struct Storage<Context> {
        pair_a: PublicMutable<u32, Context>,
    }

    #[view]
    #[external("public")]
    fn pair_a_get() -> u32 {
        self.storage.pair_a.read()
    }

    #[external("public")]
    fn pair_a_set(value: u32) {
        self.storage.pair_a.write(value);
    }
}
