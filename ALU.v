`define AND and #20 //simulate physical gate delay
`define OR or #20
`define NOT not #10
`define NOR nor #10
`define NAND nand #10
`define XOR xor #20
`define XNOR xnor #20

//TODO:
//define zero flag in top level module
//made mathControl (decoder? mux?)
//make top level ALU Module
module ALU();
endmodule


module not32(output[31:0] nRes,
             input[31:0] a
);
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            `NOT not32 (nres[i], a[i]);
        end
    endgenerate
endmodule

module xOr32(output[31:0] xRes,
             output carryout, overflow,
             input[31:0] a, b
);
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            `XOR xor32 (xres[i], a[i], b[i]);
        end
    endgenerate
endmodule

module and32(output[31:0] aRes,
             output carryout, overflow,
             input[31:0] a, b
);
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            `AND and32 (aRes[i], a[i], b[i]);
        end
    endgenerate
endmodule

module nand32(output[31:0] naRes,
             output carryout, overflow,
             input[31:0] a, b
);
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            `NAND nand32 (naRes[i], a[i], b[i]);
        end
    endgenerate
endmodule

module or32(output[31:0] oRes,
             output carryout, overflow,
             input[31:0] a, b
);
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            `OR or32 (oRes[i], a[i], b[i]);
        end
    endgenerate
endmodule

module nor32(output[31:0] noRes,
             output carryout, overflow,
             input[31:0] a, b
);
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            `NOR nor32 (noRes[i], a[i], b[i]);
        end
    endgenerate
endmodule

module doMath(output[31:0] res,
              output carryout, overflow,
              input[31:0] a, b,
              input sub, carryin
);
    wire bmod;
    xOr32 xor32 (bmod, b, sub)

    fullAdder32bit fadder32 (res, carryout, overflow, a, bmod, carryin);
endmodule

module loopfullAdder32bit(output[31:0] sum,  // 2's complement sum of a and b
                      output carryout, overflow,
                      input[31:0] a, b     // First operand in 2's complement format
                      input carryin
);
    wire [32:0] carry;
    carry[0] = carryin;
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            structuralFullAdder fadder (sum[i], carry[i+1], a[i], b[i], carry[i]);
        end
    endgenerate
    carryout = carry[32];
endmodule

module fullAdder32bit(output[31:0] sum,  // 2's complement sum of a and b
                      output carryout, overflow,
                      input[31:0] a, b     // First operand in 2's complement format
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

module fullAdder16bit(output[15:0] sum,  // 2's complement sum of a and b
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

module FullAdder4bit(output[3:0] sum,  // 2's complement sum of a and b
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