`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2026 12:31:50 PM
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
        input clk100mhz,
        input reset,
        output videoon,
        output hsync,
        output vsync,
        output ptick,
        output [9:0] x,
        output [9:0] y
        );
        
    //videoon = should we show a pixel here or not
    //reset sets counters back to zero
    //hsync tells the screen when one horizontal line finishes and when to start the next scan line
    //vsync does the same for vertical.
    //p_tick indicates to advance a pixel. this will happen at a rate of 25Mhz
    
    //10 bits for x and y outputs, since we are counting a length and width of 800x525, so 10 bits per dimension will suffice
    //all these parameters are based on VGA standards
    parameter HD = 640; //horizontal display
    parameter HF = 48; //horizontal front porch
    parameter HB = 16; //horizontal back porch
    parameter HR = 96; //horizontal retrace
    parameter HMAX = HD+HF+HB+HR-1; //this eqauls 799 since there are 800 pixels; it is one less since this is the max counter value and the counter counts from zero
    parameter VD = 480; //vertical display
    parameter VF = 10; //vertical front porch
    parameter VB = 33; //vertical back porch
    parameter VR = 2; //vertical retrace
    parameter VMAX = VD+VF+VB+VR-1; //this equals 524 since there are 525 pixels. It is one less since this is the max counter value and the counter counts from zero
    
    reg [1:0] r25mhz;
    wire w25mhz;
    
    always @(posedge clk100mhz or posedge reset)
        if(reset)
            r25mhz <= 0;
        else
            r25mhz <= r25mhz + 1;
        
    assign w25mhz = (r25mhz == 0) ? 1 : 0; //assert the tick one fourth of the time
    
    reg [9:0] hcountreg, hcountnext;
    reg [9:0] vcountreg, vcountnext;
    reg vsyncreg, hsyncreg;
    wire vsyncnext, hsyncnext;
    
    //logic for how registers get updated
    always @(posedge clk100mhz or posedge reset)
        if(reset) begin
        vcountreg <= 0;
        hcountreg <= 0;
        vsyncreg <= 1'b0;
        hsyncreg <= 1'b0;
    end
    else begin
        vcountreg <= vcountnext;
        hcountreg <= hcountnext;
        vsyncreg <= vsyncnext;
        hsyncreg <= hsyncnext;
    end
    
    //horizontal counter
    always @(posedge w25mhz or posedge reset)
        if(reset)
            hcountnext <= 0;
        else
            if(hcountreg == HMAX) //we reached the end of the horizontal scan
                hcountnext <= 0;
            else //as long as we haven't hit the end of the horizontal line we need to keep incrementing 
                hcountnext <= hcountreg + 1;
    //vertical counter
    always @(posedge w25mhz or posedge reset)
        if(reset)
            vcountnext <= 0;
        else
            if(hcountreg == HMAX)
                if((vcountreg == VMAX))
                    vcountnext <= 0;
                else
                    vcountnext <= vcountreg + 1;
                    
    assign hsyncnext = (hcountreg >= (HD+HB) && hcountreg <= (HD+HB+HR-1));
    assign vsyncnext = (vcountreg >= (VD+VF) && vcountreg <= (VD+VF+VR-1));
    assign videoon = (hcountreg < HD) && (vcountreg < VD); //video is on only for pixels within our display resolution, which is 640 x 480
    
    //outputs
    assign hsync = hsyncreg;
    assign vsync = vsyncreg;
    assign x = hcountreg;
    assign y = vcountreg;
    assign ptick = w25mhz;
endmodule
