const { Network, Alchemy } = require("alchemy-sdk");
require('dotenv').config();
let request = require('request');
const apiKey = process.env.API_KEY;

const settings = {
    apiKey: apiKey, // Replace with your Alchemy API Key.
    network: Network.ETH_SEPOLIA, // Replace with your network.
};

const alchemy = new Alchemy(settings);

async function getLatestBlockNumber(){
    return await alchemy.core.getBlockNumber();
}

async function getBlock(blockNummber){
    let blockNummberHex = "0x" + parseInt(blockNummber).toString(16);
    return new Promise(function(resolve, reject) {
        return request.post("https://eth-sepolia.g.alchemy.com/v2/" + apiKey,
            { json: {"id": 1,
                    "jsonrpc": "2.0",
                    "method": "eth_getBlockByNumber",
                    "params": [
                        blockNummberHex,
                        true
                    ]}},
            function (error, response, body) {
                if (!error && response.statusCode === 200) {
                   resolve(body.result);
                } else {
                    console.log(error);
                    reject(blockNummberHex);
                }
            });
    });
}


async function getTransaction(transactionHash){
    return await alchemy.core.getTransaction(transactionHash);
}

async function validateAccount(accountNumber){
    try {
        await alchemy.core.send("eth_getProof", [
            accountNumber,
            [],
            'latest'
        ])
    } catch (e) {
        return false;
    }
    return true;
}

async function getBalance(accountNumber){
    return await alchemy.core.getBalance(accountNumber, "latest")
}

async function getAccountTransactionNumber(accountNumber) {
    return await alchemy.core.getTransactionCount(accountNumber);
}

// getBlock("5861791").then((res, err) => {
//     console.log(res);
// }).catch((e) => {console.log(e)});
//
// getLatestBlockNumber().then((res, err) => {
//      console.log(res);
//  }).catch((e) => {console.log(e)});


module.exports = {
    getLatestBlockNumber,
    getBlock,
    getTransaction,
    validateAccount,
    getBalance,
    getAccountTransactionNumber
}
