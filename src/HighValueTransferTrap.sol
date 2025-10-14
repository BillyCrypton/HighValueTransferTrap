// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

/**
 * @title HighValueTransferTrap
 * @notice Detects transfers exceeding a specified threshold on Drosera network
 * @author Bilnab
 */
contract HighValueTransferTrap is ITrap {
    string public constant DISCORD_NAME = "Bilnab";
    uint256 public constant VERSION = 1;
    uint256 public constant TRANSFER_THRESHOLD = 100 ether; // adjust as needed

    struct TransferData {
        address token;
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }

    /**
     * @notice Collects recent transfer data
     * @return Encoded data representing the transfer
     */
    function collect() external view override returns (bytes memory) {
        // Dummy placeholder collection logic
        // In real deployment, the Drosera runtime populates state for analysis
        TransferData memory data = TransferData({
            token: address(0),
            from: address(0),
            to: address(0),
            amount: 0,
            timestamp: block.timestamp
        });

        return abi.encode(
            VERSION,
            data.token,
            data.from,
            data.to,
            data.amount,
            data.timestamp,
            DISCORD_NAME
        );
    }

    /**
     * @notice Evaluates whether a high-value transfer occurred
     * @param data Array of collected transfer data from recent blocks
     * @return shouldTrigger True if a large transfer was detected
     * @return responseData Encoded data for response contract
     */
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool shouldTrigger, bytes memory responseData)
    {
        if (data.length == 0) return (false, bytes(""));

        (
            uint256 version,
            address token,
            address from,
            address to,
            uint256 amount,
            uint256 timestamp,
            string memory discordName
        ) = abi.decode(data[0], (uint256, address, address, address, uint256, uint256, string));

        if (version != VERSION) return (false, bytes(""));

        if (amount >= TRANSFER_THRESHOLD) {
            responseData = abi.encode(token, from, to, amount, timestamp, discordName);
            return (true, responseData);
        }

        return (false, bytes(""));
    }

    /**
     * @notice Returns current configuration parameters
     */
    function getConfig() external pure returns (uint256 threshold, string memory discord) {
        return (TRANSFER_THRESHOLD, DISCORD_NAME);
    }
}
