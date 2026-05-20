use crate::{StorageMergeDedupHost, test::utils};

/// Host writer + composed reader observe the same slot.
#[test]
unconstrained fn host_write_visible_via_composed_read() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeDedupHost::at(host_addr);
    env.call_public(caller, host.host_counter_write(7));
    assert_eq(env.view_public(host.counter_get()), 7);
}

/// Composed writer + host reader observe the same slot.
#[test]
unconstrained fn composed_inc_visible_via_host_read() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeDedupHost::at(host_addr);
    env.call_public(caller, host.counter_inc());
    env.call_public(caller, host.counter_inc());
    assert_eq(env.view_public(host.host_counter_get()), 2);
}

/// Interleaved host/composed mutations accumulate against the single shared slot.
#[test]
unconstrained fn host_and_composed_mutations_share_slot() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergeDedupHost::at(host_addr);
    env.call_public(caller, host.host_counter_write(10));
    env.call_public(caller, host.counter_inc());
    env.call_public(caller, host.counter_inc());
    env.call_public(caller, host.counter_inc());
    assert_eq(env.view_public(host.counter_get()), 13);
    assert_eq(env.view_public(host.host_counter_get()), 13);
}
