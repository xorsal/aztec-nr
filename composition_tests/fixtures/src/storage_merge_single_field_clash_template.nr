use aztec::macros::{aztec, contract_template};

/// Same-name field as `storage_merge_single_field_template` but with a *different* type. A host composing both
/// templates should fail to compile with the cross-template type-mismatch panic.
#[contract_template("storage_merge_single_field_clash")]
#[aztec]
pub contract StorageMergeSingleFieldClashTemplate {
    use aztec::{macros::storage::storage, state_vars::PublicMutable};

    #[storage]
    struct Storage<Context> {
        counter: PublicMutable<bool, Context>,
    }
}
