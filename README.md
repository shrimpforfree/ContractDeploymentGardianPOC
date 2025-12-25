# ContractDeploymentGuardianPOC

Educational POC for a USPD-style deployment front-run: if an **initializable** contract is left **uninitialized**, an attacker can call `initialize()` first and seize admin/ownership. :contentReference[oaicite:0]{index=0}

## What this repo demonstrates
### 1) Vulnerable path (first-run-attacks)
`VulnerableInit` models the mistake:
- contract is deployed
- `initialize(admin)` is public
- whoever calls it first becomes `admin`

### 2) Guarded path (authorization-gated initialization)
A separate on-chain **Guardian** contract acts as an authorization layer:
- the guarded contract checks the Guardian before allowing `initialize()`
- being “first” no longer matters unless the caller is approved

## Roles (addresses)
- **A**: Guardian deployer (service admin)
- **B**: Customer who deploys their own contract
- **C**: Initializer address (the one allowed to call `initialize()`)
- **D**: Guardian contract address

Flow:
1. A deploys Guardian → address **D**
2. B deploys a guarded contract with params: `(guardian=D)`
3. B calls `Guardian.setApproved(C, true)` (scoped to B)
4. C calls `initialize()` on B’s contract and becomes its owner/admin

## How to run (Remix)
1. Open the repo as a Remix workspace (or copy `contracts/` into Remix).
2. Deploy `VulnerableInit`, try calling `initialize()` from an attacker account.
3. 
   - Account A (service) Deploy Guardian
   - Account B (customer) deploy guarded contract, then:
   - try `initialize()` from a non-approved account C (initializer) (should revert)
   - Account B approve C via Guardian
   - retry `initialize()` from account C (should succeed)
