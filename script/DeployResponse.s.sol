// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MockResponse.sol";

/// @title DeployResponse
/// @notice Deploys the MockResponse contract for Drosera trap testing
contract DeployResponse is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MockResponse response = new MockResponse();
        console.log("MockResponse deployed to:", address(response));

        vm.stopBroadcast();
    }
}
