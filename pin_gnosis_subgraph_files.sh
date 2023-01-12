#!/usr/bin/env bash

set -e

########################################################################
# Configuration

DEPLOYMENT_ID="$1"

THIS_DIR=$(dirname $(realpath "$0"))
HOME_DIR=$(dirname "$THIS_DIR")
CONTRACTS_SOURCE="$HOME_DIR/contracts"
export GNS_CONTRACT_ADDRESS=$(jq '."1337".GNS.address' "$CONTRACTS_SOURCE/addresses.json")
export NETWORK_IPFS_URL=https://ipfs.network.thegraph.com
export LOCAL_IPFS_URL=http://localhost:5001

########################################################################
# Functions

# Replace string in file
# 1: find
# 2: replace
# 3: file
find_replace_sed() {
  sed -i -e "s/${1}/${2}/g" "${3}"
}

# Add/pin a file to network IPFS node
# 1: file location
ipfs_add() {
  # Add file to local ipfs node, save ipfs hash
  ipfs_path=$(curl -s -F "file=@$1" "$LOCAL_IPFS_URL/api/v0/add" | jq -r '.Hash')

  # Pin file to network IPFS gateway, save ipfs hash
  added_hash=$(curl -s -X POST "$NETWORK_IPFS_URL/api/v0/pin/add?arg=/ipfs/$ipfs_path" | \
    cut -d "[" -f2 | cut -d "]" -f1 | tr -d ' "')
  echo $added_hash
}

# Pin file to network IPFS node
# 1: IPFS hash
ipfs_pin() {
  # Pin file to network IPFS gateway, save ipfs hash
  pinned_hash=$(curl -s -X POST "$NETWORK_IPFS_URL/api/v0/pin/add?arg=/ipfs/$1" | \
    cut -d "[" -f2 | cut -d "]" -f1 | tr -d ' "')
  echo $pinned_hash
}

########################################################################
# Update subgraph manifest, pin new one to network IPFS gateway

# Get subgraph manifest and pin to local IPFS node
# Fetch manifest
echo "Download deployment manifest, $DEPLOYMENT_ID..."
curl -s -X POST  "$NETWORK_IPFS_URL/api/v0/cat?arg=$DEPLOYMENT_ID" > deployment_manifest_temp

echo "Replace network name in manifest, xdai -> gnosis..."
# Replace network name: xdai --> gnosis
find_replace_sed \
  'xdai' \
  'gnosis' \
  deployment_manifest_temp

echo "Pin new manifest..."
new_deployment_id=$(ipfs_add deployment_manifest_temp)
echo "new deployment id: $new_deployment_id"
########################################################################
# Get all IPFS files referenced in manifest, ensure they're pinned to the network IPFS node

echo "Pin all subgraph files mentioned in manifest..."

grep 'Qm.*' deployment_manifest_temp > ipfshashes
sed -i -e 's/\/: \/ipfs\///g' ipfshashes
sed -i -e 's/^[[:space:]]\{1,\}//' ipfshashes

while read hash; do
  pinned=$(ipfs_pin "$hash")
  echo "Pinned: $pinned"
done < ipfshashes

########################################################################
# Pin metadata files to IPFS node

echo "Pin metadata files to IPFS node..."
subgraph_metadata=$(ipfs_add "$THIS_DIR/subgraphs/$DEPLOYMENT_ID/metadata.json")
version_metadata=$(ipfs_add "$THIS_DIR/subgraphs/generic-first-version-metadata.json")

echo "subgraph metadata pinned: $subgraph_metadata"
echo "version metadata pinned: $version_metadata"
