`define AND and #20 //simulate physical gate delay
`define OR or #20
`define NOT not #10
`define NOR nor #10
`define NAND nand #10
`define XOR xor #20
`define XNOR xnor #20
`define NOT32 not[31:0] #320

module xOr32
(
    output
)


module arithmeticControl
(
    output[31:0] res,
    output carryout, overflow, zero,
    input[31:0] a, b,
    input sub, carryin
);

    // b is carryin xor b

    // zero is 32-bitwise-not of res
    fullAdder32bit fadder32 (res, carryout, overflow, a, ~b, carryin);

endmodule

module fullAdder32bit
(
    output[31:0] sum,  // 2's complement sum of a and b
    output carryout,  // Carry out of the summation of a and b
    output overflow, // Overflow flag
    input[31:0] a,     // First operand in 2's complement format
    input[31:0] b,      // Second operand in 2's complement format);
    input carryin
);
    wire carry0;

    fullAdder16bit adder0 (sum[15:0], carry0, a[15:0], b[15:0], carryin);
    fullAdder16bit adder1 (sum[31:16], carryout, a[31:16], b[31:16], carry0);

    wire AxnB, BxS; //declare wires for overflow checking
    `XNOR Xnor (AxnB, a[31], b[31]); //Overflow: A == B and S !== B
    `XOR Xor (BxS, b[31], sum[31]);
    `AND And (overflow, AxnB, BxS);
endmodule

module fullAdder16bit
(
    output[15:0] sum,  // 2's complement sum of a and b
    output carryout,  // Carry out of the summation of a and b
    input[15:0] a,     // First operand in 2's complement format
    input[15:0] b,      // Second operand in 2's complement format);
    input carryin
);
    wire carry0, carry1, carry2; //declare carryout bits

    FullAdder4bit adder0 (sum[3:0], carry0, a[3:0], b[3:0], carryin);
    FullAdder4bit adder1 (sum[7:4], carry1, a[7:4], b[7:4], carry0);
    FullAdder4bit adder2 (sum[11:8], carry2, a[11:8], b[11:8], carry1);
    FullAdder4bit adder3 (sum[15:12], carryout, a[15:12], b[15:12], carry2);
endmodule

module FullAdder4bit
(
    output[3:0] sum,  // 2's complement sum of a and b
    output carryout,  // Carry out of the summation of a and b
    input[3:0] a,     // First operand in 2's complement format
    input[3:0] b,      // Second operand in 2's complement format
    input carryin
);

    wire carry0, carry1, carry2; //declare carryout bits

    structuralFullAdder adder0 (sum[0], carry0, a[0], b[0], carryin); //declare 4 adders we use
    structuralFullAdder adder1 (sum[1], carry1, a[1], b[1], carry0);
    structuralFullAdder adder2 (sum[2], carry2, a[2], b[2], carry1);
    structuralFullAdder adder3 (sum[3], carryout, a[3], b[3], carry2);
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

module test32badder;
    reg [31:0] a, b;
    wire[31:0] sum;
    wire carryout, overflow;

    // fullAdder32bit fadder32 (sum, carryout, overflow, a, b);
    subtractor32bit factor32 (sum, carryout, overflow, a, b);

    initial begin
        $dumpfile("4badder.vcd"); //dump info to create wave propagation later
        $dumpvars(0, test32badder);

        a = 32'b10000000000000000000000000000000; b = 32'd1; #1500
        $display("%b, %b, %b", sum, carryout, overflow);

    end
endmodule