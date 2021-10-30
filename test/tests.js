require("dotenv").config();
const { expect, use } = require('chai');
const { solidity } = require('ethereum-waffle');
const { deployments, ethers } = require('hardhat');
const RarityExtendedSpookyFestival = artifacts.require("rarity_extended_spooky_festival");
const Candies = artifacts.require("Candies");

use(solidity);

const RARITY_ADDRESS = '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'
let RARITY;
const ATTRIBUTES_ADDRESS = '0xb5f5af1087a8da62a23b08c00c6ec9af21f397a1'
let ATTRIBUTES;

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

		ATTRIBUTES = new ethers.Contract(ATTRIBUTES_ADDRESS, [
			'function point_buy(uint _summoner, uint32 _str, uint32 _dex, uint32 _const, uint32 _int, uint32 _wis, uint32 _cha) external',
			'function character_created(uint) external view returns (bool)'
		], user);

		candies = await Candies.new(RARITY_ADDRESS)
		rarityExtendedSpookyFestival = await RarityExtendedSpookyFestival.new(candies.address)
		await candies.setMinter(rarityExtendedSpookyFestival.address)
		SUMMMONER_ID = await rarityExtendedSpookyFestival.SUMMMONER_ID();

		nextAdventurer = Number(await RARITY.next_summoner());
		await (await RARITY.summon(1)).wait();

		// await ATTRIBUTES.point_buy(nextAdventurer, 8, 8, 8, 8, 8, 8);
	});

	it('should be possible to claim candies', async function () {
		await rarityExtendedSpookyFestival.claim(nextAdventurer);
		await expect(rarityExtendedSpookyFestival.claim(nextAdventurer)).to.be.revertedWith("claimed");
	});

	it('should be possible to trick or treat', async function () {
		await candies.approve(nextAdventurer, SUMMMONER_ID, ethers.utils.parseUnits("100000"));
		await expect(rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, 10, 1)).to.be.revertedWith("!invalidAmount");
		await rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, 25, 1);
		await rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, 25, 1);
		await rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, 25, 1);
		await expect(rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, 25, 1)).to.be.revertedWith("!action");
	});

	it('should be possible to throw a rock', async function () {
		await rarityExtendedSpookyFestival.throw_a_rock(nextAdventurer);
	});

	it('should be possible to steal a pumpkin', async function () {
		await rarityExtendedSpookyFestival.steal_a_pumpkin(nextAdventurer);
	});

	it('should be possible to tell a scary story', async function () {
		await network.provider.send("evm_increaseTime", [86400]); //1 day
		await network.provider.send("evm_mine");
		await rarityExtendedSpookyFestival.tell_a_scary_story(nextAdventurer);
	});

	it('should be possible to do a magic trick', async function () {
		await rarityExtendedSpookyFestival.do_a_magic_trick(nextAdventurer);
	});

	it('should be possible to participate in candy eating contest', async function () {
		await network.provider.send("evm_increaseTime", [86400]); //1 day
		await network.provider.send("evm_mine");
		await rarityExtendedSpookyFestival.cake_eating_contest(nextAdventurer);
	});

	it('should be possible to do some babysitting', async function () {
		await rarityExtendedSpookyFestival.do_some_babysitting(nextAdventurer);
	});

	it('should not be possible to do something, because halloween ended', async function () {
		await network.provider.send("evm_increaseTime", [604800]); //1 week
		await expect(rarityExtendedSpookyFestival.trick_or_treat(nextAdventurer, 25, 1)).to.be.revertedWith("!halloween");
		await expect(rarityExtendedSpookyFestival.claim(nextAdventurer)).to.be.revertedWith("!halloween");
		await expect(rarityExtendedSpookyFestival.throw_a_rock(nextAdventurer)).to.be.revertedWith("!halloween");
	});

});