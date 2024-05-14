const snarkjs = require("snarkjs");
const fs = require("fs");

(async function () {
    const { proof, publicSignals } = await snarkjs.groth16.fullProve({ in: 98669788754841316848590328876098484119242743596215866921846548824 }, "./poseidon_hasher_js/poseidon_hasher.wasm", "circuit_0000.zkey");
    console.log(publicSignals);
    console.log(proof);

    const vKey = JSON.parse(fs.readFileSync("verification_key.json"));
    const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }

    process.exit(0);
})();
