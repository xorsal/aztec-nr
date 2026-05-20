pub mod test;

use aztec::macros::{AztecConfig, aztec};

/// Pure-mixin host: declares no storage of its own, composes a storage-bearing template. The storage-merge layer
/// has to synthesize a `ComposedStorage` from the composed template's fields alone, and `#[aztec]` has to fire
/// the synth gate without a host-side `#[storage]` struct to anchor on.
#[aztec(AztecConfig::new().compose("storage_merge_single_field"))]
pub contract StorageMergePureMixinHost {}
