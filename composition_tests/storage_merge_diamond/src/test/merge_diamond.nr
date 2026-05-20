use crate::{StorageMergeDiamondHost, test::utils};

/// Both diamond arms see the same `leaf_value`. A write through one arm is observable through both arms' reads
/// and through the leaf's direct accessor.
#[test]
unconstrained fn diamond_arms_share_leaf_storage() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeDiamondHost::at(host_addr);
    env.call_public(caller, host.leaf_value_set(10));

    assert_eq(env.view_public(host.leaf_value_get()), 10);
    assert_eq(env.view_public(host.left_leaf_plus(5)), 15);
    assert_eq(env.view_public(host.right_leaf_minus(3)), 7);
}
