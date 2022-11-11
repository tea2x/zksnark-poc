### Intro



### Problem
Asume we have a prover A and a Verifier B.

Can A input a number x and make B believe that x > 18 without telling B what that number is?

Imagine A has a black box where he inserts number x and forges a proof for B. And B has another black box that helps him verify with the proof given by A if x on the other end is greater than 18 or not without even looking at x.

           Prover                        Verifier
         ---------                       ---------    x: ???
    x--->|   A   |      ---proof--->     |   B   |    x > 18: YES    
         ---------                       ---------

These boxes once built sucessfully are called Succint Non-interactive Argument of Knowledge - SNARK.

Once set up, any prover can use those boxes to prove to any verifier that they input a number x > 18. =))

Let's build these magical boxes step by step. For the sake of simplicity, all ouput files will be put in the main working directory

### Build the gt18.circom circuit and generate a witness
1. Install circom and snarkjs https://docs.circom.io/getting-started/installation/#installing-dependencies
    First we need an arithmetic circuit for our boxes. See circuit/gt18.circom

2. Compile the circuit to multiple formats

    `circom circuit/gt18.circom --r1cs --wasm --sym --c -o build`

3. Export R1CS to json format

    `snarkjs r1cs export json build/gt18.r1cs gt18.json`

4. Generate witness 

    `node build/gt18_js/generate_witness.js build/gt18_js/gt18.wasm input/input.json  witness.wtns`

5. Export the witness to json format

    `snarkjs wtns export json witness.wtns witness.json`

### Setup ceremony - phase1 - contribute security for ptau file

6. Starts a powers of tau ceremony (The generation of public parameters for zkSNARKs is called the “setup ceremony”)

    `snarkjs powersoftau new bn128 12 pot12_0000.ptau -v`

7. First contributor to the ceremony (seed: "nnn")

    `snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="Tung Pham - first avenger" -v`

8. Second contributor to the ceremony (seed: "ddd")
    `snarkjs powersoftau contribute pot12_0001.ptau pot12_0002.ptau --name="An Vo - second avenger" -v`

9. Third contributor from the outside (seed: "sss")

`
snarkjs powersoftau export challenge pot12_0002.ptau challenge_0003
snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="sss"
snarkjs powersoftau import response pot12_0002.ptau response_0003 pot12_0003.ptau -n="Nhi Tran - third avenger"
`


10. Verify the protocol so far (pick the latest ptau file to verify the entire chain of challenges and responses)
    `snarkjs powersoftau verify pot12_0003.ptau`

11. Fourth contributor - Apply random beacon to create a ptau file with a contribution applied in the form of a random beacon
`snarkjs powersoftau beacon pot12_0003.ptau pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"`


12. Prepares phase 2
    `snarkjs powersoftau prepare phase2 pot12_beacon.ptau pot12_final.ptau -v`


13. Verify the final ptau file
    `snarkjs powersoftau verify pot12_final.ptau`


### Setup ceremony - phase2 - contribute security for zkey file (for groth16 only)

14. Setup
    - plonk: doesn't re quire a specific trusted ceremony so is chosen,  go to step 21. Export the verification key
    `snarkjs plonk setup build/gt18.r1cs pot12_final.ptau circuit_final.zkey`

    - groth16: generate reference zkey without phase2 contribution
    `snarkjs groth16 setup build/gt18.r1cs pot12_final.ptau circuit_0000.zkey`

15. First contribution for zkey (seed: "nnn")
    `snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="First zkey Contributor" -v`

16. Second contribution for zkey (seed: "ddd")
    `snarkjs zkey contribute circuit_0001.zkey circuit_0002.zkey --name="Second zkey Contributor" -v -e="ddd"`

17. Third contribution from the outside (seed: "sss")

`
snarkjs zkey export bellman circuit_0002.zkey  challenge_phase2_0003
snarkjs zkey bellman contribute bn128 challenge_phase2_0003 response_phase2_0003 -e="sss"
snarkjs zkey import bellman circuit_0002.zkey response_phase2_0003 circuit_0003.zkey -n="Third zkey Contributor"
`

18. Verify the lastest zkey (Pick the latest zkey file)

    `snarkjs zkey verify build/gt18.r1cs pot12_final.ptau circuit_0003.zkey`

19. Fourth contributor - Apply random beacon to create a zkey file with a contribution applied in the form of a random beacon

    `snarkjs zkey beacon circuit_0003.zkey circuit_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"`

20. Verify the final zkey
    `snarkjs zkey verify build/gt18.r1cs pot12_final.ptau circuit_final.zkey`

21. Export the verification key
    `snarkjs zkey export verificationkey circuit_final.zkey verification_key.json`

### Generate proof and verify

22. Create the zkproof
    - Plonk:
    `snarkjs plonk prove circuit_final.zkey witness.wtns proof.json public.json`
    - Groth16:
    `snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json`

23. Verify the proof
    - Plonk:
    `snarkjs plonk verify verification_key.json public.json proof.json`
    - Groth16:
    `snarkjs groth16 verify verification_key.json public.json proof.json`

24. Turn the verifier into a smart contract
    `snarkjs zkey export solidityverifier circuit_final.zkey verifier.sol`

25. Simulate a verification call on the verifier smart contract - outputing <proof, publicSignal>
    `snarkjs zkey export soliditycalldata public.json proof.json`

ref: https://github.com/iden3/snarkjs

### Summary

All the steps above are collected to a few main scripts.

To setup plonk snarks run: 
    `npm run setup`
To test arguments of knowledge:
    1) Change `number` in zksnark-poc/scripts/run-snark.js
    2) Run `npm run test`. If `number` > 18 then verification goes OK. Else verification constraint fails showing `ERROR:  4 Error in template gt_3 line: 17`.