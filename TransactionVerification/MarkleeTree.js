const keccak256 = require('keccak256')
const { MerkleTree } = require('merkletreejs');
const AlchemyAPI = require('./AlchemyAPI');

async function buildMerkleTree(block) {
    //give a list of transactions has
    const transactions = block.transactions.map(t => t.hash);
    const leaves = transactions;
    const tree = new MerkleTree(leaves, keccak256);
    const root = tree.getRoot().toString('hex');
    return root;
}

async function a() {
    let block = await AlchemyAPI.getBlock(5861808);
    let res = await buildMerkleTree(block);
    console.log(res);
}
//da251f115d677347762256a0bbc098b019075879984aefff45d9b4eb42e74f7b
// 98669788754841316848590328876098484119242743596215866921846548824
a();
