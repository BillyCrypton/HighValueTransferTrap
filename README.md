# High-Value Transfer Trap (Drosera POC)

A lightweight Drosera trap for detecting high-value ERC-20 transfers.  
This Proof-of-Concept demonstrates how an off-chain Drosera operator can scan `Transfer` logs for a configured token and report on-chain incidents via a trap + response pair.

> Designed for quick testing on **Hoodi testnet**. Minimal on-chain logic — Drosera does the log scanning off-chain and calls the trap to record incidents.

---

## Project layout
.
├─ src/
│  ├─ HighValueTransferTrap.sol        # Main trap contract (records incidents)
│  └─ HighValueTransferResponse.sol    # Simple response contract that emits alerts
├─ script/
│  └─ DeployTrap.s.sol                 # Foundry deployment script
├─ foundry.toml                        # Foundry project config (Hoodi)
├─ drosera.toml                        # Drosera node config (template)
└─ README.md                           # This file
---

## Quick concepts

- **Trap** (`HighValueTransferTrap`)  
  Owner sets token thresholds (smallest unit). When Drosera detects a transfer ≥ threshold off-chain, it calls `notifyTransfer(token, from, to, amount)`. Trap records the incident in an on-chain array and attempts to call a *response* contract for further processing.

- **Response** (`HighValueTransferResponse`)  
  Very small contract that just emits an event (`HighValueAlert`) when called by the trap. Keeps on-chain logic minimal and auditable.

- **Drosera (off-chain)**  
  Off-chain operator scans Transfer logs and calls the trap endpoint when conditions are met. This POC assumes an external Drosera node will perform the scanning and call the trap.

---

## Requirements

- Foundry (forge) installed and configured.  
  Install: https://book.getfoundry.sh/getting-started/installation
- Access to a wallet private key for Hoodi testnet (for deployment). **Do not commit this key.**
- Node/VPS (Termius) with network access to Hoodi RPC:
  - `https://ethereum-hoodi-rpc.publicnode.com`

---

## Configure (local / VPS)

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO

2.	Install dependencies (one-time):
forge install OpenZeppelin/openzeppelin-contracts
forge install foundry-rs/forge-std

3.	Edit foundry.toml if you need custom RPC endpoints. The repo ships with a Hoodi-targeted config.
	4.	(Optional) Edit drosera.toml template and set drosera_address to your operator address. Example operator address used in examples: 0xfb3d951fa8496c6933ea0275695BCa906c58527e

Build
From the project root:
forge clean
forge build

If you see compilation errors, ensure:
	•	lib/openzeppelin-contracts exists (forge install completed).
	•	foundry.toml remappings point to the correct lib paths.

Deploy (Hoodi testnet)
Important: never paste your private key into GitHub or commit it. Use environment variable only.

export PRIVATE_KEY=<your_private_key_without_0x>

forge script script/DeployTrap.s.sol:DeployTrap \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key $PRIVATE_KEY \
  --broadcast

The script will:
	•	Deploy HighValueTransferResponse first.
	•	Deploy HighValueTransferTrap, passing the response address to the constructor.
	•	Print both deployed addresses in the console.

After deploy: copy the printed addresses and update drosera.toml (see below).

drosera.toml (template)

The repo contains a drosera.toml template. Before you run your Drosera node, update the trap block:
ethereum_rpc = "https://ethereum-hoodi-rpc.publicnode.com"
drosera_rpc = "https://relay.hoodi.drosera.io"
eth_chain_id = 560048
drosera_address = "0xfb3d951fa8496c6933ea0275695bca906c58527e"

[traps]

[traps.high_value_transfer_trap]
path = "out/HighValueTransferTrap.sol/HighValueTransferTrap.json"
address = "<DEPLOYED_TRAP_ADDRESS>"
response_contract = "<DEPLOYED_RESPONSE_ADDRESS>"
response_function = "handleHighValueTransfer(address,address,address,uint256,uint256)"
cooldown_period_blocks = 0
min_number_of_operators = 1
max_number_of_operators = 3
block_sample_size = 5
private_trap = true
whitelist = []

Place the actual address and response_contract values from your deployment, save, and then register/run Drosera as per your node setup.

Usage & testing

Manual test (after deploy)

From any account (or using cast), you can simulate Drosera calling the trap:
# example using cast (foundry tool)
cast send <TRAP_ADDRESS> "notifyTransfer(address,address,address,uint256)" \
  <TOKEN_ADDRESS> <FROM_ADDRESS> <TO_ADDRESS> <AMOUNT> \
  --private-key <YOUR_KEY> --rpc-url https://ethereum-hoodi-rpc.publicnode.com
After calling, check the trap’s incidents array or watch emitted events from the response contract on the Hoodi testnet explorer.

Quick local Foundry test (recommended)

I can add a small test/ file that deploys a mock ERC-20, sets a threshold and calls notifyTransfer to assert the incident is recorded. Say the word and I’ll add the test.

Security & production notes
	•	Caller restriction: This POC allows anyone to call notifyTransfer. In production you should:
	•	Restrict calls to known operator addresses (owner or a KeeperRegistry), or
	•	Require the Drosera node to sign the detected event and verify the signature on-chain, or
	•	Use an allowlist of Drosera relay addresses.
	•	Gas & storage: Incidents are stored on-chain. For high-volume monitoring prefer off-chain storage with periodic on-chain summaries.
	•	Response behaviour: The response contract in this POC only emits an event. In production it can integrate with alerting backends, governance, or automated safeguards.

⸻

Troubleshooting
	•	forge build errors:
	•	Run forge remappings to confirm remappings.
	•	Reinstall libs: rm -rf lib && forge install OpenZeppelin/openzeppelin-contracts && forge install foundry-rs/forge-std
	•	forge script deployment fails:
	•	Check RPC URL reachable from VPS.
	•	Ensure PRIVATE_KEY is exported and correct.
	•	If transaction fails, check the printed revert reason or tx hash on Hoodi explorer.
	•	Drosera not firing:
	•	Confirm drosera.toml paths (artifact path points to out/).
	•	Ensure private_trap and whitelist settings match your intention.
	•	Check Drosera logs for registration errors.

Contributing

PRs welcome. If you want additional features (signature verification, operator registry, more flexible response), open an issue or PR and I’ll help iterate.

License

MIT
