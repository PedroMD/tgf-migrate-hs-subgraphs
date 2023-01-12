## About
Simple script to facilitate migraton of subgraphs on The Graph's hosted service to mainnet.

## Pre-requisites
- `jq`
- `realpath` (for Mac users: `brew install coreutils`)
- `ipfs`

## Instructions
1. Setup subgraph files in ./subgraph directory following the structure, each subgraph has its own directory titled with deployment_Id, each directory contains  metadata.json and subgraphImage.png
2. Pin files to ipfs, use pin_gnosis_subgraph_files.sh <IPFS_HASH>
3. Publish subgraph: ./publish_subgraph.sh <DEPLOYMENT_ID_IPFS_HASH> <SUBGRAPH_METADADA_IPFS> <VERSION_METADATA_IPFS> (also setting the following ENV variables before running, MNEMONIC,ETHEREUM (rpc endpoint), and ACCOUNT_ADDRESS