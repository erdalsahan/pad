// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSale {
    IERC20 public token;
    uint256 public pricePrivatesale;
    uint256 public pricePublicsale;
    uint256 public minimumBuyPrivatesale;
    uint256 public maximumBuyPrivatesale;
    uint256 public startTimePrivatesale;
    uint256 public endTimePrivatesale;
    uint256 public startTimePublicsale;
    uint256 public endTimePublicsale;
    uint256 public raisedAmount;
    mapping(address => bool) public whitelist;

    constructor(
        address _token,
        uint256 _pricePrivatesale,
        uint256 _pricePublicsale,
        uint256 _minimumBuyPrivatesale,
        uint256 _maximumBuyPrivatesale,
        uint256 _startTimePrivatesale,
        uint256 _endTimePrivatesale,
        uint256 _startTimePublicsale,
        uint256 _endTimePublicsale
    ) {
        token = IERC20(_token);
        pricePrivatesale = _pricePrivatesale;
        pricePublicsale = _pricePublicsale;
        minimumBuyPrivatesale = _minimumBuyPrivatesale;
        maximumBuyPrivatesale = _maximumBuyPrivatesale;
        startTimePrivatesale = _startTimePrivatesale;
        endTimePrivatesale = _endTimePrivatesale;
        startTimePublicsale = _startTimePublicsale;
        endTimePublicsale = _endTimePublicsale;
    }

    function buyPrivatesale(uint256 amount) public {
        require(
            block.timestamp >= startTimePrivatesale && block.timestamp <= endTimePrivatesale,
            "Privatesale is not active"
        );
        require(whitelist[msg.sender], "Address is not whitelisted");
        require(amount >= minimumBuyPrivatesale, "Minimum buy amount not met");
        require(amount <= maximumBuyPrivatesale, "Maximum buy amount exceeded");
