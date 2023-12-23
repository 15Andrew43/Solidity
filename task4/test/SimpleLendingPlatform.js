const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

async function increaseTime(seconds) {
  await ethers.provider.send("evm_increaseTime", [seconds]);
  await ethers.provider.send("evm_mine", []);
}

describe("SimpleLendingPlatform", function () {


  beforeEach(async function () {
    [owner, supplyer, borrower] = await ethers.getSigners();
    const MyToken = await ethers.getContractFactory("MyToken", owner);
    const TokenForBorrowing = await ethers.getContractFactory("TokenForBorrowing", owner);
    myToken = await MyToken.deploy();
    tokenForBorrowing = await TokenForBorrowing.deploy();

    console.log("\n================ HELLO ===================\n");
    console.log(myToken);
    console.log("\n================ GOODBYE =================\n");

    const SimpleLendingPlatform = await ethers.getContractFactory("SimpleLendingPlatform", owner);
    simpleLendingPlatform = await SimpleLendingPlatform.deploy(myToken.target, tokenForBorrowing.target);

    console.log("\n================ HELLO ===================\n");
    console.log(simpleLendingPlatform);
    console.log("\n================ GOODBYE =================\n");



  });

  it("should allow the owner to mint tokens to users", async function () {
    const initialBalance = await myToken.balanceOf(supplyer.address);

    expect(initialBalance).to.equal(0);

    const amountToMint = 100;
    await myToken.mint(supplyer.address, amountToMint);

    const finalBalance = await myToken.balanceOf(supplyer.address);
    expect(finalBalance).to.equal(amountToMint);
  })

  it("should not allow non-owners to mint tokens", async function () {
    const amountToMint = 100;

    await expect(myToken.connect(supplyer).mint(borrower.address, amountToMint)).to.be.reverted;
  });


  it("should allow to deposit tokens", async function () {
    await myToken.mint(supplyer.address, 150);

    const amountToDeposit = 100;

    await myToken.connect(supplyer).approve(simpleLendingPlatform.target, amountToDeposit);

    await simpleLendingPlatform.connect(supplyer).deposit(amountToDeposit);

    const deposit = await simpleLendingPlatform.connect(supplyer).getDeposit();
    expect(deposit).to.equal(amountToDeposit);
  });


  it("should allow to set colloteral", async function () {
    await myToken.mint(supplyer.address, 150);

    const amountToDeposit = 100;

    await myToken.connect(supplyer).approve(simpleLendingPlatform.target, amountToDeposit);

    await simpleLendingPlatform.connect(supplyer).deposit(amountToDeposit);

    const deposit = await simpleLendingPlatform.connect(supplyer).getDeposit();
    expect(deposit).to.equal(amountToDeposit);

    const amountToColloteral = 50;
    await simpleLendingPlatform.connect(supplyer).setColloteral(amountToColloteral);
    expect(await simpleLendingPlatform.connect(supplyer).getColloteral()).to.equal(amountToColloteral);

  });


  it("should allow to borrow", async function () {
    await myToken.mint(supplyer.address, 150);
    const startAmount = await myToken.balanceOf(supplyer.address);

    const amountToDeposit = 100;

    await myToken.connect(supplyer).approve(simpleLendingPlatform.target, amountToDeposit);

    await simpleLendingPlatform.connect(supplyer).deposit(amountToDeposit);

    const deposit = await simpleLendingPlatform.connect(supplyer).getDeposit();
    expect(deposit).to.equal(amountToDeposit);

    const amountToColloteral = 50;
    await simpleLendingPlatform.connect(supplyer).setColloteral(amountToColloteral);
    expect(await simpleLendingPlatform.connect(supplyer).getColloteral()).to.equal(amountToColloteral);

    const collateralFactor = 75;
    const canBorrow = Math.floor(amountToColloteral * collateralFactor / 100);
    expect(await simpleLendingPlatform.connect(supplyer).amountCanBorrow()).to.be.equal(canBorrow);

    const amountToMintExchangedTokends = 100;
    await tokenForBorrowing.mint(simpleLendingPlatform.target, amountToMintExchangedTokends);
    expect(await tokenForBorrowing.balanceOf(simpleLendingPlatform.target)).to.be.equal(amountToMintExchangedTokends);
    await tokenForBorrowing.mint(supplyer.address, amountToMintExchangedTokends);
    expect(await tokenForBorrowing.balanceOf(supplyer.address)).to.be.equal(amountToMintExchangedTokends);

    await simpleLendingPlatform.connect(supplyer).borrowExchangedTokens(canBorrow);
    expect(await simpleLendingPlatform.connect(supplyer).borrowedTokens()).to.be.equal(canBorrow);


    await increaseTime(360 * 24 * 60 * 60);

    expect(await simpleLendingPlatform.connect(supplyer).getAmountToRepay()).to.be.equal(Math.floor(canBorrow * (1 + 10 / 100)));

    await increaseTime(360 * 24 * 60 * 60);

    expect(await simpleLendingPlatform.connect(supplyer).getAmountToRepay()).to.be.equal(Math.floor(canBorrow * (1 + 10 / 100) ** 2));

    await simpleLendingPlatform.connect(supplyer).repayDebt(await simpleLendingPlatform.connect(supplyer).getAmountToRepay());

    console.log('repay must be = ', await simpleLendingPlatform.connect(supplyer).getAmountToRepay());
    expect(await simpleLendingPlatform.connect(supplyer).getAmountToRepay()).to.be.equal(1);

    // await simpleLendingPlatform.connect(supplyer).setColloteral(0);
    // await simpleLendingPlatform.connect(supplyer).withdrawAllDdeposit();

    // expect(await myToken.balanceOf(supplyer.address)).to.be.greaterThan(startAmount);

  });

});
