var fs = require('fs');

async function main() {
    var array = fs.readFileSync('contractInput.json').toString()
    var arr = JSON.parse("[" + array + "]")

    const contract = await ethers.getContractFactory("Groth16Verifier");
    const contract_deploy = await contract.deploy();
    console.log("Contract Deployed to Address:", contract_deploy.address);
    const res =  await contract_deploy.verifyProof(arr[0], arr[1], arr[2], arr[3]);
    console.log(res);
}
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
