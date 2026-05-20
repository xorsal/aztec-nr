pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Host composes two storage-bearing templates with disjoint fields. Verifies template-template union and that the
/// composed externals are independent (writing one doesn't disturb the other).
#[aztec(AztecConfig::new().compose("storage_merge_pair_a").compose("storage_merge_pair_b"))]
pub contract StorageMergeMultiHost {}
