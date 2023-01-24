#!/usr/bin/env bash

set -e

########################################################################
# Configuration

DEPLOYMENT_ID="$1"
OLD_CHAIN_NAME="$2"
NEW_CHAIN_NAME="$3"

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
  ipfs_path=$(curl -s -F "file=@$1" "$LOCAL_IPFS_URL/api/v0/add" | jq -r '.Hash') #FIXME. no response?
  echo "$ipfs_path"

  # Pin file to network IPFS gateway, save ipfs hash
  added_hash=$(curl   -s -X POST "$NETWORK_IPFS_URL/api/v0/pin/add?arg=/ipfs/$ipfs_path" | \
    cut -d "[" -f2 | cut -d "]" -f1 | tr -d ' "')
}

# Pin file to network IPFS node
# 1: IPFS hash
ipfs_pin() {
  #sleep 30
  # Pin file to network IPFS gateway, save ipfs hash
  result=$(curl --write-out '%{http_code}' -s -X POST "$NETWORK_IPFS_URL/api/v0/pin/add?arg=/ipfs/$1")

  #| \
  #  cut -d "[" -f2 | cut -d "]" -f1 | tr -d ' "')
  #echo "result: $result"
  #echo "pinned hash: $1"
}

########################################################################
# Update subgraph manifest, pin new one to network IPFS gateway

# Get subgraph manifest and pin to local IPFS node
# Fetch manifest
echo "Download deployment manifest, $DEPLOYMENT_ID..."
curl -s -X POST  "$NETWORK_IPFS_URL/api/v0/cat?arg=$DEPLOYMENT_ID" > deployment_manifest_temp

echo "Replace network name in manifest, $OLD_CHAIN_NAME -> $NEW_CHAIN_NAME..."
# Replace network name: xdai --> gnosis
find_replace_sed \
  $OLD_CHAIN_NAME \
  $NEW_CHAIN_NAME \
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

failed=0
while read hash; do
  result=$(curl --connect-timeout 300 --max-time 600 --write-out '%{http_code}' --silent --output /dev/null -X POST "$NETWORK_IPFS_URL/api/v0/pin/add?arg=/ipfs/$hash")
  echo "result: $result"
  #result=$(ipfs_pin "$hash")
  if [[ $result -ne 200 ]]
  then
    echo "failed: $hash"
    failed=1
    echo $hash >> failed_hashes_$DEPLOYMENT_ID
  else
    echo "success: $hash"
  fi
done < ipfshashes

if [ $failed -gt 0 ]
then
  echo "looping failed ones..."
  while read failed_hash; do
    echo "(looping failed) failed hash: $failed_hash"
    #result=$(ipfs_pin "$hash")
    result=$(curl --connect-timeout 300 --max-time 600 --write-out '%{http_code}' --silent --output /dev/null -X POST "$NETWORK_IPFS_URL/api/v0/pin/add?arg=/ipfs/$failed_hash")
    echo "result: $result"
    if [[ $result == 200 ]]
    then
      # remove failed from failed list
      echo "removing $failed_hash"
      grep -v $failed_hash failed_hashes_$DEPLOYMENT_ID  > tmpfile && mv tmpfile failed_hashes_$DEPLOYMENT_ID
    fi
  done < failed_hashes_$DEPLOYMENT_ID
fi



########################################################################
# Pin metadata files to IPFS node

echo "Pin metadata files to IPFS node..."
subgraph_metadata=$(ipfs_add "$THIS_DIR/subgraphs/$DEPLOYMENT_ID/metadata.json")
version_metadata=$(ipfs_add "$THIS_DIR/subgraphs/generic-first-version-metadata.json")

echo "subgraph metadata pinned: $subgraph_metadata"
echo "version metadata pinned: $version_metadata"