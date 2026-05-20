use crate::OwnablePausableCounter;
use aztec::{protocol::address::AztecAddress, test::helpers::test_environment::TestEnvironment};

pub unconstrained fn setup() -> (TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();
    let owner = env.create_light_account();
    let stranger = env.create_light_account();
    let host = env.deploy("@ownable_pausable_counter_contract/OwnablePausableCounter").with_public_initializer(
        owner,
        OwnablePausableCounter::interface().constructor(owner),
    );

    (env, owner, stranger, host)
}
