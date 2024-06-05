/*
    The program defines a template called "PoseidonHasher" which takes a "secret" input signal called "in" and outputs a signal called "out". 
    It uses a component called "Poseidon" which is included from the circomlib library, and sets it up to use 1 input.
    The code then connects the "secret" input to the first input of the "Poseidon" component, and the output of the "Poseidon" component
    to the "out" output of the template.
    Finally, the program defines a component called "main" which is an instance of the "PoseidonHasher" template.
    Overall, this program creates a circuit that takes a secret input, hashes it using the Poseidon hashing function, and outputs the resulting hash.
*/

pragma circom 2.0.0;

include "./node_modules/circomlib/circuits/poseidon.circom";

template PoseidonHasher() {
    signal input in;
    signal output out;

    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== in;
    out <== poseidon.out;
}

component main = PoseidonHasher();
