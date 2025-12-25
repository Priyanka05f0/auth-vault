const hre = require("hardhat");

async function main() {
  const network = hre.network.name;
  console.log("Deploying to network:", network);

  // Deploy AuthorizationManager
  const AuthorizationManager = await hre.ethers.getContractFactory(
    "AuthorizationManager"
  );
  const authorizationManager = await AuthorizationManager.deploy();
  await authorizationManager.deployed();

  console.log(
    "AuthorizationManager deployed at:",
    authorizationManager.address
  );

  // Deploy SecureVault with AuthorizationManager address
  const SecureVault = await hre.ethers.getContractFactory("SecureVault");
  const secureVault = await SecureVault.deploy(
    authorizationManager.address
  );
  await secureVault.deployed();

  console.log("SecureVault deployed at:", secureVault.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
