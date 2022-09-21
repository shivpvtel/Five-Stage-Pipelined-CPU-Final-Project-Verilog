`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2022 09:10:13 PM
// Design Name: 
// Module Name: testbench
// Project Name: 
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

module testbench();

    reg clk_tb;
    wire ewreg_tb;
    wire em2reg_tb;
    wire ewmem_tb;
    wire mwreg_tb;
    wire mm2reg_tb;
    wire mwmem_tb;
    wire ealuimm_tb;
    wire wwreg_tb;
    wire wm2reg_tb;
    wire [31:0] PC_tb;
    wire [31:0] dinstOut_tb;
    wire [3:0] ealuc_tb;
    wire [4:0] edestReg_tb;
    wire [31:0] eqa_tb;
    wire [31:0] eqb_tb;
    wire [31:0] eimm32_tb;
    wire [4:0] mdestReg_tb;
    wire [31:0] mr_tb;
    wire [31:0] mqb_tb;
    wire [4:0] wdestReg_tb;
    wire [31:0] wr_tb;
    wire [31:0] wdo_tb;
    wire [4:0] rs_tb;
    wire [4:0] rt_tb;
    wire [31:0] wbData_tb;
    wire [31:0] qa_tb;
    wire [31:0] qb_tb;

initial begin 
    clk_tb <= 0;
end

  datapathModule datapathModule_tb(clk_tb,ewreg_tb,em2reg_tb,ewmem_tb,ealuimm_tb,mwreg_tb,mm2reg_tb,mwmem_tb,wwreg_tb,wm2reg_tb,rs_tb,rt_tb,edestReg_tb,mdestReg_tb,wdestReg_tb,PC_tb,dinstOut_tb,ealuc_tb,eqa_tb,eqb_tb,eimm32_tb,mr_tb,mqb_tb,wr_tb,wdo_tb,wbData_tb,qa_tb,qb_tb);
        
always begin
    #5
    clk_tb = ~clk_tb;
    end
endmodule

