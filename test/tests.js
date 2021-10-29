require("dotenv").config();
const { expect, use } = require('chai');
const { solidity } = require('ethereum-waffle');
const { deployments, ethers } = require('hardhat');
const RarityExtendedSpookyFestival = artifacts.require("rarity_extended_spooky_festival");
const Candies = artifacts.require("Candies");

use(solidity);

const RARITY_ADDRESS = '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'
let RARITY;

describe('Tests', () => {
	let rarityExtendedSpookyFestival;
	let candies;
	let user;
	let nextAdventurer;
	let SUMMMONER_ID;

	before(async () => {
		await deployments.fixture();
		[user, anotherUser] = await ethers.getSigners();
		RARITY = new ethers.Contract(RARITY_ADDRESS, [
			'function next_summoner() public view returns (uint)',
			'function summon(uint _class) external',
			'function setApprovalForAll(address operator, bool _approved) external',
		], user);

		candies = await Candies.new(RARITY_ADDRESS)
		rarityExtendedSpookyFestival = await RarityExtendedSpookyFestival.new(candies.address)
		await candies.setMinter(rarityExtendedSpookyFestival.address)
		SUMMMONER_ID = await rarityExtendedSpookyFestival.SUMMMONER_ID();

		nextAdventurer = Number(await RARITY.next_summoner());
		await	(await RARITY.summon(1)).wait();
	});

	it('should be possible to claim candies', async function () {
		await rarityExtendedSpookyFestival.claim(nextAdventurer);
		await expect(rarityExtendedSpookyFestival.claim(nextAdventurer)).to.be.revertedWith("claimed");
	});

	it('should be possible to trick or treat', async function () {
		await candies.approve(nextAdventurer, SUMMMONER_ID, ethers.utils.parseUnits("100000"));
		await expect(rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, ethers.utils.parseUnits("10"))).to.be.revertedWith("!invalidAmount");
		await rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, ethers.utils.parseUnits("25"));
		await rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, ethers.utils.parseUnits("25"));
		await rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, ethers.utils.parseUnits("25"));
		await expect(rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, ethers.utils.parseUnits("25"))).to.be.revertedWith("!action");
	});

	it('should be possible to throw a rock', async function () {

	});

	it('should be possible to steal a pumpkin', async function () {

	});

	it('should be possible to tell a scary story', async function () {

	});

	it('should be possible to do a magic trick', async function () {

	});

	it('should be possible to participate in candy eating contest', async function () {

	});

	it('should be possible to do some babysitting', async function () {

	});

});