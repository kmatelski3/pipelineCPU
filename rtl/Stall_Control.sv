//***********************************************************
// ECE 3058 Architecture Concurrency and Energy in Computation
//
// RISCV Processor System Verilog Behavioral Model
//
// School of Electrical & Computer Engineering
// Georgia Institute of Technology
// Atlanta, GA 30332
//
//  Module:     core_tb
//  Functionality:
//      Stall Controller for a 5 Stage RISCV Processor
//
//***********************************************************
import CORE_PKG::*;

module Stall_Control (
  input logic reset, 

  input logic [6:0] ID_instr_opcode_ip,
  input logic [4:0] ID_src1_addr_ip,
  input logic [4:0] ID_src2_addr_ip,

  //The destination register from the different stages
  input logic [4:0] EX_reg_dest_ip,  // destination register from EX pipe
  input logic [4:0] LSU_reg_dest_ip,
  input logic [4:0] WB_reg_dest_ip,
  input logic LSU_write_reg_en_ip,
  input logic WB_write_reg_en_ip,

  // The opcode of the current instr. in ID/EX
  input [6:0] EX_instr_opcode_ip,

  output logic stall_op

);
  logic EX_write_reg_en;

  always_comb begin
    stall_op = 1'b0;
    EX_write_reg_en = EX_instr_opcode_ip == OPCODE_LOAD || EX_instr_opcode_ip == OPCODE_OP || EX_instr_opcode_ip == OPCODE_OPIMM;
    case(ID_instr_opcode_ip) 

      OPCODE_OP: begin
        
        /**
        * Task 1
        * 
        * Here you will need to decide when to pull the stall control logic high. 
        * 
        * 1. Load to use stalls
        * 2. Stalls when reading and writing from Register File
        * For Register Register instructions, what registers are relevant
        */
        // Register/register - means both rs1 and rs2 are used, check both
        stall_op = EX_instr_opcode_ip === OPCODE_LOAD && ((EX_reg_dest_ip === ID_src1_addr_ip || EX_reg_dest_ip === ID_src2_addr_ip) && EX_write_reg_en && EX_reg_dest_ip !== 0)
                   || ((WB_write_reg_en_ip && WB_reg_dest_ip === ID_src1_addr_ip && WB_reg_dest_ip !==0)
                      && !(EX_reg_dest_ip === ID_src1_addr_ip && EX_write_reg_en && EX_reg_dest_ip !== 0)
                      && !(LSU_reg_dest_ip === ID_src1_addr_ip  && LSU_write_reg_en_ip && LSU_reg_dest_ip != 0))
                  ||  ((WB_write_reg_en_ip && WB_reg_dest_ip === ID_src2_addr_ip && WB_reg_dest_ip !==0)
                      && !(EX_reg_dest_ip === ID_src2_addr_ip && EX_write_reg_en && EX_reg_dest_ip !== 0)
                      && !(LSU_reg_dest_ip === ID_src2_addr_ip  && LSU_write_reg_en_ip && LSU_reg_dest_ip !== 0));
                    
            

      end

      OPCODE_OPIMM: begin

        /**
        * Task 1
        * 
        * Here you will need to decide when to pull the stall control logic high. 
        * 
        * 1. Load to use stalls
        * 2. Stalls when reading and writing from Register File
        * For Register Immedite instructions, what registers are relevant
        */
        // Register/Immediate - means only rs1 is used
        stall_op = EX_instr_opcode_ip === OPCODE_LOAD && (EX_reg_dest_ip === ID_src1_addr_ip && EX_write_reg_en && EX_reg_dest_ip !== 0)
                   || ((WB_write_reg_en_ip && WB_reg_dest_ip === ID_src1_addr_ip && WB_reg_dest_ip !==0) 
                      && !(EX_reg_dest_ip == ID_src1_addr_ip && EX_write_reg_en && EX_reg_dest_ip !== 0)
                      && !(LSU_reg_dest_ip == ID_src1_addr_ip && LSU_write_reg_en_ip && LSU_reg_dest_ip !== 0));
      
      end


      default: begin
        stall_op = 1'b0;
      end
    endcase
  end

endmodule
