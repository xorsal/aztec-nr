use crate::{OwnablePausableCounter, test::utils};

/// The composed `aztec_ownable` template's `get_owner` returns the value the host wrote during initialization.
#[test]
unconstrained fn composed_owner_is_initialized() {
    let (env, owner, _stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    assert_eq(env.view_public(host.get_owner()), owner);
}

/// `transfer_ownership` is composed from `aztec_ownable`; the owner can rotate ownership and the new owner
/// reads back through `get_owner`.
#[test]
unconstrained fn owner_can_transfer_ownership() {
    let (env, owner, stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    env.call_public(owner, host.transfer_ownership(stranger));
    assert_eq(env.view_public(host.get_owner()), stranger);
}

/// Non-owner cannot transfer ownership - the composed body's `_assert_only_owner` panics.
#[test(should_fail_with = "caller is not owner")]
unconstrained fn stranger_cannot_transfer_ownership() {
    let (env, _owner, stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    env.call_public(stranger, host.transfer_ownership(stranger));
}

/// Pause/unpause round-trips through composed externals; the composed `paused()` view reads the same slot the
/// composed mutator wrote.
#[test]
unconstrained fn owner_can_pause_and_unpause() {
    let (env, owner, _stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    assert_eq(env.view_public(host.paused()), false);
    env.call_public(owner, host.pause());
    assert_eq(env.view_public(host.paused()), true);
    env.call_public(owner, host.unpause());
    assert_eq(env.view_public(host.paused()), false);
}

/// Non-owner cannot pause - both templates' pause admin asserts read the merged `owner` slot.
#[test(should_fail_with = "caller is not owner")]
unconstrained fn stranger_cannot_pause() {
    let (env, _owner, stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    env.call_public(stranger, host.pause());
}

/// `increment` is host-authored; the `_assert_not_paused` library helper from `aztec_pausable` is composed into the
/// host's scope, and the function body resolves `self.storage.paused` through the merged `ComposedStorage`.
#[test]
unconstrained fn increment_works_while_unpaused() {
    let (env, owner, _stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    env.call_public(owner, host.increment());
    env.call_public(owner, host.increment());
    env.call_public(owner, host.increment());
    assert_eq(env.view_public(host.get_count()), 3);
}

/// Increment reverts while paused, via the composed `_assert_not_paused` library helper.
#[test(should_fail_with = "contract is paused")]
unconstrained fn increment_reverts_while_paused() {
    let (env, owner, _stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    env.call_public(owner, host.pause());
    env.call_public(owner, host.increment());
}

/// `#[only_owner]` macro injection: the host-authored `reset` function is owner-gated by the attribute, which
/// expands to `_assert_only_owner(self.msg_sender(), self.storage.owner.read())` and reads the composed `owner` slot.
#[test]
unconstrained fn only_owner_attribute_allows_owner_to_reset() {
    let (env, owner, _stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    env.call_public(owner, host.increment());
    env.call_public(owner, host.increment());
    env.call_public(owner, host.reset());
    assert_eq(env.view_public(host.get_count()), 0);
}

/// Non-owner cannot call a `#[only_owner]`-gated function.
#[test(should_fail_with = "caller is not owner")]
unconstrained fn only_owner_attribute_rejects_stranger() {
    let (env, _owner, stranger, host_addr) = utils::setup();
    let host = OwnablePausableCounter::at(host_addr);
    env.call_public(stranger, host.reset());
}
