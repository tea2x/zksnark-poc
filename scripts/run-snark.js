const snarkjs = require("snarkjs");
const fs = require("fs");

async function run() {
    // creating zero knowledge proof for {a: 34, b: 56}
    const { proof, publicSignals } = await snarkjs.plonk.fullProve({a: 34, b: 56}, "build/mult_js/mult.wasm", "circuit_final.zkey");

    console.log("Proof: ");
    console.log(JSON.stringify(proof, null, 1));
    console.log("Public signal: ");
    console.log(publicSignals);

    const vKey = JSON.parse(fs.readFileSync("verification_key.json"));

    const res = await snarkjs.plonk.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }
}

run().then(() => {
    process.exit(0);
});