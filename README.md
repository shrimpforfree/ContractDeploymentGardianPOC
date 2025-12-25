# ContractDeploymentGuardianPOC

Educational POC for a USPD-style deployment front-run: if an **initializable** contract is left **uninitialized**, an attacker can call `initialize()` first and seize admin/ownership.

## What this repo demonstrates
### 1) Vulnerable path (first-caller-wins)
`VulnerableInit` models the mistake:
- contract is deployed
- `initialize(admin)` is public
- whoever calls it first becomes `admin`

### 2) Guarded path (multi-tenant authorization-gated initialization)
A decentralized on-chain **MultiTenantGuardian** contract acts as an authorization layer:
- **No centralized owner**: each customer manages their own approvals
- the guarded contract checks the Guardian before allowing `initialize()`
- being "first" no longer matters unless the caller is approved by the specific customer
- compromise of one customer's key only affects that customer, not everyone

## Architecture (v2 - Multi-Tenant)
- **MultiTenantGuardian.sol**: Decentralized guardian with per-customer approvals
- **MultiTenantGuardedInit.sol**: Initializable contract that requires guardian approval
  - Constructor takes only guardian address
  - Deployer automatically becomes the customer who controls approvals
- Each customer controls who can initialize their own contracts independently

## Demo Flow
### Roles
- **Alice**: Customer who deploys her own contracts
- **Bob**: Another customer who deploys his own contracts
- **AliceInitializer**: Address approved by Alice to initialize her contracts
- **BobInitializer**: Address approved by Bob to initialize his contracts
- **Attacker**: Unauthorized address attempting to front-run

### Steps
1. **Anyone** deploys `MultiTenantGuardian` → address **G**
2. **Alice** deploys `MultiTenantGuardedInit(guardian=G)` (Alice becomes customer automatically)
3. **Bob** deploys `MultiTenantGuardedInit(guardian=G)` (Bob becomes customer automatically)
4. **Alice** calls `G.setApproved(AliceInitializer, true)`
5. **Bob** calls `G.setApproved(BobInitializer, true)`
6. **AliceInitializer** can initialize Alice's contracts (approved)
7. **BobInitializer** can initialize Bob's contracts (approved)
8. **Attacker** cannot initialize either contract (not approved by Alice or Bob)

## How to run (Remix)
1. Open the repo as a Remix workspace (or copy `contracts/` into Remix).
2. **Test vulnerable path**:
   - Deploy `VulnerableInit` from any account
   - Call `initialize()` from an attacker account (succeeds - demonstrates the vulnerability)
3. **Test guarded path**:
   - Deploy `MultiTenantGuardian` (any account)
   - Switch to Alice's account, deploy `MultiTenantGuardedInit(guardianAddress)`
   - Try `initialize()` from attacker account (should revert: NOT_APPROVED)
   - From Alice's account, call `guardian.setApproved(initializerAddress, true)`
   - Retry `initialize()` from approved initializer account (should succeed)
