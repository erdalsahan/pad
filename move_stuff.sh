#!/usr/bin/env bash

# change this part according to your chain
CHAIN="1337"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chain_dir="$script_dir/evm/ignition/deployments/chain-$CHAIN"
artifacts_dir="$chain_dir/artifacts"
target_dir="$script_dir/src/lib/abi"

cp -v "$artifacts_dir/AtlaspadDemoModule#APLock.json" "$target_dir/"
cp -v "$artifacts_dir/AtlaspadDemoModule#APPool.json" "$target_dir/"
cp -v "$artifacts_dir/AtlaspadDemoModule#APPoolManager.json" "$target_dir/"
cp -v "$artifacts_dir/AtlaspadDemoModule#APToken.json" "$target_dir/"

cp -v "$chain_dir/deployed_addresses.json" "$target_dir/"