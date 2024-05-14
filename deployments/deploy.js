async function main() {
    const contract = await ethers.getContractFactory("Groth16Verifier");
    const contract_deploy = await contract.deploy();
    console.log("Contract Deployed to Address:", contract_deploy.address);
    const res =  await contract_deploy.verifyProof(["0x192cb0f9e2426d5ac0433500078b8758a2cb8653de77462ea433aa4c30d10ecf", "0x2dc2c39341070b937bf0a9b16849d425c918ca77e3f2a954d5d8a272e224adc7"],[["0x1f66e16cc46b9fa6969b698d9858fca1a7e10ec44d9d489945c8f977b05737bf", "0x26ba8d916858d35045510e12f2ee874f3bdd946f3a976014c61e895fc2c22881"],["0x156ce81ce3b689f58d66b1143ae52d20abc525e0ef646466afdea97545683585", "0x21c157dd906c5bccb0fab7fea880fa984009ef14b9332aef4e857eced0fa5e6e"]],["0x08c8bb24339b969ae99fd7b3acf083891cf64693794f1c3bbb09cc0a0846bb64", "0x191ec1827be3a72c651fceac93eebc127dcd052746d020070f825e0503b55032"],["0x146769ac3428ab946a99a34d6480132216f76a2deaf6e59b02ed97d00b54d8a7"]);
    console.log(res);
}
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
