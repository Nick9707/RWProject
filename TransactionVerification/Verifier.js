const blockApproval = require("./BlockApproval");
const alchemyApi = require("./AlchemyAPI");
const markleeTree = require("./MarkleeTree");
const fs = require('fs');

async function main(){
    let blockNumber = await alchemyApi.getLatestBlockNumber();
    let block = await blockApproval.blockApproval(blockNumber);
    let hash = await markleeTree.buildMerkleTree(block);
    // let hash = "98669788754841316848590328876098484119242743596215866921846548824";
    if (hash.length % 2) { hash = '0' + hash; }
    var bn = BigInt('0x' + hash);
    var hash_int = bn.toString(10);
    let input = JSON.stringify({"in": hash_int});
    fs.writeFileSync('./input.json', input);
    console.log("Done verification");

}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

