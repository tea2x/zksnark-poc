circom circuit/gt18.circom --r1cs --wasm --sym --c -o build

snarkjs r1cs export json build/gt18.r1cs gt18.json

cd witness

node ../build/gt18_js/generate_witness.js ../build/gt18_js/gt18.wasm ../input/input.json  witness.wtns

snarkjs wtns export json witness.wtns witness.json

cd -


cd plonk_trusted_setup

snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

echo nnn | snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="Tung Pham - first avenger" -v

echo ddd | snarkjs powersoftau contribute pot12_0001.ptau pot12_0002.ptau --name="An Vo - second avenger" -v

snarkjs powersoftau export challenge pot12_0002.ptau challenge_0003
snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="sss"
snarkjs powersoftau import response pot12_0002.ptau response_0003 pot12_0003.ptau -n="Nhi Tran - third avenger"

snarkjs powersoftau verify pot12_0003.ptau

snarkjs powersoftau beacon pot12_0003.ptau pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

snarkjs powersoftau prepare phase2 pot12_beacon.ptau pot12_final.ptau -v

snarkjs powersoftau verify pot12_final.ptau

snarkjs plonk setup ../build/gt18.r1cs pot12_final.ptau circuit_final.zkey

snarkjs zkey export verificationkey circuit_final.zkey verification_key.json

cd -

snarkjs plonk prove plonk_trusted_setup/circuit_final.zkey witness/witness.wtns proof.json public.json

snarkjs plonk verify plonk_trusted_setup/verification_key.json public.json proof.json

cd solidity

snarkjs zkey export solidityverifier ../plonk_trusted_setup/circuit_final.zkey verifier.sol

# snarkjs zkey export soliditycalldata public.json proof.json