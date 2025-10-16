// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

/// @title HighValueTransferTrap
/// @notice Detects high-value ERC20-like transfers and triggers Drosera response.
contract HighValueTransferTrap is ITrap {
    string public constant DISCORD_NAME = "Bilnab";
    uint256 public constant VERSION = 1;
    uint256 public constant THRESHOLD = 1 ether;

    struct TransferData {
        address token;
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }

    /// @notice Collect transfer data sample
    function collect() external view override returns (bytes memory) {
        TransferData memory data = TransferData({
            token: address(0),
            from: msg.sender,
            to: address(this),
            amount: THRESHOLD + 1,
            timestamp: block.timestamp
        });

        return abi.encode(data.token, data.from, data.to, data.amount, data.timestamp);
    }

    /// @notice Decide if trap should trigger response
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        if (data.length == 0) return (false, "");

        (address token, address from, address to, uint256 amount, uint256 timestamp) =
            abi.decode(data[0], (address, address, address, uint256, uint256));

        if (amount >= THRESHOLD) {
            return (true, abi.encode(token, from, to, amount, timestamp));
        }

        return (false, "");
    }
}

