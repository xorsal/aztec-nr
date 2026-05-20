pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Host -> mid -> leaf, where only the leaf has storage. The synth must flatten the composition graph so the leaf's
/// `leaf_value` field appears in the host's `ComposedStorage`, and mid's composed function `mid_double_leaf()` must
/// resolve `self.storage.leaf_value` against the host's merged struct.
#[aztec(AztecConfig::new().compose("storage_merge_mid"))]
pub contract StorageMergeTransitiveHost {}
