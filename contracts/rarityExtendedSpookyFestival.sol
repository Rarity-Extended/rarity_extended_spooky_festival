// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IRarity.sol";
import "./interfaces/IrERC20.sol";
import "./interfaces/IAttributes.sol";
import "./interfaces/IRandomCodex.sol";
import "./onlyExtended.sol";

contract rarity_extended_spooky_festival is OnlyExtended {
    uint constant DAY = 1 days;
    string public constant name = "Rarity Extended Spooky Festival";
    string public constant symbol = "rSpook";
    uint256 public constant GIFT_CANDIES = 100;
    uint public immutable SUMMMONER_ID;
    uint public end_halloween_ts = 0;

    IRarity constant _rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IRandomCodex constant _random = IRandomCodex(0x7426dBE5207C2b5DaC57d8e55F0959fcD99661D4);
    attributes constant _attributes = attributes(0xB5F5AF1087A8DA62A23b08C00C6ec9af21F397a1);
    IrERC20 public candies;

    mapping(uint => bool) public claimed;
    mapping(uint => uint) public trick_or_treat_count;
    mapping(uint => uint) public trick_or_treat_log;
    mapping(uint => uint) public activities_count;
    mapping(uint => uint) public activities_log;

    constructor(address _candiesAddr) OnlyExtended() {
        candies = IrERC20(_candiesAddr);
        SUMMMONER_ID = _rm.next_summoner();
        _rm.summon(11);
        end_halloween_ts = block.timestamp + (7 * DAY);
    }

    modifier can_do_activities(uint _summoner) {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(block.timestamp > activities_log[_summoner], "!activities");
    
        activities_count[_summoner] += 1;
        if (activities_count[_summoner] == 2) {
            //Two activities per day
            activities_log[_summoner] = block.timestamp + DAY;
            activities_count[_summoner] = 0;
        }
        _;
    }

    modifier is_halloween() {
        require(block.timestamp < end_halloween_ts, "!halloween");
        _;
    }

    function claim(uint _summoner) external is_halloween {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(claimed[_summoner] == false, "claimed");
        claimed[_summoner] = true;
        candies.mint(_summoner, GIFT_CANDIES);
    }

    function trick_or_treat(uint _summoner, uint256 _amount, uint _choice) external is_halloween {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(_amount == 25 || _amount == 50 || _amount == 100, "!invalidAmount");
        require(candies.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, _amount), "!amount");
        require(block.timestamp > trick_or_treat_log[_summoner], "!action");
        require(_choice == 1 || _choice == 2 || _choice == 3, "!choice");
    
        trick_or_treat_count[_summoner] += 1;
        if (trick_or_treat_count[_summoner] == 3) {
           trick_or_treat_log[_summoner] = block.timestamp + DAY;
           trick_or_treat_count[_summoner] = 0;
        }

        uint random = _get_random(_summoner, 3, false);
        if (random == _choice) {
            candies.burn(SUMMMONER_ID, _amount);
            candies.mint(_summoner, _amount * 3);
        } else {
            candies.burn(SUMMMONER_ID, _amount);
        }
    }

    function throw_a_rock(uint _summoner) external is_halloween can_do_activities(_summoner) {
        //Look for strenght
        (uint str,,,,,) = _attributes.ability_scores(_summoner);
        candies.mint(_summoner, str);
    }

    function steal_a_pumpkin(uint _summoner) external is_halloween can_do_activities(_summoner) {
        //Look for dexterity
        (,uint dex,,,,) = _attributes.ability_scores(_summoner);
        candies.mint(_summoner, dex);
    }

    function tell_a_scary_story(uint _summoner) external is_halloween can_do_activities(_summoner) {
        //Look for charisma
        (,,,,,uint cha) = _attributes.ability_scores(_summoner);
        candies.mint(_summoner, cha);
    }

    function do_a_magic_trick(uint _summoner) external is_halloween can_do_activities(_summoner) {
        //Look for int
        (,,,uint inte,,) = _attributes.ability_scores(_summoner);
        candies.mint(_summoner, inte);
    }

    function cake_eating_contest(uint _summoner) external is_halloween can_do_activities(_summoner) {
        //Look for con
        (,,uint con,,,) = _attributes.ability_scores(_summoner);
        candies.mint(_summoner, con);
    }

    function do_some_babysitting(uint _summoner) external is_halloween can_do_activities(_summoner) {
        //Look for wisdom
        (,,,,uint wis,) = _attributes.ability_scores(_summoner);
        candies.mint(_summoner, wis);
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