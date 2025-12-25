const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Authorization-Governed Vault System", function () {
  let authorizationManager;
  let secureVault;
  let owner, recipient;

  beforeEach(async function () {
    [owner, recipient] = await ethers.getSigners();

    // Deploy AuthorizationManager
    const AuthorizationManager = await ethers.getContractFactory(
      "AuthorizationManager"
    );
    authorizationManager = await AuthorizationManager.deploy();
    await authorizationManager.waitForDeployment();

    // Deploy SecureVault
    const SecureVault = await ethers.getContractFactory("SecureVault");
    secureVault = await SecureVault.deploy(
      authorizationManager.target
    );
    await secureVault.waitForDeployment();
  });

  it("allows withdrawal with a valid authorization", async function () {
    // Deposit ETH into vault
    await owner.sendTransaction({
      to: secureVault.target,
      value: ethers.parseEther("1"),
    });

    const authId = ethers.keccak256(
      ethers.toUtf8Bytes("unique-auth-1")
    );

    // Withdraw with authorization
    await expect(
      secureVault.withdraw(
        recipient.address,
        ethers.parseEther("0.5"),
        authId,
        "0x"
      )
    ).to.not.be.reverted;
  });

  it("prevents reuse of the same authorization", async function () {
    // Deposit ETH into vault
    await owner.sendTransaction({
      to: secureVault.target,
      value: ethers.parseEther("1"),
    });

    const authId = ethers.keccak256(
      ethers.toUtf8Bytes("unique-auth-2")
    );

    // First withdrawal succeeds
    await secureVault.withdraw(
      recipient.address,
      ethers.parseEther("0.5"),
      authId,
      "0x"
    );

    // Second withdrawal with same authId fails
    await expect(
      secureVault.withdraw(
        recipient.address,
        ethers.parseEther("0.5"),
        authId,
        "0x"
      )
    ).to.be.revertedWith("Authorization already used");
  });
});
