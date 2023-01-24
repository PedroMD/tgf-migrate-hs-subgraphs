#!/usr/bin/env bash

set -e

########################################################################
# Configuration

DEPLOYMENT_ID="$1"
SUBGRAPH_METADATA_IPFS="$2"
VERSION_METADATA_IPFS="$3"

THIS_DIR=$(dirname $(realpath "$0"))
HOME_DIR=$(dirname "$THIS_DIR")
CONTRACTS_SOURCE="$HOME_DIR/contracts"
# export GNS_CONTRACT_ADDRESS=$(jq '."1337".GNS.address' "$CONTRACTS_SOURCE/addresses.json")
export NETWORK_IPFS_URL=https://ipfs.network.thegraph.com
export LOCAL_IPFS_URL=http://localhost:5001

########################################################################
# Publish subgraph deployment to the network

cd "$CONTRACTS_SOURCE"

echo "Publishing to network..."
echo "deploymentID: $DEPLOYMENT_ID"
echo "from: $ACCOUNT_ADDRESS"
echo "IPFS node: $NETWORK_IPFS_URL"
echo "ethereum: $ETHEREUM"
echo "subgraph metadata: $SUBGRAPH_METADATA_IPFS"
echo "version metadata: $VERSION_METADATA_IPFS"

# Publish subgraph to the network
./cli/cli.ts  contracts gns publishNewSubgraph \
  --mnemonic "$MNEMONIC" \
  --provider-url "$ETHEREUM" \
  --ipfs "$NETWORK_IPFS_URL/" \
  --graphAccount "$ACCOUNT_ADDRESS" \
  --subgraphDeploymentID "$DEPLOYMENT_ID" \
  --subgraphPath "$SUBGRAPH_METADATA_IPFS" \
  --versionPath "$VERSION_METADATA_IPFS"

#  --subgraphPath "$THIS_DIR/subgraphs/$DEPLOYMENT_ID/metadata.json" \
#  --versionPath "$THIS_DIR/subgraphs/generic-first-version-metadata.json"

## Mint signal
#./cli/cli.ts contracts graphToken approve \
#  --mnemonic "$MNEMONIC" \
#  --provider-url "$ETHEREUM" \
#  --account "$GNS_CONTRACT_ADDRESS" \
#  --amount 1000
#
## Mint and signal on subgraph
#./cli/cli.ts contracts gns mintSignal \
#  --mnemonic "$MNEMONIC" \
#  --provider-url "$ETHEREUM" \
#  --nftID "$1" \
#  --tokens 1000

# ?? how to get metadata and version metadata??
# let's just use a general file structure.
# /subgraphs/<DEPLOYMENT_ID>/metadata.json
# /subgraphs/<DEPLOYMENT_ID>/version.json
