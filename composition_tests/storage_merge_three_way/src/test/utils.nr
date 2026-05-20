use crate::StorageMergeThreeWayHost;
use aztec::{protocol::address::AztecAddress, test::helpers::test_environment::TestEnvironment};

pub unconstrained fn setup(
    initial_treasury: u64,
) -> (TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();
    let owner = env.create_light_account();
    let stranger = env.create_light_account();
    let host = env.deploy("@storage_merge_three_way_contract/StorageMergeThreeWayHost").with_public_initializer(
        owner,
        StorageMergeThreeWayHost::interface().constructor(owner, initial_treasury),
    );

    (env, owner, stranger, host)
}
