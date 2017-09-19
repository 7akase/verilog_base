`timescale 1ns / 1ps

module spi_master #(parameter W_ADDR=8, W_DATA=16)(
  input wire clk
, input wire reset_b
, input wire [W_ADDR-1:0] addr
, input wire [W_DATA-1:0] tx
, output reg [W_DATA-1:0] rx
, input wire en
, output wire ss
, output wire sclk
, input wire miso
, output reg mosi
);

reg en_d;
wire en_pe;
assign en_pe = {en_d, en} == 2'b01;
always @(posedge clk) begin
  if (~reset_b)  en_d <= 1'b0;
  else           en_d <= en;
end

assign ss = ~en;
assign sclk = (en & en_d) & clk;

reg [7:0] cnt;
reg [W_ADDR + W_DATA - 2:0] data;
always @(negedge clk) begin
  if(en_pe) begin
    {mosi, data} <= {addr, tx};
    rx <= {W_DATA{1'b0}};
  end
  else begin
    {mosi, data} <= data << 1;
    rx <= {rx[W_DATA-2:0], miso};
  end
end

endmodule
