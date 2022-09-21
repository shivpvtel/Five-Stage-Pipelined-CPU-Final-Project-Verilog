`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2022 09:09:43 PM
// Design Name: 
// Module   1 Name: Project Shiv PAtel
// Project Name: CMPEN 331 Final Project
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module pcAdder( 

    input wire [31:0] PC,
    output reg [31:0] nextPC
    );
    
    always @(*) begin
        nextPC = PC + 4;
        end
endmodule

/*************************************/
module programCounter( 
    input wire clk,
    input wire [31:0] nextPC,
    
    output reg [31:0] PC
    );
    initial begin
        PC = 100;
        end
        always @(posedge clk) begin
        PC <= nextPC;
        end
endmodule
/*************************************/
module InstructionMemory(
  
    input wire [31:0] PC,
    output reg [31:0] instOut
    );

    reg [31:0] memory [0:63];

    initial begin
    memory[25] = {6'b000000, 5'b00001, 5'b00010, 5'b00011, 5'b00000, 6'b100000}; 
    memory[26] = {6'b000000, 5'b01001, 5'b00011, 5'b00100, 5'b00000, 6'b100010};
    memory[27] = {6'b000000, 5'b00011, 5'b01001, 5'b00101, 5'b00000, 6'b100101};
    memory[28] = {6'b000000, 5'b00011, 5'b01001, 5'b00110, 5'b00000, 6'b100110};
    memory[29] = {6'b000000, 5'b00011, 5'b01001, 5'b00111, 5'b00000, 6'b100100};
    end
    always @(*) begin
      instOut = memory[PC[7:2]];
    end
endmodule
/*************************************/
module IFIDPipeline(

    input clk,
    input wire [31:0] instOut,
    output reg [31:0] dinstOut
    );
    
    always @(posedge clk) begin
    dinstOut <= instOut;
    end
endmodule
/*************************************/
module controlUnit( 
    input wire ewreg, 
    input wire em2reg,
    input wire mwreg, 
    input wire mm2reg,
    input wire [5:0] op, 
    input wire [5:0] func, 
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] edestReg,
    input wire [4:0] mdestReg,
    
    output reg wreg,
    output reg wmem,
    output reg regrt,
    output reg m2reg,
    output reg aluimm,
    output reg [3:0] aluc,
    output reg [1:0] fwda,
    output reg [1:0] fwdb
    );
  
    initial begin
        fwda <= 2'b00;
        fwdb <= 2'b00;
    end 
    
    always@ (*) begin
        fwda <= 2'b00;
        fwdb <= 2'b00;
        
        if (rs == edestReg)
        
        begin
          case(op) 6'b000000:
        begin
            fwda <= 2'b01;
            end
        6'b100011:
        begin
            fwda <= 2'b11;
            end
        endcase
     end
     if(rt == edestReg)
     begin
       case(op) 6'b000000:
        begin
            fwdb <= 2'b01;
            end
        6'b100011:
        begin
            fwdb <= 2'b11;
            end
        endcase
     end
     if(rs == mdestReg)
     begin
       case (op) 6'b000000:
        begin
            fwda <= 2'b10;
            end
        6'b100011:
        begin
            fwda <= 2'b11;
            end
        endcase
     end    
     if(rt == mdestReg)
     begin
       case(op) 6'b000000: 
        begin
            fwdb <= 2'b10;
            end
        6'b100011:
        begin
            fwdb <= 2'b11;
            end
        endcase
     end
    case(op) 6'b000000:
     begin
        case(func) 6'b100000: 
        begin
            wmem <= 1'b0;
            wreg <= 1'b1;
            m2reg <= 1'b0;
            aluimm <= 1'b0;
            aluc <= 4'b0010;
            regrt <= 1'b0;
            end
        6'b100010:
        begin    
            wmem <= 1'b0;
            wreg <= 1'b1;
            m2reg <= 1'b0;
            aluimm <= 1'b0;
            aluc <= 4'b0110;
            regrt <= 1'b0; 
            end
        6'b100100:
        begin
            wmem <= 1'b0;
            wreg <= 1'b1;
            m2reg <= 1'b0;
            aluimm <= 1'b0;
            aluc <= 4'b0000;
            regrt <= 1'b0; 
            end
        6'b100101:
        begin
            wmem <= 1'b0;
            wreg <= 1'b1;
            m2reg <= 1'b0;
            aluimm <= 1'b0;
            aluc <= 4'b0001;
            regrt <= 1'b0; 
            end
        6'b100110:
        begin
            wmem <= 1'b0;
            wreg <= 1'b1;
            m2reg <= 1'b0;
            aluimm <= 1'b0;
            aluc <= 4'b1001;
            regrt <= 1'b0; 
            end
        endcase
    end
    6'b100011: 
    begin
        wmem <= 1'b0;
        wreg <= 1'b1;
        m2reg <= 1'b1;
        aluimm <= 1'b1;
        aluc <= 4'b0010;
        regrt <= 1'b1; 
        end    
    default:
    begin
        wmem <= 1'bX;
        wreg <= 1'bX;
        m2reg <= 1'bX;
        aluimm <= 1'bX;
        aluc <= 4'bXXXX;
        regrt <= 1'bX; 
        end 
     endcase  
  end
endmodule
/*************************************/
module RegrtMux(
    
    input wire [4:0] rt, 
    input wire[4:0] rd,
    input wire regrt,
    output reg [4:0] destReg
    );
    
        always @(*) begin
        if (regrt == 0) begin
            destReg <= rd;
        end
        else begin
            destReg <= rt;
            end
        end
endmodule
/*************************************/
module RegFile( 

    input wire [4:0] rt,
    input wire [4:0] rs,
    output reg [31:0] qa,
    output reg [31:0] qb,
    
    input wire [4:0] wdestReg,
    input wire [31:0] wbData,
    input wire wwreg,
    input wire clk
    );
    reg [31:0] registers [0:63];
    initial begin
    registers[0] = 64'h00000000;  
    registers[1] = 64'hA00000AA;
    registers[2] = 64'h10000011;
    registers[3] = 64'h20000022;
    registers[4] = 64'h30000033;
    registers[5] = 64'h40000044;
    registers[6] = 64'h50000055;
    registers[7] = 64'h60000066;
    registers[8] = 64'h70000077;
    registers[9] = 64'h80000088;
    registers[10] = 64'h90000099;
    end
    always @(*) begin
      qa <= registers[rs];
      qb <= registers[rt];
    end
    always @(negedge clk) begin
      if (wwreg == 1) begin
        registers[wdestReg] <= wbData;
      end
    end
endmodule
/*************************************/
module ImmExtender( 

    input wire [15:0] imm,
    output reg [31:0] imm32
    );
 
    always @(*) begin
        imm32 <= {{16{imm[15]}}, imm};
    end
endmodule
/*************************************/
module IDEXEPipeline( 
    input wire clk,
    input wire wmem, 
    input wire wreg,
    input wire m2reg,
    input wire aluimm,
    input wire [3:0] aluc,
    input wire [31:0] imm32,
    input wire [4:0] destReg,
    input wire [31:0] FwdaMux,
    input wire [31:0] FwdbMux,
   
    output reg ewmem,
    output reg ewreg,
    output reg em2reg,
    output reg ealuimm,
    output reg [31:0] eqa,
    output reg [31:0] eqb,
    output reg [3:0] ealuc,
    output reg [31:0] eimm32,
    output reg [4:0] edestReg
    );
    always @(posedge clk) begin
      ewmem <= wmem;
      ewreg <= wreg;
      em2reg <= m2reg;
      ealuimm <= aluimm;
      eqa <= FwdaMux;
      eqb <= FwdbMux;
      ealuc <= aluc;
      eimm32 <= imm32;
      edestReg <= destReg;
    end
endmodule
/*************************************/
module aluMux(
    
    input wire ealuimm,
    input wire [31:0] eqb,
    input wire [31:0] eimm32,
    output reg [31:0] b
    );
    
    always @(*) begin
        if (ealuimm == 0) begin
            b <= eqb;
        end
        else begin
            b <= eimm32;
            end
        end
endmodule
/*************************************/
module Alu( 
  
    input wire [31:0] b,
    input wire [31:0] eqa,
    input wire [3:0] ealuc,
    output reg [31:0] r
    );
    
       always @(*) begin
       case (ealuc)
            4'b0010://add
            begin
                r <= eqa + b;
            end
            4'b0110://sub
            begin
                r <= eqa - b;
            end
            4'b0001://or
            begin
                r <= eqa|b;
            end
            4'b1001://xor
            begin
                r <= eqa^b;
            end
            4'b0000://and
            begin
                r <= eqa & b;
            end

        endcase
    end
endmodule
/*************************************/
module EXEmem( 
  input clk, 
  input ewreg, 
  input em2reg, 
  input ewmem,
  input [31:0] r, 
  input [31:0] eqb, 
  input [4:0] edestReg, 
    
  output reg mwreg, 
  output reg mm2reg, 
  output reg mwmem, 
  output reg [31:0] mr, 
  output reg [31:0] mqb,
  output reg [4:0] mdestReg
  );
  always @(posedge clk) 
  begin
    mwmem <= ewmem;
    mwreg <= ewreg;
    mm2reg <= em2reg;
    mqb <= eqb;
    mr <= r;
    mdestReg <= edestReg;
  end
endmodule
/*************************************/
module dataMemory( 
  input wire clk,
  input wire [31:0] mr,
  input wire [31:0] mqb,
  input wire  mwmem,
  output reg [31:0] mdo
    );

  reg [31:0] dmemory [0:63]; //63
  initial begin 
    dmemory[0] = 64'hA00000AA;
    dmemory[4] = 64'h10000011;
    dmemory[8] = 64'h20000022;
    dmemory[12] = 64'h30000033;
    dmemory[16] = 64'h40000044;
    dmemory[20] = 64'h50000055;
    dmemory[24] = 64'h60000066;
    dmemory[28] = 64'h70000077;
    dmemory[32] = 64'h80000088;
    dmemory[36] = 64'h90000099;
  end
  always @(*) begin
    mdo = dmemory[mr[7:2]];
  end
  always @(negedge clk) begin
    if (mwmem == 1)begin
      dmemory[mr[7:2]] <= mqb;
    end
    end
endmodule
/*************************************/ 
module MEMwb(
  input clk,
  input mwreg,
  input mm2reg, 
  input [31:0] mr, 
  input [31:0] mdo,
  input [4:0] mdestReg,

  output reg wwreg, 
  output reg wm2reg, 
  output reg [31:0] wr, 
  output reg [31:0] wdo,
  output reg [4:0] wdestReg
);

  always @(posedge clk) begin
    wwreg <= mwreg;
    wm2reg <= mm2reg;
    wdestReg <= mdestReg;
    wr <= mr;
    wdo <= mdo;
  end
endmodule
/*************************************/ 
module WBMux( 

    input wire [31:0] wr,
    input wire [31:0] wdo,
    input wire wm2reg,
    output reg [31:0] wbData
);

        always @(*) begin
        if (wm2reg == 0) begin
            wbData <= wr;
        end
        else begin
            wbData <= wdo;
            end
        end
endmodule
/*************************************/
module FWDA_mux(
  input wire [31:0] r,
  input wire [31:0] qa,  
  input wire [31:0] mr,
  input wire [31:0] mdo,
  input wire [1:0] fwda,
  output reg [31:0] FwdaMux
    );
  always @(*) begin
    case (fwda)
      2'b00:
    begin
      FwdaMux <= qa;
    end
      2'b01:
    begin
      FwdaMux <= r;
    end
      2'b10:
    begin
      FwdaMux <= mr;
    end
      2'b11:
    begin
      FwdaMux <= mdo;
    end
  endcase
  end
endmodule
/*************************************/
module FWDB_mux(
  input wire [31:0] r,
  input wire [31:0] qb,  
  input wire [31:0] mr,
  input wire [31:0] mdo,
  input wire [1:0] fwdb,
  output reg [31:0] FwdbMux
    );
  always @(*) begin
    case (fwdb)
      2'b00:
    begin
      FwdbMux <= qb;
    end
      2'b01:
    begin
      FwdbMux <= r;
    end
      2'b10:
    begin
      FwdbMux <= mr;
    end
      2'b11:
    begin
      FwdbMux <= mdo;
    end
  endcase
  end
endmodule
/****************************************/

module datapathModule(
  
  input clk,
  output wire ewreg,
  output wire em2reg,
  output wire ewmem,
  output wire ealuimm,
  output wire mwreg,
  output wire mm2reg,
  output wire mwmem,
  output wire wwreg,
  output wire wm2reg,
  output wire [4:0] rs,
  output wire [4:0] rt,
  output wire [4:0] edestReg,
  output wire [4:0] mdestReg,
  output wire [4:0] wdestReg,
  output wire [31:0] PC,
  output wire [31:0] dinstOut,
  output wire [3:0] ealuc,
  output wire [31:0] eqa,
  output wire [31:0] eqb,
  output wire [31:0] eimm32,
  output wire [31:0] mr,
  output wire [31:0] mqb,
  output wire [31:0] wr,
  output wire [31:0] wdo,
  output wire [31:0] wbData,
  output wire [31:0] qa,
  output wire [31:0] qb
    );
  
    wire wreg;
    wire m2reg;
    wire aluimm;
    wire wmem;
    wire regrt;
    assign rs = dinstOut[25:21]; 
    assign rt = dinstOut[20:16]; 
    wire [31:0] nextPC;
    wire [31:0] instOut;
    wire [31:0] b;
    wire [31:0] r;
    wire [31:0] mdo;
    wire [5:0] op = dinstOut[31:26];
    wire [4:0] rd = dinstOut[15:11]; 
    wire [5:0] func = dinstOut[5:0];
    wire [15:0] imm = dinstOut[15:0];
    wire [3:0] aluc;
    wire [1:0] fwda;
    wire [1:0] fwdb;
    wire [4:0] destReg;
    wire [31:0] imm32;
    wire [31:0] FwdbMux;
    wire [31:0] FwdaMux;

  
  pcAdder pcAdder(PC, nextPC);
  
  programCounter programCounter(clk, nextPC, PC);
  
  InstructionMemory InstructionMemory(PC, instOut);
  
  IFIDPipeline IFIDPipeline(clk, instOut, dinstOut);
  
  controlUnit controlUnit(ewreg, em2reg,mwreg, mm2reg,op, func, rs,rt,edestReg,mdestReg,wreg,wmem,regrt,m2reg,aluimm,aluc,fwda,fwdb);
  
  RegrtMux RegrtMux(rt, rd, regrt, destReg);
  
  RegFile RegFile(rs, rt, qa, qb, wdestReg, wbData, wwreg, clk);
  
  ImmExtender ImmExtender(imm, imm32);
  
  IDEXEPipeline IDEXEPipeline (clk, wmem, wreg, m2reg, aluimm,  aluc, imm32, destReg, FwdaMux, FwdbMux, ewmem, ewreg, em2reg, ealuimm, eqa, eqb, ealuc, eimm32, edestReg);
  
  aluMux aluMux( ealuimm, eqb, eimm32, b);
  
  Alu Alu(b,eqa,ealuc, r);
  
  EXEmem EXEmem(clk, ewreg, em2reg, ewmem, r, eqb, edestReg, mwreg, mm2reg, mwmem, mr, mqb, mdestReg,);
  
  dataMemory dataMemory(clk, mr, mqb, mwmem, mdo);
  
  MEMwb MEMwb( clk, mwreg, mm2reg, mr, mdo, mdestReg, wwreg,  wm2reg, wr, wdo, wdestReg);    
  
  WBMux WBMux(wr, wdo, wm2reg, wbData);
  
  FWDA_mux FWDA_mux(r, qa, mr, mdo, fwda, FWDAmux);
  
  FWDB_mux FWDB_mux(r, qa, mr, mdo, fwdb, FWDBmux);

endmodule
/*************************************/