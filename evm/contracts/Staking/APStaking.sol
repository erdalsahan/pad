//SPDX-License-Identifier: MIT
/*
2024 © Atlaspad Launchpad
Virjilakrum
*/
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./APStakingUtility.sol";
import "./helpers/IERC20Burnable.sol";

contract APStaking is APStakingUtility {
    using SafeERC20 for IERC20Burnable;

    constructor(
        IERC20Burnable _stakingToken, // MUST BE BURNABLE ?
        uint40 _launchTime,
        address _originAddr
    )
    {
        require(IERC20Metadata(address(_stakingToken)).decimals() == TOKEN_DECIMALS, "STAKING: incompatible token decimals");
        require(_launchTime >= block.timestamp, "STAKING: launch must be in future");
        require(_originAddr != address(0), "STAKING: origin address is 0");

        stakingToken = _stakingToken;
        launchTime = _launchTime;
        originAddr = _originAddr;

        /* Initialize global shareRate to 1 */
        globals.shareRate = uint40(1 * SHARE_RATE_SCALE);
    }

    /**
     * @param newStakedAmount Amount of staking token to stake
     * @param newStakedDays Number of days to stake
     */

    function stakeStart(uint256 newStakedAmount, uint256 newStakedDays)
        external
    {
        GlobalsCache memory g;
        _globalsLoad(g);
        require(newStakedDays >= MIN_STAKE_DAYS, "STAKING: newStakedDays lower than minimum");
        require(newStakedDays <= MAX_STAKE_DAYS, "STAKING: newStakedDays higher than maximum");
        _dailyDataUpdateAuto(g);
        _stakeStart(g, newStakedAmount, newStakedDays);
        stakingToken.safeTransferFrom(msg.sender, address(this), newStakedAmount);
        _globalsSync(g);
    }
    function stakeGoodAccounting(address stakerAddr, uint256 stakeIndex, uint40 stakeIdParam)
        external
    {
        GlobalsCache memory g;
        _globalsLoad(g);
        require(stakeLists[stakerAddr].length != 0, "STAKING: Empty stake list");
        require(stakeIndex < stakeLists[stakerAddr].length, "STAKING: stakeIndex invalid");
        StakeStore storage stRef = stakeLists[stakerAddr][stakeIndex];
        StakeCache memory st;
        _stakeLoad(stRef, stakeIdParam, st);
        require(g._currentDay >= st._lockedDay + st._stakedDays, "STAKING: Stake not fully served");
        require(st._unlockedDay == 0, "STAKING: Stake already unlocked");
        _dailyDataUpdateAuto(g);
        _stakeUnlock(g, st);
        (, uint256 payout, uint256 penalty, uint256 cappedPenalty) = _stakePerformance(
            st,
            st._stakedDays
        );

        emit StakeGoodAccounting(
            stakerAddr,
            stakeIdParam,
            msg.sender,
            uint40(block.timestamp),
            uint128(st._stakedAmount),
            uint128(st._stakeShares),
            uint128(payout),
            uint128(penalty)
        );

        if (cappedPenalty != 0) {
            _splitPenaltyProceeds(g, cappedPenalty);
        }
        _stakeUpdate(stRef, st);

        _globalsSync(g);
    }
    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam)
        external
        returns (uint256 stakeReturn, uint256 payout, uint256 penalty, uint256 cappedPenalty)
    {
        GlobalsCache memory g;
        _globalsLoad(g);

        StakeStore[] storage stakeListRef = stakeLists[msg.sender];
        require(stakeListRef.length != 0, "STAKING: Empty stake list");
        require(stakeIndex < stakeListRef.length, "STAKING: stakeIndex invalid");

        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);
        _dailyDataUpdateAuto(g);
     // require(g._currentDay >= st._lockedDay + HARD_LOCK_DAYS, "STAKING: hard lock period");
        uint256 servedDays = 0;
        bool prevUnlocked = (st._unlockedDay != 0);

        if (prevUnlocked) {
            servedDays = st._stakedDays;
        } else {
            _stakeUnlock(g, st);

            servedDays = g._currentDay - st._lockedDay;
            if (servedDays > st._stakedDays) {
                servedDays = st._stakedDays;
            }
        }

        (stakeReturn, payout, penalty, cappedPenalty) = _stakePerformance(st, servedDays);

        emit StakeEnd(
            msg.sender,
            stakeIdParam,
            uint40(block.timestamp),
            uint128(st._stakedAmount),
            uint128(st._stakeShares),
            uint128(payout),
            uint128(penalty),
            uint16(servedDays),
            prevUnlocked
        );

        if (cappedPenalty != 0 && !prevUnlocked) {
            _splitPenaltyProceeds(g, cappedPenalty);
        }
        if (stakeReturn != 0) {
            stakingToken.safeTransfer(msg.sender, stakeReturn);
            _shareRateUpdate(g, st, stakeReturn);
        }
        g._lockedStakeTotal -= st._stakedAmount;

        _stakeRemove(stakeListRef, stakeIndex);

        _globalsSync(g);

        return (
            stakeReturn,
            payout,
            penalty,
            cappedPenalty
        );
    }

    function fundRewards(
        uint128 amountPerDay,
        uint16 daysCount,
        uint16 shiftInDays
    )
        external
    {
        require(daysCount <= 365, "STAKING: too many days");

        stakingToken.safeTransferFrom(msg.sender, address(this), amountPerDay * daysCount);

        uint256 currentDay = _currentDay() + 1;
        uint256 fromDay = currentDay + shiftInDays;

        for (uint256 day = fromDay; day < fromDay + daysCount; day++) {
            dailyData[day].dayPayoutTotal += amountPerDay;
        }

        emit RewardsFund(amountPerDay, daysCount, shiftInDays);
    }
    function stakeCount(address stakerAddr)
        external
        view
        returns (uint256)
    {
        return stakeLists[stakerAddr].length;
    }
    function _stakeStart(
        GlobalsCache memory g,
        uint256 newStakedAmount,
        uint256 newStakedDays
    )
        internal
    {
        uint256 bonusShares = stakeStartBonusShares(newStakedAmount, newStakedDays);
        uint256 newStakeShares = (newStakedAmount + bonusShares) * SHARE_RATE_SCALE / g._shareRate;
        require(newStakeShares != 0, "STAKING: newStakedAmount must be at least minimum shareRate");
        uint256 newLockedDay = g._currentDay + 1;

        /* Create Stake and add ID */
        uint40 newStakeId = ++g._latestStakeId;
        _stakeAdd(
            stakeLists[msg.sender],
            newStakeId,
            newStakedAmount,
            newStakeShares,
            newLockedDay,
            newStakedDays
        );

        emit StakeStart(
            msg.sender,
            newStakeId,
            uint40(block.timestamp),
            uint128(newStakedAmount),
            uint128(newStakeShares),
            uint16(newStakedDays)
        );

        g._nextStakeSharesTotal += newStakeShares;
        g._lockedStakeTotal += newStakedAmount;
        dailyData[newLockedDay + newStakedDays].sharesToBeRemoved += uint128(newStakeShares);
    }
    function getStakeStatus(
        address staker,
        uint256 stakeIndex,
        uint40 stakeIdParam
    )
        external
        view
        returns (uint256 stakeReturn, uint256 payout, uint256 penalty, uint256 cappedPenalty)
    {
        GlobalsCache memory g;
        _globalsLoad(g);

        StakeStore[] storage stakeListRef = stakeLists[staker];

        require(stakeListRef.length != 0, "STAKING: Empty stake list");
        require(stakeIndex < stakeListRef.length, "STAKING: stakeIndex invalid");

        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);

        uint256 servedDays = 0;
        bool prevUnlocked = (st._unlockedDay != 0);

        if (prevUnlocked) {
            servedDays = st._stakedDays;
        } else {
            st._unlockedDay = g._currentDay;

            servedDays = g._currentDay - st._lockedDay;
            if (servedDays > st._stakedDays) {
                servedDays = st._stakedDays;
            }
        }

        (stakeReturn, payout, penalty, cappedPenalty) = _stakePerformance(st, servedDays);
    }
    function _calcPayoutRewards(
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    )
        private
        view
        returns (uint256 payout)
    {
        uint256 accRewardPerShare = dailyData[endDay - 1].accRewardPerShare - dailyData[beginDay - 1].accRewardPerShare;
        payout = stakeSharesParam * accRewardPerShare / ACC_REWARD_MULTIPLIER;
        return payout;
    }
    function stakeStartBonusShares(uint256 newStakedAmount, uint256 newStakedDays)
        public
        pure
        returns (uint256 bonusShares)
    {
        uint256 cappedExtraDays = 0;
        if (newStakedDays > 1) {
            cappedExtraDays = newStakedDays <= LPB_MAX_DAYS ? newStakedDays - 1 : LPB_MAX_DAYS;
        }

        uint256 cappedStakedAmount = newStakedAmount >= BPB_FROM_AMOUNT ? newStakedAmount - BPB_FROM_AMOUNT : 0;
        if (cappedStakedAmount > BPB_MAX) {
            cappedStakedAmount = BPB_MAX;
        }

        bonusShares = cappedExtraDays * BPB + cappedStakedAmount * LPB;
        bonusShares = newStakedAmount * bonusShares / (LPB * BPB);

        return bonusShares;
    }

    function _stakeUnlock(GlobalsCache memory g, StakeCache memory st)
        private
    {
        st._unlockedDay = g._currentDay;

        uint256 endDay = st._lockedDay + st._stakedDays;

        if (g._currentDay <= endDay) {
            dailyData[endDay].sharesToBeRemoved -= uint128(st._stakeShares);
            g._stakeSharesTotal -= st._stakeShares;
        }
    }

    function _stakePerformance(StakeCache memory st, uint256 servedDays)
        private
        view
        returns (uint256 stakeReturn, uint256 payout, uint256 penalty, uint256 cappedPenalty)
    {
        if (servedDays < st._stakedDays) {
            (payout, penalty) = _calcPayoutAndEarlyPenalty(
                st._lockedDay,
                st._stakedDays,
                servedDays,
                st._stakeShares
            );
            stakeReturn = st._stakedAmount + payout;
        } else {
            payout = _calcPayoutRewards(
                st._stakeShares,
                st._lockedDay,
                st._lockedDay + servedDays
            );
            stakeReturn = st._stakedAmount + payout;

            penalty = _calcLatePenalty(st._lockedDay, st._stakedDays, st._unlockedDay, stakeReturn);
        }
        if (penalty != 0) {
            if (penalty > stakeReturn) {
                cappedPenalty = stakeReturn;
                stakeReturn = 0;
            } else {
                /* Remove penalty from the stake return */
                cappedPenalty = penalty;
                stakeReturn -= cappedPenalty;
            }
        }
        return (stakeReturn, payout, penalty, cappedPenalty);
    }

    function _calcPayoutAndEarlyPenalty(
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 servedDays,
        uint256 stakeSharesParam
    )
        private
        view
        returns (uint256 payout, uint256 penalty)
    {
        uint256 servedEndDay = lockedDayParam + servedDays;
        uint256 penaltyDays = (stakedDaysParam + 1) / 2;
// %50
        if (penaltyDays < EARLY_PENALTY_MIN_DAYS) {
            penaltyDays = EARLY_PENALTY_MIN_DAYS;
        }

        if (penaltyDays < servedDays) {

            uint256 penaltyEndDay = lockedDayParam + penaltyDays;
            penalty = _calcPayoutRewards(stakeSharesParam, lockedDayParam, penaltyEndDay);

            uint256 delta = _calcPayoutRewards(stakeSharesParam, penaltyEndDay, servedEndDay);
            payout = penalty + delta;
            return (payout, penalty);
        }

        payout = _calcPayoutRewards(stakeSharesParam, lockedDayParam, servedEndDay);

        if (penaltyDays == servedDays) {
            penalty = payout;
        } else {
            penalty = payout * penaltyDays / servedDays;
        }
        return (payout, penalty);
    }

    function _calcLatePenalty(
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 unlockedDayParam,
        uint256 rawStakeReturn
    )
        private
        pure
        returns (uint256)
    {
        uint256 maxUnlockedDay = lockedDayParam + stakedDaysParam + LATE_PENALTY_GRACE_DAYS;
        if (unlockedDayParam <= maxUnlockedDay) {
            return 0;
        }

        return rawStakeReturn * (unlockedDayParam - maxUnlockedDay) / LATE_PENALTY_SCALE_DAYS;
    }

    function _splitPenaltyProceeds(GlobalsCache memory g, uint256 penalty)
        private
    {
        uint256 splitPenalty = penalty / 2;

        if (splitPenalty != 0) {
   
            uint256 originPenalty = splitPenalty * 3 / 5;
         // %30
            stakingToken.safeTransfer(originAddr, originPenalty);

            //20% of the total penalty is burned
            stakingToken.burn(splitPenalty - originPenalty);
        }
        splitPenalty = penalty - splitPenalty;
        g._stakePenaltyTotal += splitPenalty;
    }

    function _shareRateUpdate(GlobalsCache memory g, StakeCache memory st, uint256 stakeReturn)
        private
    {
        if (stakeReturn > st._stakedAmount) {

            uint256 bonusShares = stakeStartBonusShares(stakeReturn, st._stakedDays);
            uint256 newShareRate = (stakeReturn + bonusShares) * SHARE_RATE_SCALE / st._stakeShares;

            if (newShareRate > SHARE_RATE_MAX) {

                newShareRate = SHARE_RATE_MAX;
            }

            if (newShareRate > g._shareRate) {
                g._shareRate = newShareRate;

                emit ShareRateChange(
                    st._stakeId,
                    uint40(block.timestamp),
                    uint40(newShareRate)
                );
            }
        }
    }
}
