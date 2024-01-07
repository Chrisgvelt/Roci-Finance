const {network, ethers} = require('hardhat')
const fs = require("fs");

// Script to deploy contracts to the local hardhat network and transfer contract files to the frontend
async function main() {
  if (network.name === "hardhat") {
    console.warn("Deploying contract to Hardhat Network");
  }

  // Get the deployer address from Hardhat node
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contract with account", await deployer.getAddress());

  // Show address balance
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  // Getting the contract bytecode or Factory
  const TokenStorage = await ethers.getContractFactory("TokenStorage");
  const tokenStorage = await TokenStorage.deploy();
  await tokenStorage.deployed();
  console.log("TokenStorage contract address:", tokenStorage.address);
  // Getting the contract bytecode or Factory
  const StoreToken = await ethers.getContractFactory("StoreToken");
  const storeToken = await StoreToken.deploy();
  await storeToken.deployed();
  console.log("StoreToken contract address:", storeToken.address);

  // Getting the contract bytecode or Factory
  const RociMinter = await ethers.getContractFactory("RociMinter");
  // Instantiating the contract
  // The deploy method of the contractFactory returns a promise that resolves to a contract object
  const rociMinter = await RociMinter.deploy("RociToken", "RTK");
  await rociMinter.deployed();
  console.log("RociMinter contract address:", rociMinter.address);

  saveFrontendFiles(rociMinter);
}

//Now, we must save the contract files (source, ABI, bytecode etc.) to the frontend dir as well
const saveFrontendFiles = (rociMinter) => {
  // Defining the dir where we want our contract files to be stored
  const contractsDir = __dirname + "/../frontend/src/contracts";
  // Existence check, create otherwise
  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }
  // Create a new JSON file (arg1) and put inside it the contract address (arg2)
  fs.writeFileSync(
    contractsDir + "/contract-address.json",
    JSON.stringify({ RociMinter: rociMinter.address }, undefined, 2)
  );
  // Get the AssetSync file from artifacts directory
  const RociMinterArtifact = artifacts.readArtifactSync("RociMinter");
  // Write its contents to RociMinter.json file in contractsDir
  fs.writeFileSync(contractsDir + "/RociMinter.json", JSON.stringify(RociMinterArtifact, null, 2));
};

//Calling the main function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
