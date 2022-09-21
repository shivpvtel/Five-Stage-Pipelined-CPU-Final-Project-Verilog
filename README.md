# Five-Stage-Pipelined-CPU-Final-Project-Verilog

This project is a *pipelining technique* for building a fast CPU. I will *obtain experience with the design implementation and testing of the five-stage pipelined CPU using the Xilinx design package for FPGAs*. This code will coded/debugged on the Xilinx design package for Field Programmable Gate Arrays (FPGAs).

1. **Pipelining** - Pipelining is an implementation technique in which multiple instructions are overlapped in execution. The five- stage pipelined CPU allows overlapping execution of multiple instructions. Although an instruction takes five clock cycle to pass through the pipeline, a new instruction can enter the pipeline during every clock cycle. Under ideal circumstances, the pipelined CPU can produce a result in every clock cycle. Because in a pipelined CPU there are multiple operations in each clock cycle, we must save the temporary results in each pipeline stage into pipeline registers for use in the follow-up stages. We have five stages: IF, ID, EXE, MEM, and WB. The PC can be considered as the first pipeline register at the beginning of the first stage. We name the other pipeline registers as IF/ID, ID/EXE, EXE/MEM, and MEM/WB in sequence. In order to understand in depth how the pipelined CPU works, we will show the circuits that are required in each pipeline stage of a baseline CPU.

2. **Circuits of the Instruction Fetch Stage** - The circuit in the IF stage are shown in Figure 2. Also, looking at the first clock cycle in Figure 1(b), the first lw instruction is being fetched. In the IF stage, there is an instruction memory module and an adder between two pipeline registers. The left most pipeline register is the PC; it holds 100. In the end of the first cycle (at the rising edge of clk), the instruction fetched from instruction memory is written into the IF/ID register. Meanwhile, the output of the adder (PC + 4, the next PC) is written into PC.

3. **Circuits of the Instruction Decode Stage** - Referring to Figure 3, in the second cycle, the first instruction entered the ID stage. There are two jobs in the second cycle: to decode the first instruction in the ID stage, and to fetch the second instruction in the IF stage. The two instructions are shown on the top of the figures: the first instruction is in the ID stage, and the second instruction is in the IF stage. The first instruction in the ID stage comes from the IF/ID register. Two operands are read from the register file (Regfile in the figure) based on rs and rt, although the lw instruction does not use the operand in the register rt. The immediate (imm) is sign- extended into 32 bits. The regrt signal is used in the ID stage that selects the destination register number; all others must be written into the ID/EXE register for later use. At the end of the second cycle, all the data and control signals, except for regrt, in the ID stage are written into the ID/EXE register. At the same time, the PC and the IF/ID register are also updated.

4. **Circuits of the Execution Stage** - Referring to Figure 4, (8.5) in the third cycle the first instruction entered the EXE stage. The ALU performs addition, and the multiplexer selects the immediate. A letter “e” is prefixed to each control signal in order to distinguish it from that in the ID stage. The second instruction is being decoded in the ID stage and the third instruction is being fetched in the IF stage. All the four pipeline registers are updated at the end of the cycle.

5. **Circuits of the Memory Access Stage** - Referring to Figure 5, (8.6) in the fourth cycle of the first instruction entered the MEM stage. The only task in this stage is to read data memory. All the control signals have a prefix “m”. The second instruction entered the EXE stage; the third instruction is being decoded in the ID stage; and the fourth instruction is being fetched in the IF stage. All the five pipeline registers are updated at the end of the cycle.

6. **Circuits of the Write Back Stage** - Referring to Figure 6, in the fifth cycle the first instruction entered the WB stage. The memory data is selected and will be written into the register file at the end of the cycle. All the control signal have a prefix “w”. The second instruction entered the MEM stage; the third instruction entered the EXE stage; the fourth instruction is being decoded in the ID stage; and the fifth instruction is being fetched in the IF stage. All the six pipeline registers are updated at the end of the cycle (the destination register is considered as the six pipeline register). Then the first instruction is committed. In each of the forth coming clock cycles, an instruction will be commited and a new instruction will enter the pipeline. We use the structure shown in Figure 1 as a baseline for the design of our pipelined CPU.

