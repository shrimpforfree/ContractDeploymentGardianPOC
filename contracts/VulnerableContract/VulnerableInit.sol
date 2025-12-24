// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VulnerableInit
 * @notice VULNERABLE: Anyone can call initialize() first and become admin
 * @dev Educational POC - demonstrates front-running attack on unprotected initialization
 *
 * ATTACK SCENARIO:
 * 1. Contract is deployed
 * 2. Attacker sees deployment in mempool
 * 3. Attacker submits initialize(attackerAddress) with higher gas price
 * 4. Attacker's transaction mines first
 * 5. Attacker becomes admin
 */
contract VulnerableInit {

    bool public initialized;
    address public admin;

    event Initialized(address indexed admin, address indexed caller);

    /**
     * @notice Initialize the contract and set admin
     * @param _admin Address to become the admin
     *
     * DOESN'T protect - Anyone can call this first and steal admin rights
     */
    function initialize(address _admin) external {
        require(!initialized, "ALREADY_INITIALIZED");

        admin = _admin;
        initialized = true;

        emit Initialized(_admin, msg.sender);
    }

    function getAdmin() external view returns (address) {
        return admin;
    }

    /**
     * @notice Example admin-only function (just to show the impact)
     */
    function adminOnlyFunction() external view returns (string memory) {
        require(msg.sender == admin, "NOT_ADMIN");
        return "You are the admin!";
    }
}
