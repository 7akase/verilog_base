`timescale 1ns / 1ps

module mcu_tb;

parameter TCK_HALF = 5;
parameter TCLK = 10;

reg clk;
reg reset_b;
reg [15:0] gpio_in1, gpio_in2;
wire [15:0] gpio_out1, gpio_out2;
wire ss, sclk, miso, mosi;

mcu mcu1(
  .clk       (clk)
, .reset_b   (reset_b)
, .gpio_in1  (gpio_in1)
, .gpio_in2  (gpio_in2)
, .gpio_out1 (gpio_out1)
, .gpio_out2 (gpio_out2)
, .ss        (ss)
, .sclk      (sclk)
, .miso      (miso)
, .mosi      (mosi)
);

//----------------------------------------------------------------------
initial          clk = 0;
always #TCK_HALF clk = ~clk;

initial begin
  reset_b = 1'b0;  #10 reset_b = 1'b1;
end

//----------------------------------------------------------------------


endmodule
