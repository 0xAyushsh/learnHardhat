import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { assert, expect } from "chai"
import { ethers, deployments, network, getNamedAccounts } from "hardhat"
import { developmentChains } from "../../helper-hardhat-config"
import { Counter } from "../../typechain-types"

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Counter", function () {
          let counter: Counter
          let deployer

          beforeEach(async () => {
              
              deployer = await getNamedAccounts()

              //Deploying all the contracts using fixture method
              await deployments.fixture(["counter"])

              //Getting Counter contract using ethers.js
              counter = await ethers.getContract("Counter")
          })

          //increment
          //decrement
          it("increment function needs to increment the counter", async () => {
              let incrementTrx = await counter.increment()
              let count = await counter.getCount()
              console.log("Count: ", count)
              assert.equal(count, 1)
          })

          it("decrement function needs to decrement the counter", async () => {
              let incrementTrx = await counter.increment()
              let count1 = await counter.getCount()
              let decrementTrx = await counter.decrement()
              let count2 = await counter.getCount()

              assert.equal(count1, 1)
              assert.equal(count2, 0)
          })

          // Error Condition
          it("check for underflow error", async () => {
              await expect(counter.decrement()).to.be.revertedWithPanic
          })
      })