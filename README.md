## About
Simple script to facilitate migraton of subgraphs on The Graph's hosted service to mainnet.

## Pre-requisites
- `jq`
- `realpath` (for Mac users: `brew install coreutils`)
- `ipfs`
- https://github.com/graphprotocol/contracts @ root #TODO add as sub-module

## Instructions
1. Setup subgraph files in ./subgraph directory following the structure, each subgraph has its own directory titled with deployment_Id, each directory contains  metadata.json and subgraphImage.png
2. Add logo to local IPFS and save hash.
curl -s -F "file=@./curve-polygon-mips.png" "http://localhost:5001/api/v0/add" | jq -r '.Hash'
4. Tell Network IPFS to pin that hash.
curl -X --POST https://ipfs.network.thegraph.com/api/v0/pin/add?arg=/ipfs/QmToXjnxSkRDU8YdCGnawEdrc3bMnbmUdXSwvuxGixJVxd
5. Update metadata.json pointing to the newly pinned logo
6. Pin files to ipfs, use pin_subgraph_files.sh <IPFS_HASH>
7. Publish subgraph: 
./publish_subgraph.sh <DEPLOYMENT_ID_IPFS_HASH> <SUBGRAPH_METADADA_IPFS> <VERSION_METADATA_IPFS> (also setting the following ENV variables before running, MNEMONIC,ETHEREUM (rpc endpoint), and ACCOUNT_ADDRESS
    - DEPLOYMENT_ID_IPFS_HASH referst to the NEW deployment ID from step #6
    - Example:
     ```MNEMONIC="xxx" ETHEREUM="https://goerli.infura.io/v3/b68ab89e1848466fa1f4a9c3bda0f2dd" ACCOUNT_ADDRESS=0xE20987c54C9F06A5B2fb05D37A49b871ca3DB7E7 ./publish_subgraph.sh QmZ2egWxWWiEoxujgVVvqLyvh2yNG8Q8QyXvmoWYDiB4Ua ./QmV3LtUtUCiD774HXR3D9SJBNgw2VNcXZM9McyMGTfotBQ/metadata.json  ./generic-first-version-metadata.jso```

# do 7 on mac, move subgraph to be published into ./../contracts/cli
## /Users/pdiogo/Documents/code/thegraph/subgraph_publishing_tool



### Other examples
**Example of an update_subgraph_metadata.sh**
MNEMONIC="xxx" ETHEREUM="https://goerli.infura.io/v3/b68ab89e1848466fa1f4a9c3bda0f2dd" ACCOUNT_ADDRESS=0xE20987c54C9F06A5B2fb05D37A49b871ca3DB7E7 ./update_subgraph_metadata.sh Qme7R29Yvi6U8LyTHDgwkLwq3SJvoTLbp5m1ERaBvCmXU3 ./Qmc1XwMPmbVNCqvbTkTNWxGogcZLxQ72WwTsgHVbRTJ7XD/metadata.json  88909531615753365509774376510644539778743308502477770331529531489591500772200

**Example of an publis_new_version.sh**
MNEMONIC="xxx" ETHEREUM="https://goerli.infura.io/v3/b68ab89e1848466fa1f4a9c3bda0f2dd" ACCOUNT_ADDRESS=0xE20987c54C9F06A5B2fb05D37A49b871ca3DB7E7 ./publish_new_version.sh Qme7R29Yvi6U8LyTHDgwkLwq3SJvoTLbp5m1ERaBvCmXU3 ./generic-first-version-metadata.json  88909531615753365509774376510644539778743308502477770331529531489591500772200

