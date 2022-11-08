pragma circom 2.0.0;

template Mult() {
    signal input a;
    signal input b;
    signal output d;
    var c=0;
    c = a*a;
    d <== c+b;
 }
 component main = Mult();
 