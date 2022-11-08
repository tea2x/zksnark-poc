1. Install circom and snarkjs https://docs.circom.io/getting-started/installation/#installing-dependencies

2. Compile the circuit to multiple formats 
    `circom mult.circom --r1cs --wasm --sym --c`

3. Export R1CS to json format
    `snarkjs r1cs export json mult.r1cs mult.json`

4. Generate witness 
    `node mult_js/generate_witness.js mult_js/mult.wasm input.json  witness.wtns`

5. Export the witness to json format
    `snarkjs wtns export json witness.wtns witness.json`

6. Starts a powers of tau ceremony
    `snarkjs powersoftau new bn128 12 pot12_0000.ptau -v`

7. Creates a ptau file with a new contribution. New member adds up to contribute the combined security
    `snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="Tung Pham" -v`

8. Prepares phase 2
    `snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v`

9. Create a proving and a verification key
    `snarkjs groth16 setup mult.r1cs pot12_final.ptau mult_0000.zkey`

8. Prepares phase 2 again????????
    `snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v`
9. Create a proving and a verification key again???????
    `snarkjs groth16 setup mult.r1cs pot12_final.ptau mult_0000.zkey`

10. Contribute to the ceremony
    `snarkjs zkey contribute mult_0000.zkey mult_0001.zkey --name="Tung Pham" -v`

11. Export the verification key
    `snarkjs zkey export verificationkey mult_0001.zkey verification_key.json`

12. Generating a proof
    `snarkjs groth16 prove mult_0001.zkey witness.wtns proof.json public.json`

13. Check first key if it is valid
    `snarkjs zkey verify mult.r1cs pot12_final.ptau mult_0000.zkey`

14. Check first key if it is valid
    `snarkjs zkey verify mult.r1cs pot12_final.ptau mult_0001.zkey`

15. Verifying the proof
    `snarkjs groth16 verify verification_key.json public.json proof.json`

ref: https://medium.com/asecuritysite-when-bob-met-alice/the-magic-of-zksnarks-from-equation-to-verification-1d8c87553ff