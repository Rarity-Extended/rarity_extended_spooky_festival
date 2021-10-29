// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IRarity.sol";
import "./interfaces/IrERC20.sol";
import "./interfaces/IRandomCodex.sol";
import "./onlyExtended.sol";

contract rarity_extended_spooky_festival {
    uint constant DAY = 1 days;
    string public constant name = "Rarity Extended Spooky Festival";
    string public constant symbol = "rSpook";
    uint256 public constant GIFT_CANDIES = 100e18;
    uint8 public constant decimals = 18;
    uint public totalSupply = 0;
    uint public immutable SUMMMONER_ID;

    IRarity constant _rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IrERC20 public candies;

    mapping(uint => bool) public claimed;
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
        require(_amount == 25 || _amount == 50 || _amount == 100, "!invalidAmount");
        require(candies.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, _amount), "!amount");
        
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
            allowance[msg.sender][_summoner] == true
        );
    }

    function _get_random(uint _summoner, uint limit, bool withZero) public view returns (uint) {
        _summoner += gasleft();
        uint result = 0;
        if (withZero) {
            result = random.dn(_summoner, limit);
        }else{
            if (limit == 1) {
                return 1;
            }
            result = random.dn(_summoner, limit);
            result += 1;
        }
        return result;
    }
}