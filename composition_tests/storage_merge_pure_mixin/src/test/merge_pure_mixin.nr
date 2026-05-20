use crate::{StorageMergePureMixinHost, test::utils};

/// A host with no own storage exposes the composed template's storage operations end-to-end.
#[test]
unconstrained fn composed_counter_works_without_host_storage() {
    let (env, caller, host_addr) = utils::setup();
    let host = StorageMergePureMixinHost::at(host_addr);

    assert_eq(env.view_public(host.counter_get()), 0);
    env.call_public(caller, host.counter_inc());
    env.call_public(caller, host.counter_inc());
    env.call_public(caller, host.counter_inc());
    assert_eq(env.view_public(host.counter_get()), 3);
}
