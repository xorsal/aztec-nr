// Poison contract: EXPECTED to fail compilation.
//
// Composes two templates that declare a same-named storage field with different types
// (`storage_merge_single_field` has `counter: PublicMutable<u64>`; `storage_merge_single_field_clash` has
// `counter: PublicMutable<bool>`). The composed storage merger should panic before reaching name resolution,
// surfacing the conflict at the macro layer with a clear message.

use aztec::macros::{AztecConfig, aztec};

#[aztec(
    AztecConfig::new()
        .compose("storage_merge_single_field")
        .compose("storage_merge_single_field_clash")
)]
pub contract StorageMergeTemplateClashHost {}
