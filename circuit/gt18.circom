pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/comparators.circom";
// this circuit verification succeeds only if input in is greater than 18
template gt() {
    signal input in;
    signal output out;
    //2^7 cover most ages
    component gt = GreaterThan(7);
    gt.in[0] <== in;
    gt.in[1] <== 18;
    out <== gt.out;

    // constraint expression of output signal
    // output must be 1 for the verification to sucess
    // otherwise verification process fails
    out === 1;
 }
 component main = gt();
 
