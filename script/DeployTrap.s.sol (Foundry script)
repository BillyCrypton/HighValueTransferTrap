// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/HighValueTransferTrap.sol";
import "../src/HighValueTransferResponse.sol";

contract DeployTrap is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);

        // Deploy response first
        HighValueTransferResponse resp = new HighValueTransferResponse();

        // Deploy trap with response address
        HighValueTransferTrap trap = new HighValueTransferTrap(address(resp));

        // Optionally set a sample threshold (owner is deployer)
        // trap.setThreshold(0x...tokenAddress..., 1000000000000000000);

        console.log("Deployed Response at:", address(resp));
        console.log("Deployed Trap at:", address(trap));

        vm.stopBroadcast();
    }
}
