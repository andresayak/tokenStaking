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

    IERC20 public token;

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Reward(bytes data, uint256 total);

    constructor (IERC20 _token) public {
        token = _token;
    }
    /*
      * Internal Function for transferring tokens for staking.
      *
      * @remark Possibly spin this into the controller but for development, keep here
      * for convenience
      */
    function __transferToken(address _sender, address _recipient, uint256 _amount) private {
        // Allowance must be set
        token.transferFrom(_sender, _recipient, _amount);
    }
    /*
      * Stakes a certain amount of tokens, this MUST transfer the given amount from the user.
      */
    function stake(uint256 amount, bytes memory data) public{
        //__transferToken(msg.sender, address(this), amount);
        stakes[msg.sender] = Stake(amount, data);
        addressIndices.push(msg.sender);
        totalStaked += amount;
        emit Staked(msg.sender, amount, totalStaked, data);
    }
    /*
       * Returns the current total of tokens staked for an address.
       */
    function totalStakedFor(address addr) public view returns (uint256) {
        return stakes[addr].amount;
    }

    function calculateAPY(address addr) public view returns (int256) {

        return 8;
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
        }
        totalStaked += amountToDistribute;
        rewards[data] = amountToDistribute;
        emit Reward(data, amountToDistribute);
    }
}