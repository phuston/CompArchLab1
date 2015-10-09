`define AND and #50 //simulate physical gate delay
`define OR or #50
`define NOT not #50
`define NOR nor #50
`define NAND nand #50
`define XOR xor #50
`define XNOR xnor #50

module FullAdder4bit
(
    output[3:0] sum,  // 2's complement sum of a and b
    output carryout,  // Carry out of the summation of a and b
    output overflow,  // True if the calculation resulted in an overflow
    input[3:0] a,     // First operand in 2's complement format
    input[3:0] b      // Second operand in 2's complement format
);

    wire carry0, carry1, carry2; //declare carryout bits
    wire AxnB, BxS; //declare wires for overflow checking

    structuralFullAdder adder0 (sum[0], carry0, a[0], b[0], 1'b0); //declare 4 adders we use
    structuralFullAdder adder1 (sum[1], carry1, a[1], b[1], carry0);
    structuralFullAdder adder2 (sum[2], carry2, a[2], b[2], carry1);
    structuralFullAdder adder3 (sum[3], carryout, a[3], b[3], carry2);

    `XNOR Xnor (AxnB, a[3], b[3]); //Overflow: A == B and S !== B
    `XOR Xor (BxS, b[3], sum[3]);
    `AND And (overflow, AxnB, BxS);

endmodule

module structuralFullAdder(out, carryout, a, b, carryin);
    output out, carryout; //declare vars
    input a, b, carryin;
    wire AxorB, fullAnd, AandB;

    `XOR AxB (AxorB, a, b); //first level gates
    `AND ABand (AandB, a, b);
    `AND Alland (fullAnd, carryin, AxorB);

    `XOR Sout (out, AxorB, carryin); //final gates
    `XOR Cout (carryout, AandB, fullAnd);
endmodule

module testSomethin;


    initial begin
    end
endmodule
