// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/HighValueTransferTrap.sol";

contract DeployTrap is Script {
    function run() external {
        // Load private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Response contract address (already deployed)
        address RESPONSE_CONTRACT = 0xD7D61ceF2D05a1485a408d7B683156B7D4E6b8BE;

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the HighValueTransferTrap contract
        HighValueTransferTrap trap = new HighValueTransferTrap(RESPONSE_CONTRACT);

        vm.stopBroadcast();

        console.log("HighValueTransferTrap deployed at:", address(trap));
    }
}
