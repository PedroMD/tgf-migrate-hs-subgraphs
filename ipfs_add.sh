#!/usr/bin/env bash

set -e

########################################################################
# Vars

FILE_LOCATION="$1"

HOME_DIR=$(dirname $(dirname $(realpath $0)))
export NETWORK_IPFS_URL=https://ipfs.network.thegraph.com
export LOCAL_IPFS_URL=http://localhost:5001

########################################################################
# Functions

# Add/pin a file to network IPFS node
# 1: file location
ipfs_add() {
  # Add file to local ipfs node, save ipfs hash
  ipfs_path=$(curl -F "file=@$1" "$LOCAL_IPFS_URL/api/v0/add" | jq -r '.Hash')
  echo "Added to local IPFS node, deploymentID : $ipfs_path"

  # Pin file to network IPFS gateway, save ipfs hash
  new_deployment_id=$(curl -X POST "$NETWORK_IPFS_URL/api/v0/pin/add?arg=/ipfs/$ipfs_path" | \
    cut -d "[" -f2 | cut -d "]" -f1)
  echo "Pinned to gateway node, deploymentID: $new_deployment_id"
  echo "$new_deployment_id"
}

########################################################################
# Main

ipfs_add "$FILE_LOCATION"
