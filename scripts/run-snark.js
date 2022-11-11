const snarkjs = require("snarkjs");
const fs = require("fs");

var number = 18;

async function run() {
    // creating zero knowledge proof
    try {
        const { proof, publicSignals } = await snarkjs.plonk.fullProve(
            {in: number},
            "build/gt18_js/gt18.wasm",
            "plonk_trusted_setup/circuit_final.zkey"
        );
    
        console.log("Proof: ");
        console.log(JSON.stringify(proof, null, 1));
        console.log("Public signal: ");
        console.log(publicSignals);

        const vKey = JSON.parse(fs.readFileSync("plonk_trusted_setup/verification_key.json"));

        const res = await snarkjs.plonk.verify(vKey, publicSignals, proof);

        if (res === true) {
            console.log("Verification OK");
        } else {
            console.log("Invalid proof");
        }
    } catch (e) {
        if (e.toString().search("Error: Assert Failed")) {
            console.log("Invalid proof constraint")
        }
    }
}

run().then(() => {
    process.exit(0);
});