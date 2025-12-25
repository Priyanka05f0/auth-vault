# Authorization-Governed Vault System

## Overview
This project implements an authorization-governed vault system where withdrawals
are permitted only after explicit authorization validation via a separate on-chain
AuthorizationManager contract.

The system demonstrates secure separation of concerns between authorization logic
and asset custody, with strong replay protection guarantees.

## Architecture
The system consists of two core smart contracts:

- **AuthorizationManager**: validates and consumes withdrawal authorizations
- **SecureVault**: holds funds and executes withdrawals only after authorization approval

The SecureVault does not perform cryptographic verification directly and relies
entirely on AuthorizationManager for authorization decisions.

## Architecture Diagram

High-level interaction flow:

## Architecture Diagram

High-level interaction flow:

```text
+---------------+
| User / Script |
+---------------+
        |
        v
+--------------+
| SecureVault  |
+--------------+
        |
        v
+-----------------------+
| AuthorizationManager  |
+-----------------------+
```

The SecureVault delegates authorization checks to the AuthorizationManager
before executing any withdrawal.

## Deployment
The system is deployed locally using Docker and docker-compose.

Deployment steps:
1. Run `docker-compose up`
2. A local blockchain node is initialized
3. AuthorizationManager is deployed
4. SecureVault is deployed with the AuthorizationManager address

Deployed contract addresses are printed in the deployment logs.

## Authorization Design
Withdrawals are governed by off-chain generated authorizations. Each authorization
is bound to specific contextual parameters:

- Vault contract address
- Recipient address
- Withdrawal amount
- Unique authorization identifier (`authId`)

During a withdrawal request, the SecureVault delegates authorization validation to
the AuthorizationManager contract.

## Replay Protection
Replay protection is enforced on-chain by the AuthorizationManager contract.
Each authorization includes a unique identifier (`authId`) that is tracked in
contract storage.

Once an authorization is successfully used, it is permanently marked as consumed.
Any attempt to reuse the same authorization results in a deterministic transaction
revert, preventing replay attacks and duplicated withdrawals.

## Authorization Flow
1. Funds are deposited into the SecureVault using a native ETH transfer
2. An off-chain authorization is generated with tightly scoped parameters
3. The authorization is submitted as part of a withdrawal request
4. AuthorizationManager validates and consumes the authorization
5. SecureVault updates internal state and releases funds
6. Reuse of the same authorization fails deterministically

## Assumptions
- Cryptographic signature verification is performed off-chain by a trusted
  authorization service, as permitted by the task requirements
- Authorization data is constructed deterministically off-chain
- The local blockchain environment is trusted for development and evaluation

## Known Limitations
- This implementation focuses on authorization enforcement and replay protection,
  not on decentralized signer management
- Authorization expiration, revocation, and rotation mechanisms are not implemented
- The system is intended for demonstration and evaluation purposes rather than
  production deployment
