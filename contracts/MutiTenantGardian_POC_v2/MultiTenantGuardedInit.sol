// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MultiTenantGuardian.sol";

/**
 * @title MultiTenantGuardedInit
 * @notice Protected by multi-tenant guardian - only customer-approved initializers can initialize
 */
contract MultiTenantGuardedInit {

    bool public initialized;
    address public admin;
    MultiTenantGuardian public immutable guardian;
    address public immutable customer;

    event Initialized(address indexed admin, address indexed caller);

    /**
     * @notice Constructor sets guardian and customer (both immutable)
     * @param _guardian Address of MultiTenantGuardian contract
     */
    constructor(address _guardian) {
        guardian = MultiTenantGuardian(_guardian);
        customer = msg.sender;
    }

    /**
     * @notice Initialize contract - only customer-approved addresses can call
     * @param _admin Address to become admin
     */
    function initialize(address _admin) external {
        require(!initialized, "ALREADY_INITIALIZED");
        require(guardian.isApproved(customer, msg.sender), "NOT_APPROVED");

        admin = _admin;
        initialized = true;

        emit Initialized(_admin, msg.sender);
    }

    function adminOnlyFunction() external view returns (string memory) {
        require(msg.sender == admin, "NOT_ADMIN");
        return "You are the admin!";
    }
}
