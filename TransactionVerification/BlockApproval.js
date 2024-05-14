const alchemyApi = require("./AlchemyAPI")

async function blockApproval(blockNumber) {
    let block;
    try {
        block = await alchemyApi.getBlock(blockNumber.toString());
    } catch (e) {
     console.log(e);
    }

    for (let i = 0; i < block.transactions.length; i++) {
        try {
            let transaction = block.transactions[i];
            if (! await isAccountValid(transaction)) {
                return false;
            }
            if (! await isAmountValid(transaction)) {
                return false;
            }
            if (! await isNonceValid(transaction)) {
                return false;
            }
        } catch (e) {
            console.log("Error with transaction or account:");
            console.log(transaction.hash);
        }
    }
    return block;
}

async function isAccountValid(transaction) {
    if (transaction.type === 1) {
        if (! ( await alchemyApi.validateAccount(transaction.from) && await validateAccount(transaction.to)) ) {
            console.log("error with transaction account:");
            console.log(transaction.hash)
            return false;
        }
    }
    return true;
}
async function isAmountValid(transaction) {
    try {
        let balance = await alchemyApi.getBalance(transaction.from);
        if (transaction.amount > balance) {
            return false;
        }
    } catch (e) {
        console.log("wrong amount");
        console.log(transaction.hash);
        console.log(transaction.from);
        return false;
    }
    return true;
}

async function isNonceValid(transaction) {
    try {
        let nonce = await alchemyApi.getAccountTransactionNumber(transaction.from);
        if (nonce < transaction.nonce) {
            console.log("nonce error");
            console.log(transaction.hash)
            return false;
        }
    } catch (e) {
        console.log("nonce error");
        console.log(transaction.hash)
        return false;
    }
    return true;
}

alchemyApi.getLatestBlockNumber().then((res, err) => {
    blockApproval(res).then((res, err) => {
        console.log(res);
    });
})


module.exports = {
    blockApproval
}
