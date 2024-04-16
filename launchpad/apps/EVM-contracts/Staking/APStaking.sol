// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.9.0;

interface IERC20 {
    function totalSupply() external view returns(uint);

function balanceOf(address account) external view returns(uint);

function transfer(address recipient, uint amount) external returns(bool);

function allowance(address owner, address spender) external view returns(uint);

function approve(address spender, uint amount) external returns(bool);

function transferFrom(
    address sender,
    address recipient,
    uint amount
) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract StakingContract {
    IERC20 public immutable stakingToken; //stakingToken = kullanıcıların yatıracakları token.
    IERC20 public immutable rewardsToken; //rewardsToken = stake edenlere dağıtılacak ödül token'i.

    address public owner; //issue #1
    uint constant public rewardPerToken = 1;
    uint public totalStakedTokens = 0;


    mapping(address => uint) public balanceOf;
    mapping(address => uint) public durations;
    mapping(address => uint) public rewards;
    mapping(address => uint) public releaseTime;
    // issue #4 possible additions
        uint public lockupPeriod = 210 days; // lockup period (7 mounths)
        //issue #11-19-20
        uint public bonusPercentage = 15; // %15 bonus for completing lockup


        event Staked(address indexed user, uint256 amount);
            event Claimed(address indexed user, uint256 amount);

    /*
    • lockupPeriod:
    kilitleme süresini takip eden
    bir state variable (durum değişkeni) ekledim.
    varsayılan olarak 210 güne ayarladım ama bu değişebilir.
    */

    // Bu periyotlar 3 farklı kilit versiyonu şeklinde olmalı.

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    modifier updateReward(address _account) {
        rewards[_account] += calculateReward(_account);
        durations[_account] = block.timestamp;
                emit Claimed(_account, rewards[_account]); // Emitting event for dashboard
        _;
    }
  //issue #3
    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can call");
        _;
    }
    /*
    old version of calculateReward
     function calculateReward(address _account) view internal returns(uint) {
         uint durationInSeconds = block.timestamp - durations[_account];
         uint rewardAmount = balanceOf[_account] * durationInSeconds * rewardPerToken;
         return rewardAmount;
     } //rewardAmount = balanceOf[_account] * durationInSeconds * rewardPerToken

     */
    // issue #24 - updated calculateReward
    // Modified calculateReward to consider total staked tokens
    function calculateReward(address _account) public view returns(uint) {
        uint total = totalStaked();
        if (total == 0) {
            return 0;
        }
        uint userShare = balanceOf[_account]; // User's staked tokens
        uint durationInSeconds = block.timestamp - durations[_account];
        uint rewardAmount = (userShare / total) * durationInSeconds * rewardPerToken;
        return rewardAmount;
    }

    function stake(uint _amount) external updateReward(msg.sender){
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] += _amount;
        totalStakedTokens += _amount; // Update total staked tokens , issue #24
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        //issue #4
        // • update release time based on lockup period
        releaseTime[msg.sender] = block.timestamp + lockupPeriod;
                emit Staked(msg.sender, _amount); // Emitting event for dashboard
        /*
    • releaseTime:
    her kullanıcı için ayrı ayrı token'ların kilidini açabilmek için zamanı takip eder.
        */
    }
    // New function to calculate the total staked tokens
    function totalStaked() public view returns(uint) {
        return totalStakedTokens;
    }
    // issue #4 updated
    function withdraw(uint _amount) external updateReward(msg.sender){
        require(_amount > 0, "amount = 0");
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        require(block.timestamp >= releaseTime[msg.sender], "Tokens are locked");
            //issue #6-7-8
            uint penalty = calculatePenalty(_amount);
            uint amountAfterPenalty = _amount - penalty;
        totalStakedTokens -= _amount; // Update total staked tokens
        balanceOf[msg.sender] -= _amount;
        //issue #11-19-20

        // 📍 apply bonus if lockup period is over (kontrol edilmeli !?!?!)

        if (block.timestamp >= releaseTime[msg.sender]) {
                        uint bonus = amountAfterPenalty * bonusPercentage / 100;
            amountAfterPenalty += bonus;
        }

        stakingToken.transfer(msg.sender, amountAfterPenalty); // transfer after deducting penalty
        stakingToken.transfer(owner, penalty); // transfer penalty to owner
                emit Claimed(msg.sender, amountAfterPenalty); // Emitting event for dashboard
    }
    function totalStaked() public view returns(uint) {
            return totalStakedTokens;
        }


    function calculatePenalty(uint _amount) public view returns(uint) {
            uint timeElapsed = block.timestamp - releaseTime[msg.sender];
        if (timeElapsed < lockupPeriod) {
            uint oneMonth = lockupPeriod / 7;
            if (timeElapsed < oneMonth) {
                return (_amount * 30) / 100; // 30% penalty for withdrawal within first month
            } else if (timeElapsed < 3 * oneMonth) {
                return (_amount * 20) / 100; // 20% penalty for withdrawal within 1-3 months
            } else {
                return (_amount * 10) / 100; // 10% penalty for withdrawal within 3-6 months
            }
        }

        else {
            return 0; // No penalty after lockup period ends
        }

    }

                /*
        function _burn(uint _amount) internal {
            stakingToken.transfer(address(0x0), _amount);
        }
            */


    //gas yeterliliği
    function requireSufficientGas(uint _gasLimit, uint _gasPrice) external view {
        require(gasleft() >= _gasLimit, "Insufficient gas limit");
        require(tx.gasprice <= _gasPrice, "Gas price is too high");
    }

    //ödül miktarı güncelleme: negatif olmamalı, bakiye sıfır olmamalı
    function updateSecurityReward(address _account) internal {
    uint calculatedReward = calculateReward(_account);
        require(calculatedReward >= 0, "Invalid reward amount");
        require(balanceOf[_account] >= 0, "Invalid balance");
        rewards[_account] = calculatedReward;
    }

    /*
function _burn(uint _amount) internal {
   stakingToken.transfer(address(0x0), _amount);
   */

    //kilit bozma öncesi kimlik doğrulama
    function requireConfirmation(uint _amount) external pure {
        uint confirmationThreshold = 100; //100 değeri değişecek, eşik
        require(_amount >= confirmationThreshold, "Confirmation threshold not met");
    }

    function getReward() external updateReward(msg.sender){
        uint reward = rewards[msg.sender];
        require(reward > 0, "You dont have rewards");
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
                emit Claimed(msg.sender, reward); // Emitting event for dashboard
    }
    //issue #3-4
    // • function to adjust staking balance (only callable by the owner)
    function adjustStakingBalance(address _account, uint _newBalance) external onlyOwner {
        balanceOf[_account] = _newBalance;
                emit Staked(_account, _newBalance); // Emitting event for dashboard
    }
    // issue #4
    // • function to set the lockup period
    function setLockupPeriod(uint _newLockupPeriod) external onlyOwner {
        lockupPeriod = _newLockupPeriod;
    }

    function setBonusPercentage(uint _newBonusPercentage) external onlyOwner {
        bonusPercentage = _newBonusPercentage;
    } //Kontrol edilmeli !?!?!?!?!??!?

    // • function to get remaining lockup time for a user
    function getRemainingLockupTime(address _account) public view returns(uint) {
        // kullanıcının token'larının kilidini açmak için ne kadar süre kaldığını gösteren yardımcı bir fonksiyon, dashboard için önemli.
        if (releaseTime[_account] <= block.timestamp) {
            return 0;
        } else {
            return releaseTime[_account] - block.timestamp;
        }
    }
}
