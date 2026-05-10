# base-smart-account

> ERC-4337 Smart Account for Base L2

Modular, upgradeable ERC-4337 smart account with session keys, social recovery, batch transactions, and spending limits — fully compatible with Coinbase Smart Wallet.

## Features
- 🔑 Session keys with per-dApp permissions
- 👥 Social recovery (M-of-N guardians)
- 📦 Batch transaction execution
- 💸 Spending limits per token/time period
- 🔌 Module system (plugins)
- 🔄 Upgradeable via UUPS proxy
- ⚡ Compatible with Coinbase Paymaster

## Installation
```bash
git clone https://github.com/fabt31/base-smart-account
forge install && forge build && forge test
```

## Deploy
```bash
forge script script/DeployAccount.s.sol --rpc-url $BASE_RPC_URL --broadcast
```

## Usage
```typescript
import { createSmartAccount } from "./src/client";

const account = await createSmartAccount({
  owner: ownerAddress,
  factoryAddress: FACTORY_ADDRESS,
  rpc: "https://mainnet.base.org",
});

// Batch transactions
await account.executeBatch([
  { to: TOKEN, data: approveData },
  { to: SWAP_ROUTER, data: swapData },
]);
```

## EntryPoint
`0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`

## License
MIT