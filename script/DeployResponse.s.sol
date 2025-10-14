// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/HighValueTransferTrapResponse.sol";

/// @title DeployResponse Script
/// @notice Deploys the HighValueTransferTrapResponse contract to the Hoodi Testnet
contract DeployResponse is Script {
    function run() external {
        // Start broadcasting with your private key
        vm.startBroadcast();

        // Deploy the response contract
        HighValueTransferTrapResponse response = new HighValueTransferTrapResponse();

        // Log the deployed address
        console.log("HighValueTransferTrapResponse deployed at:", address(response));

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
