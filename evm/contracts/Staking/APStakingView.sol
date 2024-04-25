//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./APStaking.sol";
import "./APStakingUtility.sol";

contract APStakingView {
    function getAllStakesOfAddress(address stakingAddress, address staker) external view returns (APStakingUtility.StakeStore[] memory)  {
        uint stakeCount = APStaking(stakingAddress).stakeCount(staker);

        APStakingUtility.StakeStore[] memory stakes = new APStakingUtility.StakeStore[](stakeCount);

        for (uint i; i < stakeCount; i++) {
            (
                uint128 stakedAmount,
                uint128 stakeShares,
                uint40 stakeId,
                uint16 lockedDay,
                uint16 stakedDays,
                uint16 unlockedDay
            ) = APStaking(stakingAddress).stakeLists(staker, i);


            stakes[i] = APStakingUtility.StakeStore(
                stakedAmount,
                stakeShares,
                stakeId,
                lockedDay,
                stakedDays,
                unlockedDay
            );
        }

        return stakes;
    }
}
