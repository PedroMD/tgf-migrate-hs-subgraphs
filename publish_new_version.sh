#!/usr/bin/env bash

set -e

########################################################################
# Configuration

DEPLOYMENT_ID="$1"
VERSION_METADATA_IPFS="$2"
SUBGRAPH_ID="$3"

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
echo "version metadata: $VERSION_METADATA_IPFS"

# Publish new subgraph version
./cli/cli.ts  contracts gns publishNewVersion \
  --mnemonic "$MNEMONIC" \
  --provider-url "$ETHEREUM" \
  --ipfs "$NETWORK_IPFS_URL/" \
  --graphAccount "$ACCOUNT_ADDRESS" \
  --subgraphDeploymentID "$DEPLOYMENT_ID" \
  --versionPath "$VERSION_METADATA_IPFS" \
  --subgraphID "$SUBGRAPH_ID" #Token ID in Studio
  

#   export const publishNewVersion = async (cli: CLIEnvironment, cliArgs: CLIArgs): Promise<void> => {
#   const subgraphID = cliArgs.subgraphID
#   const ipfs = cliArgs.ipfs
#   const subgraphDeploymentID = cliArgs.subgraphDeploymentID
#   const versionPath = cliArgs.versionPath

#   const subgraphDeploymentIDBytes = IPFS.ipfsHashToBytes32(subgraphDeploymentID)
#   const versionHashBytes = await pinMetadataToIPFS(ipfs, 'version', versionPath)
#   const gns = cli.contracts.GNS

#   logger.info(`Publishing new subgraph version for ${subgraphID}...`)
#   await sendTransaction(cli.wallet, gns, 'publishNewVersion', [
#     subgraphID,
#     subgraphDeploymentIDBytes,
#     versionHashBytes,
#   ])
# }

# export const publishNewSubgraph = async (cli: CLIEnvironment, cliArgs: CLIArgs): Promise<void> => {
#   const ipfs = cliArgs.ipfs
#   const subgraphDeploymentID = cliArgs.subgraphDeploymentID
#   const versionPath = cliArgs.versionPath
#   const subgraphPath = cliArgs.subgraphPath

#   const subgraphDeploymentIDBytes = IPFS.ipfsHashToBytes32(subgraphDeploymentID)
#   const versionHashBytes = await pinMetadataToIPFS(ipfs, 'version', versionPath)
#   const subgraphHashBytes = await pinMetadataToIPFS(ipfs, 'subgraph', subgraphPath)
#   const gns = cli.contracts.GNS

#   logger.info(`Publishing new subgraph for ${cli.walletAddress}...`)
#   await sendTransaction(cli.wallet, gns, 'publishNewSubgraph', [
#     subgraphDeploymentIDBytes,
#     versionHashBytes,
#     subgraphHashBytes,
#   ])
# }
