async function main() {
    //Compile
    await hre.run("clean");
    await hre.run("compile");

    //Deploy candies
    this.Candies = await ethers.getContractFactory("Candies");
    this.candies = await this.Candies.deploy('0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb');
    await this.candies.deployed();
    console.log("Deployed candies to:", this.candies.address);

    //Deploy
    this.Contract = await ethers.getContractFactory("rarity_extended_spooky_festival");
    this.Contract = await this.Contract.deploy(this.candies.address);
    await this.Contract.deployed();
    console.log("Deployed to:", this.Contract.address);

    await (await this.candies.setMinter(this.Contract.address)).wait();
    console.log("Minter setted up successfully to:", this.Contract.address);

    await hre.run("verify:verify", {
		address: this.Contract.address,
		constructorArguments: [this.candies.address],
	});
    await hre.run("verify:verify", {
        address: this.candies.address,
        constructorArguments: ['0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'],
        contract: "contracts/candies.sol:Candies"
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });