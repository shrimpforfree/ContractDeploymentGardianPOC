// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MultiTenantGuardian
 * @notice Decentralized guardian - each customer controls their own initializer allowlist
 */
contract MultiTenantGuardian {

    // customer => initializer => approved
    mapping(address => mapping(address => bool)) public approved;

    event ApprovalSet(address indexed customer, address indexed initializer, bool ok);

    /**
     * @notice Customer approves/revokes an initializer for their own contracts
     * @param initializer Address to approve or revoke
     * @param ok True to approve, false to revoke
     */
    function setApproved(address initializer, bool ok) external {
        require(initializer != address(0), "ZERO_ADDRESS");
        approved[msg.sender][initializer] = ok;
        emit ApprovalSet(msg.sender, initializer, ok);
    }

    /**
     * @notice Check if initializer is approved for customer
     * @param customer The customer address
     * @param initializer The initializer address to check
     */
    function isApproved(address customer, address initializer) external view returns (bool) {
        return approved[customer][initializer];
    }
}
