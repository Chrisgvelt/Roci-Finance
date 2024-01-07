const {expect} = require("chai");
const {ethers} = require('hardhat')

describe("NFT minter contract", () => {
    
    let deployer;
    let RociMinterContract;
    let rociMinterInstance;

    // That is, before each test run
    beforeEach(async () => {
        // Gets the contract bytecode/ initicode
        RociMinterContract = await ethers.getContractFactory("RociMinter");
        // Gets the accounts in the list of Eth accounts available
        // First account is the one being used to deploy
        // Signer is an object use to send tx; signer.address will give its address
        [deployer, addr1, addr2, ...addrs] = await ethers.getSigners();
        // Instantiates the contract and stores its address
        rociMinterInstance = await RociMinterContract.deploy("RociCreditToken", "RCT");
    });

    describe("Deployment", () => {
        // Check that it is equal to that of the deployer
        it("Should deploy the contract and set the right owner", async () => {
            expect(await rociMinterInstance.owner()).to.equal(deployer.address);
        })
    })

    describe("ERC721 Interface Support", () => {
        it("Should tell whether the ERC721 interface is supported or not", async () => {
            expect(await rociMinterInstance.supportsInterface("0x80ac58cd")).to.equal(true)
        })
    })

    describe("Name", () => {
        it("Should return the contract name as RociMinter", async () => {
            expect(await rociMinterInstance.name()).to.equal("RociCreditToken")
        })
    })
})