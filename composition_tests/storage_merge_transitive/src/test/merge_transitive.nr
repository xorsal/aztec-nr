use crate::{StorageMergeTransitiveHost, test::utils};

/// The leaf's storage and the mid's composed function are both exposed on the host.
#[test]
unconstrained fn transitive_storage_reaches_host() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeTransitiveHost::at(host_addr);
    env.call_public(caller, host.leaf_value_set(7));
    assert_eq(env.view_public(host.leaf_value_get()), 7);
    assert_eq(env.view_public(host.mid_double_leaf()), 14);
}
