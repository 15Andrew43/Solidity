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
  let exchangeRate = 1000
  let limitSpends = 100000

  beforeEach(async function () {
    [owner, dev1, dev2, dev3, other_addr] = await ethers.getSigners();
    const Crowdsale = await ethers.getContractFactory("Crowdsale", owner);
    crowdsale = await Crowdsale.deploy();
    // console.log("\n\nTARGET\n\n", demo.target)
  });

  async function buyTokensByReceive(sender, amount) {
    const txData = {
      to: crowdsale.target,
      value: amount
    }
    const tx = await sender.sendTransaction(txData);
    await tx.wait();
    return tx
  }


  it("should allow to buy tokens", async function () {
    amount = 65000
    let buyTokensTx = await buyTokensByReceive(other_addr, amount)

    expect(await crowdsale.balanceOf(other_addr.address))
      .to.eq(Math.floor(amount / exchangeRate));


    buyTokensTx = await buyTokensByReceive(other_addr, amount)

    expect(await crowdsale.balanceOf(other_addr.address))
      .to.eq(Math.floor(limitSpends / exchangeRate)); // 100
  })

  it("should mint extra 10 percent tokens for developers", async function () {

    amount = limitSpends + 999
    let buyTokensTx = await buyTokensByReceive(other_addr, amount)

    expect(await crowdsale.balanceOf(other_addr.address))
      .to.eq(Math.floor(limitSpends / exchangeRate)); // 100

    await crowdsale.setDevelopersAddresses([dev1.address, dev2.address, dev3.address])


    expect(await crowdsale.developersAddresses(0))
      .to.eq(dev1.address)
    expect(await crowdsale.developersAddresses(1))
      .to.eq(dev2.address)
    expect(await crowdsale.developersAddresses(2))
      .to.eq(dev3.address)

    function sleep(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
    }
    await sleep(6000);

    expect(await crowdsale.balanceOf(dev1.address))
      .to.eq(Math.floor(Math.floor(Math.floor(limitSpends / exchangeRate) / 10) / 3)); // 100
  })

});
