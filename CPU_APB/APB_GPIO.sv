`timescale 1ns / 1ps


module APB_GPIO(
    
        input                PCLK,               
        input                PRESET, 
        input  logic  [31:0] paddr,  
        input  logic  [31:0] PWDATA, 
        input  logic         penable,
        input  logic         pwrite,
        input  logic         psel,        
        output logic  [31:0] prdata,      
        output logic         pready,      
        inout  logic  [15:0] GPIO

    );

    localparam [11:0] GPIO_CTL_ADDR = 12'h000;
    localparam [11:0] GPIO_ODATA_ADDR = 12'h004;
    localparam [11:0] GPIO_IDATA_ADDR = 12'h008;
    logic [15:0] GPIO_ODATA_REG, GPIO_CTL_REG, GPIO_IDATA_REG;
    //logic [15:0] w_gpi;

    assign pready = (penable & psel) ? 1'b1 : 1'b0;

    assign prdata = (psel & ~pwrite) ? 
                    (paddr[11:0] == GPIO_CTL_ADDR) ?  {16'h0000,GPIO_CTL_REG} :
                    (paddr[11:0] == GPIO_ODATA_ADDR) ? {16'h0000,GPIO_ODATA_REG}: 
                    (paddr[11:0] == GPIO_IDATA_ADDR) ? {16'h0000,GPIO_IDATA_REG}: 
                    32'h0000_0000: 32'h0000_0000;

    always_ff @( posedge PCLK, posedge PRESET ) begin 
        if (PRESET) begin
            GPIO_CTL_REG   <= 16'h0000;
            GPIO_ODATA_REG <= 16'h0000;
            //GPIO_IDATA_REG <= 16'h0000;
        end else begin 
            if (pready) begin
                if(pwrite)begin
                case (paddr[11:0])
                GPIO_CTL_ADDR :  GPIO_CTL_REG   <=  PWDATA[15:0]; 
                GPIO_ODATA_ADDR: GPIO_ODATA_REG <=  PWDATA[15:0]; 
                endcase
                end 
                //else begin
                //    prdata <= GPIO_IDATA_REG;
                //end 
            end 
        //GPIO_IDATA_REG <= w_gpi;     
        end 
    end


        
        gpio U_GPIO (
            .ctl(GPIO_CTL_REG),
            .o_data(GPIO_ODATA_REG),
            .i_data(GPIO_IDATA_REG),
            .gpio(GPIO)
        );



endmodule


module gpio (
    input        [15:0] ctl,
    input        [15:0] o_data,
    output logic [15:0] i_data,
    inout  logic [15:0] gpio
);
    genvar i;
    generate
        for(i=0;i<16;i++)begin
            
            assign gpio[i] = ctl[i] ? o_data[i]:1'bz; 
            assign i_data[i] = ~ctl[i] ? gpio[i] : 1'bz;

        end
    endgenerate

    
endmodule