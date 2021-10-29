// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IRarity.sol";
import "./interfaces/IrERC20.sol";
import "./interfaces/IRandomCodex.sol";
import "./onlyExtended.sol";

contract rarity_extended_spooky_festival is OnlyExtended {
    uint constant DAY = 1 days;
    string public constant name = "Rarity Extended Spooky Festival";
    string public constant symbol = "rSpook";
    uint256 public constant GIFT_CANDIES = 100e18;
    uint public immutable SUMMMONER_ID;

    IRarity constant _rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IRandomCodex constant _random = IRandomCodex(0x7426dBE5207C2b5DaC57d8e55F0959fcD99661D4);
    IrERC20 public candies;

    mapping(uint => bool) public claimed;
    mapping(uint => uint) public actions_count;
    mapping(uint => uint) public actions_log;

    constructor(address _candiesAddr) OnlyExtended() {
        candies = IrERC20(_candiesAddr);
        SUMMMONER_ID = _rm.next_summoner();
        _rm.summon(11);
    }

    function claim(uint _summoner) external {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(claimed[_summoner] == false, "claimed");
        claimed[_summoner] = true;
        candies.mint(_summoner, GIFT_CANDIES);
    }

    function trick_or_treat(uint _summoner, uint256 _amount) external {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(_amount == 25e18 || _amount == 50e18 || _amount == 100e18, "!invalidAmount");
        require(candies.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, _amount), "!amount");
        require(block.timestamp > actions_log[_summoner], "!action");
    
        actions_count[_summoner] += 1;
        if (actions_count[_summoner] == 3) {
           actions_log[_summoner] = block.timestamp + DAY;
           actions_count[_summoner] = 0;
        }

        uint random = _get_random(_summoner, 100, false);
        if (random <= 50) {
            candies.burn(SUMMMONER_ID, _amount);
        } else {
            candies.burn(SUMMMONER_ID, _amount);
            candies.mint(_summoner, _amount * 2);
        }
    }

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return (
            _rm.getApproved(_summoner) == msg.sender ||
            _rm.ownerOf(_summoner) == msg.sender ||
            _rm.isApprovedForAll(_rm.ownerOf(_summoner), msg.sender)
        );
    }

    function _get_random(uint _summoner, uint limit, bool withZero) public view returns (uint) {
        _summoner += gasleft();
        uint result = 0;
        if (withZero) {
            result = _random.dn(_summoner, limit);
        }else{
            if (limit == 1) {
                return 1;
            }
            result = _random.dn(_summoner, limit);
            result += 1;
        }
        return result;
    }
}