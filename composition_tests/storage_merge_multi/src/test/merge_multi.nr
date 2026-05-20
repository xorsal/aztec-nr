use crate::{StorageMergeMultiHost, test::utils};

/// Both composed templates' fields are independently writeable + readable on the host.
#[test]
unconstrained fn both_templates_round_trip() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeMultiHost::at(host_addr);
    env.call_public(caller, host.pair_a_set(11));
    env.call_public(caller, host.pair_b_set(22));
    assert_eq(env.view_public(host.pair_a_get()), 11);
    assert_eq(env.view_public(host.pair_b_get()), 22);
}

/// Composed fields do not alias each other (different slots).
#[test]
unconstrained fn templates_do_not_alias() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeMultiHost::at(host_addr);
    env.call_public(caller, host.pair_a_set(100));
    env.call_public(caller, host.pair_b_set(200));
    env.call_public(caller, host.pair_a_set(101));
    assert_eq(env.view_public(host.pair_a_get()), 101);
    assert_eq(env.view_public(host.pair_b_get()), 200);
}
