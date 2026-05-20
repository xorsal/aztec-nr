use crate::{StorageMergeBasicHost, test::utils};

/// The composed template's storage is observable on the host (no host re-declaration of `counter` needed).
#[test]
unconstrained fn composed_counter_reads_as_zero_initially() {
    let (env, _caller, host_addr) = utils::setup();
    let host = StorageMergeBasicHost::at(host_addr);
    assert_eq(env.view_public(host.counter_get()), 0);
}

/// Mutating the composed field through the composed external function is visible via the composed read.
#[test]
unconstrained fn composed_counter_inc_round_trips() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeBasicHost::at(host_addr);
    env.call_public(caller, host.counter_inc());
    env.call_public(caller, host.counter_inc());
    assert_eq(env.view_public(host.counter_get()), 2);
}

/// The host's own storage field still works alongside the composed one.
#[test]
unconstrained fn host_own_field_round_trips() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeBasicHost::at(host_addr);
    env.call_public(caller, host.host_only_set(0xdeadbeef));
    assert_eq(env.view_public(host.host_only_get()), 0xdeadbeef);
}

/// Composed and host fields are independent: writing one doesn't disturb the other (different slots).
#[test]
unconstrained fn host_and_composed_fields_do_not_alias() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeBasicHost::at(host_addr);
    env.call_public(caller, host.counter_inc());
    env.call_public(caller, host.host_only_set(42));
    env.call_public(caller, host.counter_inc());
    assert_eq(env.view_public(host.counter_get()), 2);
    assert_eq(env.view_public(host.host_only_get()), 42);
}
