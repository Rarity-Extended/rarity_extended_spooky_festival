// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRarity {
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function getApproved(uint256 tokenId) external view returns (address);
    function ownerOf(uint _summoner) external view returns (address);
}

contract rarity_extended_spooky_festival {
    IRarity constant _rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
   
}