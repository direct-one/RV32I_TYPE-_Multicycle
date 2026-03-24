`timescale 1ns / 1ps


module apb_master(
        //BUS Global signal 
        input                 PCLK,
        input                 PRESET,
        

        //SoC Internal signal with CPU
        input   logic  [31:0] addr,
        input   logic  [31:0] Wdata,
        input   logic         w_req, // from cpu, write request, signal cpu : dwe
        input   logic         r_req, // from cpu, read request, signal cpu : dre 
        output  logic         slverr,  // RAM 
        output  logic  [31:0] rdata,   // RAM  
        output  logic         ready,
        
        //APB interface signal 
        output  logic  [31:0] paddr,  //need register
        output  logic  [31:0] PWDATA, //need register
        output  logic         penable,
        output  logic         pwrite,
        output  logic         psel0,       // RAM 
        output  logic         psel1,       // GPO
        output  logic         psel2,       // GPI 
        output  logic         psel3,       // GPIO  
        output  logic         psel4,       // FND
        output  logic         psel5,       // UART
        input   logic  [31:0] prdata0,      // RAM 
        input   logic  [31:0] prdata1,      // GPO 
        input   logic  [31:0] prdata2,      // GPI 
        input   logic  [31:0] prdata3,      // GPIO 
        input   logic  [31:0] prdata4,      // FND 
        input   logic  [31:0] prdata5,      // UART
        input   logic         pready0,      // RAM 
        input   logic         pready1,      // GPO
        input   logic         pready2,      // GPI
        input   logic         pready3,      // GPIO
        input   logic         pready4,      // FND
        input   logic         pready5      // UART

    );



//STATE(APB Interface)
    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } apb_state_e;

    apb_state_e c_state, n_state;

    logic [31:0] paddr_next, PWDATA_next;
    logic decode_en, pwrite_next;
    
    always_ff @( posedge PCLK, negedge PRESET ) begin
        if(!PRESET)begin // negative edge reset // delay half clk 
            c_state <= IDLE;
            paddr <= 32'd0;
            PWDATA <= 32'd0;
            pwrite <= 1'b0;
        end else begin
            c_state <= n_state;
            paddr  <= paddr_next;
            PWDATA <= PWDATA_next;
            pwrite <= pwrite_next;
        end
    end

    //next
    always_comb begin 
        decode_en = 1'b0;
        penable   = 1'b0;
        pwrite    = 1'b0;
        paddr_next = paddr;
        PWDATA_next = PWDATA;
        pwrite_next = pwrite;
        n_state     = c_state;
        case (c_state)
            IDLE:begin
                decode_en = 0;
                if(w_req | r_req)begin
                    paddr_next = addr;
                    PWDATA_next = Wdata;
                    if (w_req) begin
                        pwrite = 1'b1;
                    end else begin
                        pwrite = 1'b0;
                    end
                    n_state = SETUP;
                end
            end 
            SETUP:begin
                decode_en = 1;
                penable   = 0;
                n_state = ACCESS;
            end
            ACCESS:begin
                decode_en =1;
                penable = 1;
                //if (pready0 | pready1 | pready2| pready3| pready4 | pready5) begin
                //    n_state = IDLE;
                //end
                if(ready)begin
                    n_state = IDLE;
                end
            end
        endcase
    end


addr_decoder U_ADDR_DECODER(
    .addr(addr),
    .psel0(psel0),  // RAM 
    .psel1(psel1), // GPO
    .psel2(psel2), // GPI 
    .psel3(psel3), // GPIO  
    .psel4(psel4), // FND
    .psel5(psel5), // UART
    .en(decode_en)
);


    apb_mux U_APB_MUX(
    .sel(addr),
    .prdata0(prdata0),
    .prdata1(prdata1),
    .prdata2(prdata2),
    .prdata3(prdata3),
    .prdata4(prdata4),
    .prdata5(prdata5),
    .pready0(pready0),
    .pready1(pready1),
    .pready2(pready2),
    .pready3(pready3),
    .pready4(pready4),
    .pready5(pready5),
    .rdata(rdata),
    .ready(ready)

);


        //input   logic         pslverr,
        //output  logic         pselx,  // RAM  
        //output  logic         slverr1, // GPO
        //output  logic         slverr2, // GPI 
        //output  logic         slverr3, // GPIO
        //output  logic         slverr4, // FND 
        //output  logic  [31:0] rdata1,  // GPO
        //output  logic  [31:0] rdata2,  // GPI
        //output  logic  [31:0] rdata3,  // GPIO 
        //output  logic  [31:0] rdata4,  // FND





endmodule



module addr_decoder (
    input        en, 
    input [31:0] addr,
    output logic psel0,  // RAM 
    output logic psel1, // GPO
    output logic psel2, // GPI 
    output logic psel3, // GPIO  
    output logic psel4, // FND
    output logic psel5 // UART
);

always_comb begin 
        psel1 = 1'b0;  // idle : 0
        psel2 = 1'b0;  // idle : 0
        psel3 = 1'b0;  // idle : 0
        psel4 = 1'b0;  // idle : 0
        psel5 = 1'b0;  // idle : 0
        if(en)begin

        case (addr[31:28])    //instead of casex: but, Be careful using casex
            4'h1: psel0 = 1'b1; 
            4'h2: begin
                case (addr[15:12])
                    4'h0: psel1 = 1'b1;
                    4'h1: psel2 = 1'b1;
                    4'h2: psel3 = 1'b1;
                    4'h3: psel4 = 1'b1;
                    4'h4: psel5 = 1'b1;
                endcase
            end
        endcase
        end 
    end 

endmodule

module apb_mux (
    input [31:0]  sel,
    input [31:0]  prdata0,
    input [31:0]  prdata1,
    input [31:0]  prdata2,
    input [31:0]  prdata3,
    input [31:0]  prdata4,
    input [31:0]  prdata5,
    input         pready0,
    input         pready1,
    input         pready2,
    input         pready3,
    input         pready4,
    input         pready5,
    output logic [31:0] rdata,
    output logic  ready

);
    always_comb begin
        rdata = 32'h0000_0000;  // idle : 0
        ready = 1'b0;

        case (sel[31:28])    //instead of casex: but, Be careful using casex
            4'h1:begin
                rdata = prdata0;
                ready = pready0;
            end
            4'h2: begin
                case (sel[15:12])
                    4'h0:begin
                        rdata = prdata1;
                        ready = pready1;
                    end 
                    4'h1:begin
                        rdata = prdata1;
                        ready = pready1;
                    end 
                    4'h2: begin
                        rdata = prdata1;
                        ready = pready1;

                    end
                    4'h3:begin
                        rdata = prdata1;
                        ready = pready1;
                    end 
                    4'h4: begin
                        rdata = prdata1;
                        ready = pready1;

                    end
                endcase
            end
        endcase
    end 
    
    
endmodule

//    //STATE(APB Interface)
//    typedef enum logic [1:0] {
//        IDLE,
//        SETUP,
//        ACCESS
//    }state_e;
//
//
//    state_e c_state, n_state;
//
//
//    always_ff @( posedge PCLK, posedge PRESET ) begin
//        if(PRESET)begin
//            c_state <= IDLE; 
//        end else begin
//            c_state <= n_state;
//        end
//    end
//
//    //Wirte 
//    always_comb begin 
//        n_state = c_state;
//        paddr   = 32'd0;
//        pwrite  = 1'b0;
//        pselx   = 1'b0;
//        penable = 1'b0;
//        pwdata  = 1'b0;
//        slverr  = 1'b0;
//        rdata   = 32'd0;
//        ready   = 1'b0;
//        case (c_state)
//            IDLE:begin
//                pselx = 1'b0;
//                if(w_req == 1'b1 | r_req == 1'b1) begin
//                    n_state = SETUP;
//                end
//            end 
//            SETUP:begin
//                pselx = 1'b1;
//                penable = 1'b0;
//                if(penable == 1'b1)begin
//                    n_state = ACCESS;
//                end
//
//            end
//            ACCESS: begin
//                psel   = 1'b1;
//                penable = 1'b1;
//                if(pready == 1'b1)begin
//                    ready = 1'b1;
//                    if(pslverr == 1'b1)begin
//                        slverr = 1'b1;
//                    end else begin
//                        slverr = 1'b0;
//                    end
//                    if(w_req | r_req)begin
//                        n_state = SETUP;  
//                    end else begin
//                        n_state = IDLE;
//                    end
//                end else begin
//                    n_state = ACCESS;
//                end
//            end
//             
//        endcase
//        
//    end
//
//