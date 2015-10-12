`define AND and #20 //simulate physical gate delay
`define OR or #20
`define NOT not #10
`define NOR nor #10
`define NAND nand #10
`define XOR xor #20
`define XNOR xnor #20

`define cADD  3'd0
`define cSUB  3'd1
`define cXOR  3'd2
`define cSLT  3'd3
`define cAND  3'd4
`define cNAND 3'd5
`define cNOR  3'd6
`define cOR   3'd7

//TODO:
//define zero flag in top level module
//make mathControl (decoder? mux?)
//make top level ALU Module

module ALU(output[31:0] out,
           output carryflag, overflag, zero,
           input[31:0] a, b,
           input[2:0] selector
);
    wire[1:0] muxindex;
    wire inverse, carryin, carryout;
    wire[31:0] result, xres, nares, nores, mathres;

    ALUcontrolLUT controlLUT (muxindex, inverse, carryin, selector);

    xOr32 xor32 (xres, a, b);
    nAnd32 nand32 (nares, a, b, inverse);
    nOr32 nor32 (nores, a, b, inverse);
    doMath mather (mathres, carryout, overflow, a, b, inverse, carryin);

    always @(muxindex) begin
        case (muxindex)
          1'd0:  begin result = xres; carryflag = 0; overflag = 0; end
          1'd1:  begin result = nares; carryflag = 0; overflag = 0; end
          1'd2:  begin result = nores; carryflag = 0; overflag = 0; end;
          1'd3:  begin result = mathres; assign carryflag = carryout; assign overflag = overflow; end;
        endcase
    end
    assign out = result;
    zeroTest zertest (zero, result);
endmodule

module zeroTest(output zeroflag,
                input[31:0] result);
    wire zerout;
    assign zerout = 1'b0;
    generate
        genvar z
        for (z=0; z<32; z=z+1) begin: zeroblock
            `OR zerOr (zerout, zerout, result[z]);
        end
    endgenerate
endmodule

module ALUcontrolLUT(output reg[1:0] muxindex,
           output reg inverse,
           output reg carryin,
           input[2:0] ALUcommand);

    always @(ALUcommand) begin
        case (ALUcommand)
          `cADD:  begin muxindex = 0; inverse=0; carryin = 0; end
          `cSUB:  begin muxindex = 0; inverse=1; carryin = 1; end
          `cSLT:  begin muxindex = 0; inverse=1; carryin = 0; end
          `cXOR:  begin muxindex = 1; inverse=0; carryin = 0; end
          `cNAND: begin muxindex = 2; inverse=0; carryin = 0; end
          `cAND:  begin muxindex = 2; inverse=1; carryin = 0; end
          `cNOR:  begin muxindex = 3; inverse=0; carryin = 0; end
          `cOR:   begin muxindex = 3; inverse=1; carryin = 0; end
        endcase
    end
endmodule

module not32(output[31:0] nRes,
             input[31:0] a
);
    generate
        genvar i;
        for (i=0; i<32; i=i+1) begin: notblock
            `NOT not32 (nRes[i], a[i]);
        end
    endgenerate
endmodule

module xOr32(output[31:0] xRes,
             input[31:0] a, b
);
    generate
        genvar j;
        for (j=0; j<32; j=j+1) begin: xorblock
            `XOR xor32 (xRes[j], a[j], b[j]);
        end
    endgenerate
endmodule

module nAnd32(output[31:0] res,
              input[31:0] a, b,
              input inverse);

    wire[31:0] nandRes;
    wire[31:0] inverseExtended;

    generate
        genvar l;
        for (l=0; l<32; l=l+1) begin: nandblock
            `NAND nand32 (nandRes[l], a[l], b[l]);
        end
    endgenerate

    signExtend invExtender(inverseExtended, inverse);

    xOr32 xor32 (res, nandRes, inverseExtended);

endmodule


module nOr32(output[31:0] res,
             input[31:0] a, b,
             input inverse );

    wire[31:0] norRes;
    wire[31:0] inverseExtended;

    generate
        genvar n;
        for (n=0; n<32; n=n+1) begin: norblock
            `NOR nor32 (norRes[n], a[n], b[n]);
        end
    endgenerate

    signExtend invExtender(inverseExtended, inverse);

    xOr32 xor32 (res, norRes, inverseExtended);

endmodule

module doMath(output[31:0] res,
              output carryout, overflow,
              input[31:0] a, b,
              input inverse, carryin
);

    wire[31:0] paddedSub;

    signExtend extender(paddedSub, inverse);

    wire[31:0] bmod;
    xOr32 xor32 (bmod, b, paddedSub);

    fullAdder32bit fadder32 (res, carryout, overflow, a, bmod, carryin);

endmodule

module fullAdder32bit(output[31:0] sum,  // 2's complement sum of a and b
                      output carryout, overflow,
                      input[31:0] a, b,     // First operand in 2's complement format
                      input carryin
);

    wire [32:0] carry;
    assign carry[0] = carryin;

    generate
        genvar o;
        for (o=0; o<32; o=o+1) begin: addblock
            bitFullAdder fadder (sum[o], carry[o+1], a[o], b[o], carry[o]);
        end
    endgenerate

    assign carryout = carry[32];
    `XOR overflowcalc (overflow, carryout, carry[31]);
endmodule

module bitFullAdder(out, carryout, a, b, carryin);
    output out, carryout; //declare vars
    input a, b, carryin;
    wire AxorB, fullAnd, AandB;

    `XOR AxB (AxorB, a, b); //first level gates
    `AND ABand (AandB, a, b);
    `AND Alland (fullAnd, carryin, AxorB);

    `XOR Sout (out, AxorB, carryin); //final gates
    `XOR Cout (carryout, AandB, fullAnd);
endmodule

module signExtend(signExtendedInverse, inverse);
    output[31:0] signExtendedInverse;
    input inverse;

    generate
        genvar index;
        for (index=0; index<32; index=index+1) begin: subpad
            assign signExtendedInverse[index] = inverse;
        end
    endgenerate
endmodule

module testALU;
    reg [31:0] a, b;
    wire[31:0] sum;
    wire carryout, overflow;

    // fullAdder32bit fadder32 (sum, carryout, overflow, a, b);
    doMath mather (sum, carryout, overflow, a, b, 1'b1, 1'b1);

    initial begin
        $dumpfile("testALU.vcd"); //dump info to create wave propagation later
        $dumpvars(0, mather);

        a = 32'b00000000000000000000100000000010; b = 32'd1; #1500
        $display("%b, %b, %b", sum, carryout, overflow);

    end
endmodule
