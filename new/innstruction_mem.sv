`timescale 1ns / 1ps


module instruction_mem(
    input [31:0] instr_addr,
    output [31:0] instr_data
    );

    logic [31:0] rom[0:127];

    initial begin
        
    // -------------------------------------------------------------------------
    // [1] I-Type ALU (imm calculate & alu & shift)
    
    rom[0] = 32'hfff00293; // ADDI  x5, x0, -1  (x5 = 0xFFFFFFFF, --> -1)
    rom[1] = 32'h0002a313; // SLTI  x6, x5, 0   (x6 = 1, -1<0 --> True )
    rom[2] = 32'h0002b393; // SLTIU x7, x5, 0   (x7 = 0, Unsigned 0xFFFF = -1--> bigger than '0')
    rom[3] = 32'h00f2c413; // XORI  x8, x5, 15  (x8 = 0xFFFFFFF0 = -16 )
    rom[4] = 32'h00f46493; // ORI   x9, x8, 15  (x9 = 0xFFFFFFFF = -1)
    rom[5] = 32'h0034f513; // ANDI x10, x9, 3  (x10 = 3)
    rom[6] = 32'h00251593; // SLLI x11, x10, 2 (x11 = 12, shift left 2 side)
    rom[7] = 32'h0012d613; // SRLI x12, x5, 1  (x12 = 0x7FFFFFFF = 21...(big size), zero-extend)
    rom[8] = 32'h4012d693; // SRAI x13, x5, 1  (x13 = 0xFFFFFFFF = -1, msb_extend )

    // -------------------------------------------------------------------------
    // [2] R-Type ALU (register_cal)

    rom[9] = 32'h004187b3;  // ADD X15, X3, X4 (x15 = 7)                        
    rom[10] = 32'h40628d33; // SUB x26, x5, x6 (x26 = -2)
    rom[11] = 32'h00a31db3; // SLL x27, x6, x10(x27 = 1 << 3 = 8 )
    rom[12] = 32'h0062ae33; // SLT x28, x5, x6(x28 = 1, signed -1 < 1(True)) 
    rom[13] = 32'h00533733;  // SLTU x14, x6, x5 (x14 = 1, Unsigned 1 < 0xFFFFFFFF)
    rom[14] = 32'h005347b3; // XOR  x15, x6, x5 (x15 = 0xFFFFFFFE)
    rom[15] = 32'h00a2d833; // SRL  x16, x5, x10(x16 = 0x1FFFFFFF, shift right like x10(3))
    rom[16] = 32'h40a2d8b3; // SRA  x17, x5, x10(x17 = 0xFFFFFFFF, keep state(-,+) )
    rom[17] = 32'h0062e933; // OR   x18, x5, x6 (x18 = 0xFFFFFFFF)
    rom[18] = 32'h0062f9b3; // AND  x19, x5, x6 (x19 = 1)

   // -------------------------------------------------------------------------
    // [3] Memory (Load / Store) - store certain byte & extend test
   
    rom[19] = 32'h06400a13; // ( setting Memory base address) ADDI x20, x0, 100
    rom[20] = 32'h005a2023; // SW   x5, 0(x20)  (dmem[100] = 0xFFFFFFFF)
    rom[21] = 32'h006a1223; // SH   x6, 4(x20)  (dmem[104] = 0x0001)
    rom[22] = 32'h00aa0323; // SB   x10, 6(x20) (dmem[106] = 0x03)
    rom[23] = 32'h000a2a83; // LW   x21, 0(x20) (x21 = 0xFFFFFFFF)
    rom[24] = 32'h004a1b03; // LH   x22, 4(x20) (x22 = 1)
    rom[25] = 32'h006a0b83; // LB   x23, 6(x20) (x23 = 3)
    rom[26] = 32'h004a5c03; // LHU  x24, 4(x20) (x24 = 1, zero Extended)
    rom[27] = 32'h006a4c83; // LBU  x25, 6(x20) (x25 = 3, zero Extended)

    // -------------------------------------------------------------------------
    // [4] B-Type (Branch) -  to jump -->  all True 
    
    rom[28] = 32'h00630463; // 28. BEQ  x6, x6, 8   (1 == 1, True -> imm 8 jump)
    rom[29] = 32'h00531863; // 29. BNE  x6, x5, 16   (1 != 1, True -> imm 16 jump)
    rom[30] = 32'h00634463; // 30. BLT  x6, x6, 8   (1 < 1, false -> Keep PC+4, no jump)
    rom[31] = 32'h0062d463; // 31. BGE  x5, x6, 8   (1 >= -1, false -> Keep PC+4, no jump)
    rom[32] = 32'hfe536ae3; // 32. BLTU x6, x5, -12 (1 < 0xFFFF.., True -> imm -4 jump)
    rom[33] = 32'h01b37463; // 33. BGEU x6, x27, 8   (0xFFFF.. >= 8, false -> Keep PC+4, no jump)

  // [5] U-Type (address)
    
    rom[34]  = 32'h000010b7; // LUI   x1, 1       (x1 =  0x00001000)
    rom[35]  = 32'h00001117; // AUIPC x2, 1       (x2 = PC + 0x1000)
  
  // [6] J-Type (Jump)  

        rom[36] = 32'h00a00293;  // ADDI x5,x0,10 (144)
        rom[37] = 32'h00c000ef;  // JAL x1, 12 (148 + 12 =160)
        rom[38] = 32'h00128293;  // ADDI x5, x5, 1 (x5 == 11)
        rom[39] = 32'h0000006f;  // JAL x0, 0(Infiinte loop) --> debuging 
        rom[40] = 32'h01400313;  // ADDI x6, x0, 20 (160)
        rom[41] = 32'h00008067;  // JALR x0, x1, 0 (Go back to 152)

    end

    assign instr_data = rom[instr_addr[31:2]]; // delete '0', '1'

endmodule


        //$readmemh("riscv_rv32i_rom_data_sum.mem", rom);

        //rom[0]  = 32'h000010b7; //  LUI   x1, 1       (x1 = 0x00001000)
        //rom[1]  = 32'h00001117; //  AUIPC x2, 1       (x2 = PC + 0x1000)
        //rom[2]  = 32'h004001ef; //  JAL   x3, 4       (x3 = PC+4 store, PC+4 Jump)
        //rom[3]  = 32'h00018267; //  JALR  x4, x3, 0   (x4 = PC+4 store, x3 Jump)
        
        //rom[3] = 32'h00211123;
        //rom[2] = 32'h00211123;
        //rom[2] =32'h402852b3;  
        
        //rom[0] = 32'h00402023;  //x4,0(x0)
        //rom[1] = 32'h00a020a3;  //x10,1(x0)
        //rom[2] = 32'h00000283;  //x5, 0(x0)
        
        
        //professor code 
        //rom[0] =32'h004182b3;  //  ADD X5, X3, X4
        //rom[1] = 32'h00812123; // SW x8, 2(x2),
        //rom[2] = 32'h00212383;  // LW, x7 x2, 2
        //rom[3] = 32'h00438413;  //  ADDI X8, X7, 4
        //rom[4] = 32'h00840463; //BEQ x8 x8,8
        //rom[5] =32'h004182b3;  //  ADD X5, X3, X4
        //rom[6] = 32'h00812123; // SW x8, 2(x2),

        //practice code 
        //rom[0] = 32'h005102a3; // SB x5  5(x2)
        //rom[1] = 32'h00511123;  // SH x5 2(x2)

        //rom[0]  = 32'h000010b7; //  LUI   x1, 1       (x1 = 0x00001000)
        //rom[1]  = 32'h00001117; //  AUIPC x2, 1       (x2 = PC + 0x1000)
        //rom[2]  = 32'h004001ef; //  JAL   x3, 4       (x3 = PC+4 store, PC+4 Jump)
        //rom[3]  = 32'h00018267; //  JALR  x4, x3, 0   (x4 = PC+4 store, x3 Jump)

    //rom[0]  = 32'hfff00293; // 5. ADDI  x5, x0, -1  (x5 = 0xFFFFFFFF,  -1)
    //rom[1]  = 32'h0002a313; // 6. SLTI  x6, x5, 0   (x6 = 1, -1<0 --> True )
    //rom[2]  = 32'h0002b393; // 7. SLTIU x7, x5, 0   (x7 = 0, Unsigned 0xFFFF...bigger than '0')
    //rom[3]  = 32'h00f2c413; // 8. XORI  x8, x5, 15  (x8 = 0xFFFFFFF0)
    //rom[4]  = 32'h00f46493; // 9. ORI   x9, x8, 15  (x9 = 0xFFFFFFFF)
    //rom[5]  = 32'h0034f513; // 10. ANDI x10, x9, 3  (x10 = 3)
    //rom[6] = 32'h00251593; // 11. SLLI x11, x10, 2 (x11 = 12, shift 2 block left)
    //rom[7] = 32'h0012d613; // 12. SRLI x12, x5, 1  (x12 = 0x7FFFFFFF, zero extend)
    //rom[8] = 32'h4012d693; // 13. SRAI x13, x5, 1  (x13 = 0xFFFFFFFF, msb_extend)
       













    //S-type full case
    //rom[1] = 32'h006a1223; // SH   x6, 4(x20)  (dmem[104] = 0x0001)
    //rom[2] = 32'h005a1323; // SH   x4, 6(x20)  (dmem[104] = 0x0001)

    //rom[1] = 32'h005a2023; // SW   x5, 0(x20)  (dmem[100] = 0xFFFFFFFF)
    //rom[2] = 32'h006a2023; // SW   x5, 0(x20)  (dmem[100] = 0xFFFFFFFF)

    //rom[1] = 32'h00aa0223; // SB   x10, 4(x20) (dmem[106] = 0x03)
    //rom[2] = 32'h00aa02a3; // SB   x10, 5(x20) (dmem[106] = 0x03)
    //rom[3] = 32'h00aa0323; // SB   x10, 6(x20) (dmem[106] = 0x03)
    //rom[4] = 32'h00aa03a3; // SB   x10, 7(x20) (dmem[106] = 0x03)

    //L-type full case 
    //rom[2] = 32'h000a2a83; // LW   x21, 0(x20)

    //rom[2] = 32'h000a1b03; // LH   x22, 0(x20) 

    //rom[1] = 32'h006a1023; // SH   x6, 0(x20)    
    //rom[2] = 32'h000a0b83; // LB   x23, 0(x20) (x23 = 3)
    
    //rom[1] = 32'h00aa0223; // SB   x10, 4(x20)
    //rom[2] = 32'h00aa02a3; // SB   x10, 5(x20)
    //rom[3] = 32'h004a5c03; // LHU  x24, 4(x20) (x24 = 10, zero Extended)

    //rom[1] = 32'h00aa0223; // SB   x10, 4(x20)
    //rom[2] = 32'h004a4c83; // LBU  x25, 4(x20) (x25 = 10, zero Extended)

    //rom[0] = 32'h06400a13; // ( setting Memory base address) ADDI x20, x0, 100
    //rom[1] = 32'h006a1223; // SH   x6, 4(x20)  
    //rom[2] = 32'h004a2a83; // LW   x21, 4(x20)




//
//
    //////rom[38] = nothing order (xxxxx)    
    ////
    ////
    //////rom[36]  = 32'h004001ef; // JAL   x3, 4       (x3 =148  after store PC+4 , to jump 148)
    //////rom[37]  = 32'h00418267; // JALR  x4, x3, 4   (x4 = 152 after store PC+4 , to jump x3  152)
////
    ////    
    