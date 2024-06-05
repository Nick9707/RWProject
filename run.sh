#!/bin/sh

# In the context of zkSNARKs, a "circuit" refers to a specific computation that is represented in a formalized way using logical gates,
# similar to how a digital circuit is represented using gates like AND, OR, and NOT. The circuit defines the behavior of the computation
# that we want to prove knowledge of without revealing any secrets.

# A trusted ceremony is a process in which a group of trusted individuals or entities collaboratively generate
# the initial parameters for a zkSNARK system in a secure and controlled environment. 
# The parameters generated ("Secret") in the trusted ceremony are used to create the proving key and verification key,
# which are used for generating and verifying proofs in zkSNARKs.
node ./TransactionVerification/Verifier.js
if [ "$1" = "-g" ];
then
  # Trusted setup is a process used in some zero knowledge proof systems to generate the initial proving and verifying keys
  # required for generating and verifying proofs. The purpose of trusted setup is to establish a secure foundation for the
  # system by generating these keys in a way that ensures they are unpredictable and unbiased. 
  # This is typically done by having a group of trusted individuals generate the keys together, with each individual contributing 
  # a piece of random data. Once all the pieces are combined and processed using cryptographic techniques, 
  # the resulting keys can be used to generate and verify proofs without the need for any additional trust assumptions. 
  # The goal of trusted setup is to ensure that the system is secure and trustworthy, even if some of the participants 
  # in the trusted setup process are malicious.

  # The file generated during trusted setup process is called a ptau file(powers of tau).
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
  
  # The prove algorithm is responsible for generating the zero-knowledge proof. It takes as inputs the proving key (“pk”), 
  # the private witness “w” and a public value “x” to generate the proof.

  # Witness "w" is the secret you as a prover know and not reveal it to the verifier and public value "x" is used to verify the proof(π) 
  # generated with the witness.
  # proof = Prove(pk,x,w)

  node ./circuit_js/generate_witness.js ./circuit_js/circuit.wasm input.json witness.wtns
  snarkjs wtns check circuit.r1cs witness.wtns

  # Groth16 is a type of zk-SNARK (Zero-Knowledge Succinct Non-Interactive Argument of Knowledge) proof system used for generating and verifying proofs of computation. 
  # It is named after its creator, Jens Groth.

  # circuit_0000.zkey is a binary file that contains the proving and verification keys
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

  # The verify algorithm takes in the proof, the public value "x" and the verification key(vk) and return true or false.
  # V(vk, x, π) = true
  # If the equation is true, then the proof is valid, and the verifier is convinced that the prover possesses the knowledge of
  # the secret witness "w" without revealing it.
  
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
