// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking {
    using SafeMath for uint256;
    uint256 amountToDistribute = 100;//tokens
    uint256 period = 3600;//seconds
    uint256 public totalStaked;
    struct Stake {
        uint256 amount;
        bytes data;
    }
    mapping(address => Stake) stakes;
    address[] public addressIndices;
    mapping(bytes => uint256) rewards;
    mapping(address => uint256) lastProfits;

    IERC20 public token;

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Reward(bytes data, uint256 total);

    constructor (IERC20 _token) public {
        token = _token;
    }

    function __transferToken(address _sender, address _recipient, uint256 _amount) private {
        token.transferFrom(_sender, _recipient, _amount);
    }

    function stake(uint256 amount, bytes memory data) public{
        stakes[msg.sender] = Stake(amount, data);
        addressIndices.push(msg.sender);
        totalStaked += amount;
        emit Staked(msg.sender, amount, totalStaked, data);
    }

    function totalStakedFor(address addr) public view returns (uint256) {
        return stakes[addr].amount;
    }

    function calculateAPY(address addr) public view returns (uint256) {
        uint profit = lastProfits[addr];
        uint amount = stakes[addr].amount - profit;
        return profit.mul(100).div(amount);
    }

    function reward(bytes memory data) public returns (int256) {
        _reward(data, amountToDistribute);
    }

    function _reward(bytes memory data, uint256 amountToDistribute) public returns (int256) {
        for(uint index=0; index<addressIndices.length; index++){
            address addr = addressIndices[index];
            uint profit = amountToDistribute * totalStakedFor(addr) / totalStaked;
            stakes[addr].amount+= profit;
            stakes[addr].data = data;
            lastProfits[addr] = profit;
        }
        totalStaked += amountToDistribute;
        rewards[data] = amountToDistribute;
        emit Reward(data, amountToDistribute);
    }
}