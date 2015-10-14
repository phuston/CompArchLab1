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
           output reg carryflag, overflag,
           output wire zero,
           input[31:0] a, b,
           input[2:0] selector
);
    wire[2:0] muxindex;
    wire inverse, carryin, carryout;
    reg[31:0] result;
    wire[31:0] xres, nares, nores, mathres, sltres;

    ALUcontrolLUT controlLUT (muxindex, inverse, carryin, selector);

    xOr32 xor32 (xres, a, b);
    nAnd32 nand32 (nares, a, b, inverse);
    nOr32 nor32 (nores, a, b, inverse);
    doMath mather (mathres, carryout, overflow, a, b, inverse, carryin);
    SLT slt (sltres, carryout, overflow, a, b);

    always @(muxindex) begin
        case (muxindex)
          3'd0:  begin assign result = xres; carryflag = 0; overflag = 0; end
          3'd1:  begin assign result = nares; carryflag = 0; overflag = 0; end
          3'd2:  begin assign result = nores; carryflag = 0; overflag = 0; end
          3'd3:  begin assign result = mathres; assign carryflag = carryout; assign overflag = overflow; end
          3'd4:  begin assign result = sltres; assign carryflag = 0; assign overflag = overflow; end
        endcase
    end
    assign out = result;
    zeroTest zertest (zero, result);
endmodule

module zeroTest(output zeroflag,
                input[31:0] result);

    `NOR zerOr(zeroflag, result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],
      result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15],result[16],
      result[17],result[18],result[19],result[20],result[21],result[22],result[23],result[24],result[25],
      result[26],result[27],result[28],result[29],result[30],result[31]);

endmodule

module ALUcontrolLUT(output reg[2:0] muxindex,
           output reg inverse,
           output reg carryin,
           input[2:0] ALUcommand);

    always @(ALUcommand) begin
        case (ALUcommand)
          `cXOR:  begin muxindex = 3'd0; inverse=0; carryin = 0; end
          `cNAND: begin muxindex = 3'd1; inverse=0; carryin = 0; end
          `cAND:  begin muxindex = 3'd1; inverse=1; carryin = 0; end
          `cNOR:  begin muxindex = 3'd2; inverse=0; carryin = 0; end
          `cOR:   begin muxindex = 3'd2; inverse=1; carryin = 0; end
          `cADD:  begin muxindex = 3'd3; inverse=0; carryin = 0; end
          `cSUB:  begin muxindex = 3'd3; inverse=1; carryin = 1; end
          `cSLT:  begin muxindex = 3'd4; inverse=1; carryin = 0; end
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

module SLT(output[31:0] res,
           output carryout, overflow,
           input[31:0] a, b);
    wire[31:0] mathres;

    doMath mather (mathres, carryout, overflow, a, b, 1'b1, 1'b1);    

    assign res = mathres[31];

endmodule

module doMath(output[31:0] res,
              output carryout, overflow,
              input[31:0] a, b,
              input inverse, carryin);

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
    reg [2:0] selector;
    wire[31:0] out;
    wire carryflag, overflag, zeroflag;

    ALU alu (out, carryflag, overflag, zeroflag, a, b, selector);

    initial begin
        $dumpfile("testALU.vcd"); //dump info to create wave propagation later
        $dumpvars(0, alu);

        $display("              operandA              |               operandB              |  selector  |                 output                | carryflag | overflag | zeroflag");
        $display("----------------------------------------------------------------------------------------------------------------------------------------------------------------");
        //Addition Tests
        $display("----------Addition Tests----------");
        a = 32'b0; b = 32'b1; selector = 3'b000; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'd10; b = 32'd1; selector = 3'b000; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);

        //Subtraction Tests
        $display("----------Subtraction Tests----------");
        a = 32'b0; b = 32'b1; selector = 3'b001; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);

        //XOR Tests
        $display("----------XOR Tests----------");
        a = 32'b1; b = 32'b1; selector = 3'b010; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);

        //SLT Tests
        $display("----------SLT Tests----------");
        a = 32'd2; b = 32'b1; selector = 3'b011; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);

        //AND Tests
        $display("----------AND Tests----------");
        a = 32'b01010101010101010101010101010101; b = 32'b10101010101010101010101010101010; selector = 3'b100; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11111111111111110000000000000000; b = 32'b11111111111111110000000000000000; selector = 3'b100; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11010100101000101110011100010010; b = 32'b00101001100101001010111001001011; selector = 3'b100; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);


        //NAND Tests
        $display("----------NAND Tests----------");
        a = 32'b01010101010101010101010101010101; b = 32'b10101010101010101010101010101010; selector = 3'b101; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11111111111111110000000000000000; b = 32'b11111111111111110000000000000000; selector = 3'b101; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11010100101000101110011100010010; b = 32'b00101001100101001010111001001011; selector = 3'b101; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);


        // NOR Tests
        $display("----------OR Tests----------");
        a = 32'b01010101010101010101010101010101; b = 32'b10101010101010101010101010101010; selector = 3'b110; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11111111111111110000000000000000; b = 32'b00000000000000001111111111111111; selector = 3'b110; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11010100101000101110011100010010; b = 32'b00101001100101001010111001001011; selector = 3'b110; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);

        //OR Tests
        $display("----------NOR Tests----------");
        $display("----------OR Tests----------");
        a = 32'b01010101010101010101010101010101; b = 32'b10101010101010101010101010101010; selector = 3'b111; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11111111111111110000000000000000; b = 32'b00000000000000001111111111111111; selector = 3'b111; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);
        a = 32'b11010100101000101110011100010010; b = 32'b00101001100101001010111001001011; selector = 3'b111; #3000
        $display("  %b  |  %b   |    %b     |    %b   |     %b     |    %b     |     %b    ", a, b, selector, out, carryflag, overflag, zeroflag);

    end
endmodule
