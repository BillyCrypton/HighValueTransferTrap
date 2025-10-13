// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/mocks/MockResponse.sol";

/// @notice Foundry deployment script for MockResponse on Hoodi testnet
contract DeployResponse is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); // load from .env
        vm.startBroadcast(deployerPrivateKey);

        MockResponse response = new MockResponse();

        console.log("✅ MockResponse deployed at:", address(response));

        vm.stopBroadcast();
    }
}
