#!/bin/sh

# Proving circuit is a set of arithmetical operations that is performed on input data, to prove the knowledge of it without reviling. 
# In this case, we calculate the root of Merkle tree and use it as the input data for the prover. So we are proving that we know the state
# root that is the result of verifying transactions that are part of the block and using their has for the tree
node ./TransactionVerification/Verifier.js
if [ "$1" = "-g" ];
then
  snarkjs powersoftau new bn128 14 pot14_0000.ptau -v
  snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v -e="someText"
  snarkjs powersoftau contribute pot14_0001.ptau pot14_0002.ptau --name="Second contribution" -v -e="some random text"
  snarkjs powersoftau export challenge pot14_0002.ptau challenge_0003
  snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="some random text"
  snarkjs powersoftau import response pot14_0002.ptau response_0003 pot14_0003.ptau -n="Third contribution name"
  snarkjs powersoftau verify pot14_0003.ptau
  snarkjs powersoftau beacon pot14_0003.ptau pot14_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"
  snarkjs powersoftau prepare phase2 pot14_beacon.ptau pot14_final.ptau -v
  snarkjs powersoftau verify pot14_final.ptau
  circom circuit.circom --r1cs --wasm --sym
  snarkjs r1cs info circuit.r1cs
  snarkjs r1cs print circuit.r1cs circuit.sym
  snarkjs r1cs export json circuit.r1cs circuit.r1cs.json
  node ./circuit_js/generate_witness.js ./circuit_js/circuit.wasm input.json witness.wtns
  snarkjs wtns check circuit.r1cs witness.wtns
  snarkjs groth16 setup circuit.r1cs pot14_final.ptau circuit_0000.zkey
  snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="1st Contributor Name" -v -e="someText"
  snarkjs zkey contribute circuit_0001.zkey circuit_0002.zkey --name="Second contribution Name" -v -e="Another random entropy"
  snarkjs zkey export bellman circuit_0002.zkey  challenge_phase2_0003
  snarkjs zkey bellman contribute bn128 challenge_phase2_0003 response_phase2_0003 -e="some random text"
  snarkjs zkey import bellman circuit_0002.zkey response_phase2_0003 circuit_0003.zkey -n="Third contribution name"
  snarkjs zkey verify circuit.r1cs pot14_final.ptau circuit_0003.zkey
  snarkjs zkey beacon circuit_0003.zkey circuit_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
  snarkjs zkey verify circuit.r1cs pot14_final.ptau circuit_final.zkey
  snarkjs zkey export verificationkey circuit_final.zkey verification_key.json
  snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json
  snarkjs groth16 verify verification_key.json public.json proof.json
  snarkjs zkey export solidityverifier circuit_final.zkey ./contracts/verifier.sol
  snarkjs zkey export soliditycalldata public.json proof.json > ./contractInput.json
  npx hardhat compile
  npx hardhat run deployments/deploy.js --network sepolia
else
  snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json
  snarkjs groth16 verify verification_key.json public.json proof.json
  snarkjs zkey export solidityverifier circuit_final.zkey ./contracts/verifier.sol
  snarkjs zkey export soliditycalldata public.json proof.json > ./contractInput.json
  npx hardhat compile
  npx hardhat run deployments/deploy.js --network sepolia
fi
