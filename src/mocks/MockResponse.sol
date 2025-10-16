// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MockResponse
/// @notice Response contract for HighValueTransferTrap
contract MockResponse {
    event HighValueTransferHandled(
        address token,
        address from,
        address to,
        uint256 amount,
        uint256 timestamp
    );

    function handleHighValueTransfer(
        address token,
        address from,
        address to,
        uint256 amount,
        uint256 timestamp
    ) external {
        emit HighValueTransferHandled(token, from, to, amount, timestamp);
    }
}