7. **Control Hazards and Delayed Branch** - The control hazard occurs when a pipelined CPU executes a branch or jump instruction. The jump target address a jump instruction (jr, j, or jal) can be determined in the ID stage and it will be written into PC at the end of the ID stage. But because the pipelined CPU fetches instruction during every clock cycle, the next instruction is being fetched during the ID stage of the jump instruction. The control hazard caused by a conditional branch instruction (beq or bne) becomes more serious than that of a jump instruction because the condition must be evaluated in addition to the calculation of the branch of the target address. Figure 7 shows an example when we calculate the branch target address in the EXE or the ID stage respectively. There are mainly two methods to deal with the instruction(s) next to branch or jump instruction. One method is to cancel it (them). The other is to let it (them) be executed. The second method is called a delayed branch. The position in between the location of a jump or branch instruction and the jump or branch target address are called delay slots. MIPS (microprocessor without interlocked pipeline stages) ISA (instruction set architecture) adopts a one delay slot mechanism: the instruction located in delay slot is always executed no matter wither the branch is taken or not as shown in figure 8. In figure 8 (a) shows the case where the branch is not taken. Figure 8 (b) shows the case where the branch is taken; t is the branch target address. In both cases, the instruction located in a+4 (delay slot) is always executed no matter whether the branch is taken or not. In order to implement the delayed branch with one delay slot, we must let the conditional branch instructions finish the executions in the ID stage. There should be no problem for calculating the branch target address within the ID stage. For checking the condition, we can perform an exclusive OR (XOR) on the two source operands:```verilog rsrtequ = ~| (da^db); // (da == db)``` where the ```verilog rsrtequ ``` signal indicates where da or db are equal or not. Both da and db should be the state of the art data. Referring to     figures 9 and 10, we use the outputs of the multiplexers for internal forwarding as da and db. This is the reason why we put the forwarding to the ID stage instead of to the EXE stage. Because the delayed branch, the return address of the MIPS jal instruction is PC+8. Figure 11 illustrates the execution of the jal instruction. The instruction located in delay slot (PC + 4) was already executed before transferring control to a function (or a subroutine). The return address should be PC+8, which is written into $31 register in the WB stage by the jal instruction. The return form subroutine can be done by the instruction of jr $31. The jr rs instruction reads the content of register rs and writes it into the PC.

***For your reference***
*Figure 12 illustrate the detailed circuit of the pipelined CPU, plus instruction memory and data memory.*
The PC can be considered as the first pipeline located in front of the IF stage, and a register of the register file can be considered as the sixth (last) pipeline register at the end of the WB stage.
In the IF stage, an instruction is fetched from instruction memory, and the PC is incremented by 4 if the instruction in the ID stage is neither a branch nor a jump instruction, and there is no pipeline stall. There are four sources for the next PC:
+ pc4: PC+4
+ bpc: branch target address of a beq or bne instruction da: target address in register of a jr instruction
+ jpc: jump target address of a j or jal instruction
+ The selection of the next PC (npc) is done by a 32-bit 4-to-1 multiplexer whose selection signal is pcsrc (PC source), generated by the control unit in the ID stage.
In the ID stage, two register operands are read from the register file based on ```verilog rs ``` and ```verilog rt ```; the immediate (imm) is extended and the instruction is decoded based on op (and func) by the control unit.
The selection signal of the multiplexer for ALU’s input e.g. A is named fwda (forward A) and the other for ALU’s input B, is named fwdb (forward B). if there is no data hazard, the multiplexer selects the data read from the register file. The inverse of the stall signal is used as the write enable for the PC and the IF/ID pipeline register (wpcir). The stall signal becomes true when an instruction in the ID stage uses the result of an lw instruction which is in the EXE stage. Thus, the stall signal can be generated by the following Verilog HDL code.```verilog stall = ewreg & em2reg & (ern!=0) & (i_rs & (ern== rs) | i_rt & (ern == rt)); ``` where i_rs and i_rt indicate that an instruction uses the contents of the rs register and the rt register respectively. There is an important thing we must not to forget. The pipeline stall is implemented by prohibiting the updates of the PC and the IF/ID pipeline register. But the instruction that is already in the IF/ID register will be decoded and fed to the next pipeline stage. This will result in an instruction being executed twice. To prvent an instruction from being executed twice, we must cancel the first instruction. Canceling an instruction is easy: prevent it from updating the states of the cpu and memory.

