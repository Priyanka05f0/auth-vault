# Authorization-Governed Vault System

## Overview
This project implements an authorization-governed vault system where withdrawals
are only allowed after explicit permission validation via a separate on-chain
AuthorizationManager contract.

## Architecture
- AuthorizationManager: validates and consumes withdrawal authorizations
- SecureVault: holds funds and executes withdrawals after authorization approval

## Deployment
The system is deployed locally using Docker and docker-compose.

Steps:
1. Run `docker-compose up`
2. A local blockchain node starts
3. AuthorizationManager is deployed
4. SecureVault is deployed with AuthorizationManager address

Deployed contract addresses are printed in the logs.

## Authorization Flow (Manual Validation)
1. Funds are deposited into the SecureVault using a native ETH transfer
2. An off-chain authorization is generated containing:
   - Vault address
   - Recipient address
   - Withdrawal amount
   - Unique authorization identifier
3. The authorization is submitted during withdrawal
4. AuthorizationManager validates and consumes the authorization
5. SecureVault releases funds to the recipient
6. Reusing the same authorization fails deterministically

## Security Guarantees
- Authorizations are single-use
- Vault balance never becomes negative
- State is updated before value transfer
- Unauthorized withdrawals revert
