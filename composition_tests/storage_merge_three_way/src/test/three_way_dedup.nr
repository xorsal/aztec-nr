use crate::{StorageMergeThreeWayHost, test::utils};

/// `_initialize_ownable` (composed internal) wrote to the same slot the host's own reader observes - if the
/// merger created separate slots, the host read would return zero instead of the deployer address.
#[test]
unconstrained fn template_init_lands_in_host_visible_slot() {
    let (env, owner, _stranger, host_addr) = utils::setup(0);
    let host = StorageMergeThreeWayHost::at(host_addr);
    assert_eq(env.view_public(host.host_owner_view()), owner);
    assert_eq(env.view_public(host.get_owner()), owner);
}

/// Round-trip the OTHER direction: write `owner` via the host's own setter, then both composed externals
/// (`get_owner`, `pause`'s auth check) must see the same value.
#[test]
unconstrained fn host_write_visible_via_composed_externals() {
    let (env, owner, stranger, host_addr) = utils::setup(0);
    let host = StorageMergeThreeWayHost::at(host_addr);

    env.call_public(owner, host.host_owner_overwrite(stranger));
    assert_eq(env.view_public(host.get_owner()), stranger);
    assert_eq(env.view_public(host.host_owner_view()), stranger);
}

/// Composed-external mutation (`transfer_ownership`) is observable through the host's own reader, confirming
/// the slot all three declarations collapsed to is the same one the host accesses.
#[test]
unconstrained fn composed_transfer_visible_via_host_view() {
    let (env, owner, stranger, host_addr) = utils::setup(0);
    let host = StorageMergeThreeWayHost::at(host_addr);
    env.call_public(owner, host.transfer_ownership(stranger));
    assert_eq(env.view_public(host.host_owner_view()), stranger);
}

/// The pausable template's admin gate (`pause` -> `_assert_pausable_admin`) authenticates against the merged
/// `owner` slot, so a host-side overwrite of `owner` flows through to who can pause.
#[test(should_fail_with = "caller is not owner")]
unconstrained fn host_overwrite_revokes_old_owner_pause_rights() {
    let (env, owner, stranger, host_addr) = utils::setup(0);
    let host = StorageMergeThreeWayHost::at(host_addr);

    // Original owner overwrites the slot to `stranger`. The old owner now has no admin rights.
    env.call_public(owner, host.host_owner_overwrite(stranger));
    env.call_public(owner, host.pause());
}

/// After a host-side owner overwrite, the new owner can pause - same slot, same gate.
#[test]
unconstrained fn host_overwrite_grants_new_owner_pause_rights() {
    let (env, owner, stranger, host_addr) = utils::setup(0);
    let host = StorageMergeThreeWayHost::at(host_addr);

    env.call_public(owner, host.host_owner_overwrite(stranger));
    env.call_public(stranger, host.pause());
    assert_eq(env.view_public(host.paused()), true);
}

/// The host's domain field (`treasury_balance`) lives at a separate slot. Owner manipulation does not touch
/// it, and treasury manipulation does not touch the owner slot.
#[test]
unconstrained fn host_domain_field_and_merged_owner_do_not_alias() {
    let (env, owner, stranger, host_addr) = utils::setup(1000);
    let host = StorageMergeThreeWayHost::at(host_addr);

    assert_eq(env.view_public(host.treasury_get()), 1000);
    env.call_public(owner, host.transfer_ownership(stranger));
    assert_eq(env.view_public(host.treasury_get()), 1000);

    env.call_public(stranger, host.treasury_set(2000));
    assert_eq(env.view_public(host.get_owner()), stranger);
    assert_eq(env.view_public(host.treasury_get()), 2000);
}