All the control signals that will be used in the following stages are saved into the ID/EXE registers.
In the EXE stage, in addition to the operation performed by the ALU, the PC+8 operation is carried out by an adder for generating the return address for the jal instruction. The shift amount (sa) for a shift instruction can be extracted from the immediate field (eimm). If the instruction in the EXE stage is a jal, PC+8 is selected and the destination register number (ern) is set to 31 (done by f component). Otherwise, the ALU output is selected and let ern=ern0 (rd or rt in the EXE stage).

+ *In the MEM stage*, if the instruction is an sw, the data mb will be written into the data memory addressed by malu. If the instruction is an lw, the memory data addressed by malu is read out. Other instructions do nothing in this stage.

+ *In the WB stage*, an instruction is graduated by writing the result, either the ALU result or memory data, into a register file. The destination register number is wrn (register number in the WB stage). And the write enable signal is wwreg (register write enable in WB stage)

10. **Test Program and Simulation Waveform** - Write a Verilog code that implement the following instructions to verify the correctness of your pipelined CPU design. The code should be used to initialize the instruction memory block. The register file should be all initialized to zeros. In the test program, it is aimed to check the 20 instructions. The main part of the test program is a subroutine in which four 32-bit memory words are summed by a for loop. After returning from the subroutine, the sum is stored in the data memory by a sw instruction. A code pattern that causes pipeline stall is also prepared within the loop. Word address is used to assign the content of each word (a 32-bit instruction). The parenthesized hexadecimal number in the center of each line is the byte address (PC).

<img width="787" alt="Screen Shot 2022-09-21 at 18 56 28" src="https://user-images.githubusercontent.com/81172033/191624500-ac62e4ff-fd8f-4a6e-aef1-5891e524ccd8.png">

<img width="819" alt="Screen Shot 2022-09-21 at 18 56 46" src="https://user-images.githubusercontent.com/81172033/191624517-287d9cae-f851-44c9-9360-aaa008f53dd3.png">

Below is the test data that should be stored in the data memory. Four 32-bit words in the memory will be read by lw instructions. The test program will store a word in the location next to the four words.

<img width="813" alt="Screen Shot 2022-09-21 at 18 57 14" src="https://user-images.githubusercontent.com/81172033/191624576-2ff14330-d0b1-423d-9307-eec0c26e5921.png">

**Figure 13** illustrates an example of waveforms when the pipelined CPU executes the jal instruction (PC = 0x00000008). The instruction in the delay slot (PC = 0x0000000c) is executed also. The taget address of the jal instruction is 0x0000006c, the entry of a subroutine (sum). The result at the EXE stage of the jal instruction is 0x00000010, which is the return address (from the subroutine).

11. Write a Verilog code that implement the instructions shown in item number 8 with the corresponding initialization of data memory using the design shown in Figure 12. You need to show your outputs in a similar way as figure 13 with the same signals when the pipelined CPU execute the lw $9, 0($4) instruction (PC = 0x00000070) and its follow up, the add $8, $8, $9 instruction in the fourth (last round) of the for loop.



Table 1 lists the names and usages of the 32 registers in the register file:
  
<img width="934" alt="Screen Shot 2022-09-21 at 12 53 04" src="https://user-images.githubusercontent.com/81172033/191565107-c33b3f9b-aa09-4cce-b734-a1be836a16df.png">

Table 2 lists some MIPS instructions that will be implemented in our CPU:

<img width="799" alt="Screen Shot 2022-09-21 at 12 55 28" src="https://user-images.githubusercontent.com/81172033/191565568-4f167c2b-abb3-4e57-9bd6-21306ace0f83.png">

**Figure 1** Timing chart comparison between two types of CPUs:

<img width="842" alt="Screen Shot 2022-09-21 at 12 42 11" src="https://user-images.githubusercontent.com/81172033/191562787-591e541d-2194-44b8-bc5f-1c09a8d27e59.png">

**Figure 2** Pipeline instruction fetch (IF) stage:

