// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title HighValueTransferResponse
/// @notice Simple response contract that emits an event for each handled incident.
contract HighValueTransferResponse {
    event HighValueAlert(address indexed token, address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    /// @notice Called by the trap (via try/catch) to register/alert.
    function handleHighValueTransfer(address token, address from, address to, uint256 amount, uint256 timestamp) external {
        // minimal processing — just emit an event
        emit HighValueAlert(token, from, to, amount, timestamp);
    }
}
