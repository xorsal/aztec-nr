pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Diamond: host -> {mid_left, mid_right} -> leaf. The leaf's `leaf_value` is reachable through two paths; the
/// transitive-flatten + same-name-same-type dedup must collapse it to a single field in `ComposedStorage`.
#[aztec(
    AztecConfig::new().compose("storage_merge_mid_left").compose("storage_merge_mid_right")
)]
pub contract StorageMergeDiamondHost {}
