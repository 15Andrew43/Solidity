const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Crowdsale", function () {
  let owner
  let dev1, dev2, dev3
  let other_addr
  let exchangeRate = 1000;

  beforeEach(async function () {
    [owner, dev1, dev2, dev3, other_addr] = await ethers.getSigners();
    const Crowdsale = await ethers.getContractFactory("Crowdsale", owner);
    crowdsale = await Crowdsale.deploy();
    // console.log("\n\nTARGET\n\n", demo.target)
  });

  async function buyTokens(sender) {
    const amount = 6000;
    const txData = {
      to: crowdsale.target,
      value: amount
    }
    const tx = await sender.sendTransaction(txData);
    await tx.wait();
    return [tx, amount]
  }


  it("should allow to buy tokens", async function () {
    const [buyTokensTx, amount] = await buyTokens(other_addr)
    // console.log(sendMoneyTx)

    await expect(() => buyTokensTx)
      .to.changeEtherBalance(other_addr, -amount, { includeFee: true });

    await expect(() => crowdsale.balanceOf(other_addr.address))
      .to.eq(amount / 1000);


    // const timestamp = (
    //   await ethers.provider.getBlock(sendMoneyTx.blockNumber)
    // ).timestamp
    // console.log(await ethers.provider.getBlock(sendMoneyTx.blockNumber))
    // console.log("\n\nTRANSACTION\n\n", sendMoneyTx)

    // await expect(sendMoneyTx)
    //   .to.emit(demo, "Paid")
    //   .withArgs(other_addr.address, amount, timestamp)
  })

  // it("should allow owner to withdraw funds", async function () {
  //   const [_, amount] = await sendMoney(other_addr)
  //   // console.log("\n\nBALANCE:\n", await ethers.provider.getBalance(demo.target))

  //   const tx = await demo.withdraw(owner)
  //   // console.log("\n\nTX\n\n", tx)

  //   await expect(() => tx)
  //     .to.changeEtherBalances([demo, owner], [-amount, amount])
  // })

  // it("should not allw other accounts to withdrat funds", async function () {
  //   await sendMoney(other_addr)

  //   await expect(
  //     demo.connect(other_addr).withdraw(other_addr.address)
  //   ).to.be.revertedWith("you are not an owner")
  // })

});