<img width="822" alt="Screen Shot 2022-09-21 at 12 42 37" src="https://user-images.githubusercontent.com/81172033/191562874-dbc35d00-98b5-4f1a-98e9-0a5876893d15.png">

**Figure 3** Pipeline instruction decode (ID) stage:

<img width="849" alt="Screen Shot 2022-09-21 at 12 42 58" src="https://user-images.githubusercontent.com/81172033/191563014-05e3ae3e-caf2-40ec-a418-076194c5627c.png">

**Figure 4** Pipeline execution (EXE) stage:

<img width="882" alt="Screen Shot 2022-09-21 at 12 44 54" src="https://user-images.githubusercontent.com/81172033/191563334-b9935ae1-c2ac-4310-bf1f-28249a8723a7.png">

**Figure 5** Pipeline memory access (MEM) stage:

<img width="903" alt="Screen Shot 2022-09-21 at 12 45 23" src="https://user-images.githubusercontent.com/81172033/191563456-77335e7b-ea00-4428-bbcb-d83560c9b4bb.png">

**Figure 6** Pipeline write back (WB) stage:

<img width="914" alt="Screen Shot 2022-09-21 at 12 52 03" src="https://user-images.githubusercontent.com/81172033/191564908-34f85346-f075-44bb-b09c-867d895c1dd3.png">

**Figure 7** Determining whether a branch is taken or not taken:

<img width="894" alt="Screen Shot 2022-09-21 at 18 46 01" src="https://user-images.githubusercontent.com/81172033/191623491-83f5890b-3725-459d-8015-5baad9d99726.png">

**Figure 8** Delayed branch:

<img width="915" alt="Screen Shot 2022-09-21 at 18 48 12" src="https://user-images.githubusercontent.com/81172033/191623720-0e3b6130-133f-4810-a301-36e947fe64df.png">

**Figure 9** Implementation with delayed branch with one delay slot:

<img width="916" alt="Screen Shot 2022-09-21 at 18 48 43" src="https://user-images.githubusercontent.com/81172033/191623772-58001b65-3996-4e3a-a72a-04133a90af20.png">

**Figure 10** Mechanism of internal forwarding and pipeline stall:

<img width="903" alt="Screen Shot 2022-09-21 at 18 49 11" src="https://user-images.githubusercontent.com/81172033/191623810-d151a79b-5c09-41d0-85fe-c0f8db3e5b45.png">

**Figure 11** Return address of the function call instruction:

<img width="900" alt="Screen Shot 2022-09-21 at 18 49 36" src="https://user-images.githubusercontent.com/81172033/191623855-af1e835d-6bbc-4123-a6f0-a4c987f5b476.png">

**Figure 12** Detailed circuit of the pipelined CPU:

<img width="1284" alt="Screen Shot 2022-09-21 at 18 52 59" src="https://user-images.githubusercontent.com/81172033/191624155-45c2d609-9f03-4fec-9a74-3202bc76130d.png">

**Figure 13** Waveform of the pipelined CPU (call subroutine):

<img width="697" alt="Screen Shot 2022-09-21 at 18 58 02" src="https://user-images.githubusercontent.com/81172033/191624671-c24da0c2-d3ff-4dc2-b7fe-86ba850c8238.png">

My Results:

**Timing Diagram:**

![timing diagram project](https://user-images.githubusercontent.com/81172033/191625102-71fdd527-395f-45b5-80d4-89855f2df4d0.png)

**Timing Analysis:**

![timing analysis](https://user-images.githubusercontent.com/81172033/191625144-150ff539-8013-4d2e-b223-3be9e420e455.png)

**I/O Planning:**

![I:O planning rpoject](https://user-images.githubusercontent.com/81172033/191625198-df4be83e-599f-4f71-a6ee-7213a74cbee6.png)

**Floor Planning:**

![porject Floorplanning](https://user-images.githubusercontent.com/81172033/191625247-9c4da8fd-1029-4c2b-8acf-6556f858375d.png)

**Design Schematic:**

![Desing Schematic](https://user-images.githubusercontent.com/81172033/191625488-aaff5fac-d12f-4104-8263-214f58a29b76.png)









