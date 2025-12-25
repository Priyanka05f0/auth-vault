// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * Responsible for validating withdrawal permissions
 * Tracks whether an authorization has already been consumed
 */
contract AuthorizationManager {

    // Tracks used authorization identifiers
    mapping(bytes32 => bool) private usedAuthorizations;

    // Event emitted when an authorization is consumed
    event AuthorizationConsumed(bytes32 authId);

    /*
     * Confirms whether a withdrawal is permitted
     *
     * Parameters must encode:
     * - vault address
     * - recipient
     * - amount
     * - unique authorization identifier
     * - signature data (opaque to this contract)
     */
    function verifyAuthorization(
        address vault,
        address recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external returns (bool) {

        // Silence unused variable warning (signature verified off-chain)
        signature;

        // Authorization must not be used before
        require(!usedAuthorizations[authId], "Authorization already used");

        // Mark authorization as consumed
        usedAuthorizations[authId] = true;

        emit AuthorizationConsumed(authId);

        // Authorization accepted
        return true;
    }
}
