// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DeploymentGuardian.sol";

/**
 * @title GuardedInit
 * @notice PROTECTED: Only guardian-approved addresses can initialize
 * @dev Educational POC - demonstrates defense against front-running via authorization
 *
 * PROTECTION MECHANISM:
 * 1. Guardian is set at DEPLOYMENT (immutable, can't be changed)
 * 2. Guardian must be YOUR DeploymentGuardian (passed to constructor)
 * 3. Attacker CANNOT pass their own malicious guardian
 * 4. Only guardian-approved addresses can successfully call initialize
 * 5. Even if attacker calls first, they are NOT approved → transaction reverts
 *
 * This replaces "first caller wins" with "only approved caller wins"
 *
 * IMMUTABLE GUARDIAN:
 * - Guardian address is set ONCE in constructor (immutable keyword)
 * - Stored in bytecode, not storage (works with many proxy patterns)
 * - Cannot be changed or front-run after deployment
 */
contract GuardedInit {

    // STATE VARIABLES
    bool public initialized;
    address public admin;
    DeploymentGuardian public immutable guardian;  // ← IMMUTABLE: Set at deployment, can't change

    // EVENTS
    event Initialized(address indexed admin, address indexed caller);

    /**
     * @notice Constructor sets the guardian contract (IMMUTABLE)
     * @param _guardian Address of the DeploymentGuardian contract
     * @dev Guardian is set ONCE at deployment and cannot be changed
     *
     * What this protects:
     * - Guardian set by deployer, not by initializer
     * - Attacker cannot pass their own malicious guardian
     * - require(_guardian != address(0)) prevents zero address guardian
     */
    constructor(address _guardian) {
        require(_guardian != address(0), "GUARDIAN_ZERO");
        guardian = DeploymentGuardian(_guardian);
    }

    /**
     * @notice Initialize the contract and set admin (PROTECTED VERSION)
     * @param _admin Address to become the admin
     * @dev Only guardian-approved addresses can call this successfully
     *
     * What this protects:
     * - require(!initialized) prevents re-initialization
     * - require(_admin != address(0)) prevents setting admin to zero address
     * - require(guardian.approvedInitializers(msg.sender)) prevents unauthorized initialization
     *
     * This is the key defense: even if an attacker calls first, they will hit
     * the "NOT_APPROVED" revert unless they are in the guardian's allowlist.
     * The guardian is immutable and set by the deployer, so attacker can't use their own guardian.
     */
    function initialize(address _admin) external {
        require(!initialized, "ALREADY_INITIALIZED");
        require(_admin != address(0), "ADMIN_ZERO");
        require(guardian.approvedInitializers(msg.sender), "NOT_APPROVED");

        admin = _admin;
        initialized = true;

        emit Initialized(_admin, msg.sender);
    }

    /**
     * @notice Example admin-only function (just to show the impact)
     * @dev In a real contract, admin could control critical functions
     */
    function adminOnlyFunction() external view returns (string memory) {
        require(msg.sender == admin, "NOT_ADMIN");
        return "You are the admin!";
    }
}
