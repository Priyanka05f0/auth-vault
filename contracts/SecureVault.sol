// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuthorizationManager {
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external returns (bool);
}

/*
 * Holds pooled funds and executes withdrawals
 */
contract SecureVault {

    // Reference to AuthorizationManager
    IAuthorizationManager public authorizationManager;

    // Internal accounting of total balance
    uint256 public totalBalance;

    // Events
    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount, bytes32 authId);

    constructor(address _authorizationManager) {
        authorizationManager = IAuthorizationManager(_authorizationManager);
    }

    /*
     * Accept deposits
     */
    receive() external payable {
        require(msg.value > 0, "No value sent");

        totalBalance += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    /*
     * Withdraw funds after authorization
     */
    function withdraw(
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external {

        // Request authorization validation
        bool allowed = authorizationManager.verifyAuthorization(
            address(this),
            recipient,
            amount,
            authId,
            signature
        );

        require(allowed, "Authorization failed");
        require(amount <= totalBalance, "Insufficient vault balance");

        // Update internal accounting BEFORE transfer
        totalBalance -= amount;

        // Transfer funds
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawal(recipient, amount, authId);
    }
}
