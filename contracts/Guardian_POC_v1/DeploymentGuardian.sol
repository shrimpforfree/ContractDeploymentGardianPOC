// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DeploymentGuardian
 * @notice centralized authorization contract that controls who can initialize protected contracts
 * @dev maintains an allowlist of approved initializers
 */
contract DeploymentGuardian {

    address public owner;
    mapping(address => bool) public approvedInitializers;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ApprovedInitializerSet(address indexed who, bool ok);

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    /**
     * @notice owner is who control the admin permission (can edit ownership and approve initialization of protected contracts)
     * @dev owner is currently hard coded during deployment, can be changed later
     */
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Set approval status for an initializer address
     * @param who Address to approve or revoke
     * @param ok True to approve, false to revoke
     */
    function setApproved(address who, bool ok) external onlyOwner {
        approvedInitializers[who] = ok;
        emit ApprovedInitializerSet(who, ok);
    }

    /**
     * @notice Check if an address is approved to initialize contracts
     * @param who Address to check
     * @return bool True if approved, false otherwise
     */
    function isApproved(address who) external view returns (bool) {
        return approvedInitializers[who];
    }

    /**
     * @notice Transfer ownership to a new address
     * @param newOwner Address of the new owner
     * @dev Added for completeness
     */
    function transferOwnership(address newOwner) external onlyOwner {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
