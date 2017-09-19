`timescale 1ns / 1ps

module mcu(
  input wire clk
, input wire reset_b
, input wire [15:0] gpio_in1
, input wire [15:0] gpio_in2
, output wire [15:0] gpio_out1
, output wire [15:0] gpio_out2
, output wire ss
, output wire sclk
, input wire miso
, output wire mosi
);

//----------------------------------------------------------------------
reg [7:0] addr;
reg [15:0] tx;
wire [15:0] rx;
reg en;

spi_master #(8,16) spi_master_1 (
  .clk(clk)
, .reset_b(reset_b)
, .addr(addr)
, .tx(tx)
, .rx(rx)
, .en(en)
, .ss(ss)
, .sclk(sclk)
, .miso(miso)
, .mosi(mosi)
);

//----------------------------------------------------------------------
integer timer;

reg [3:0] state_next;
`define ST_RESET     4'h0
`define ST_SPI_WRITE 4'h1
`define ST_SPI_CLOSE 4'h2
`define ST_HALT      4'hF

task reset;
  begin
    en <= 1'b0;
    addr <= 8'h00;
    tx <= 16'h0000;
  end
endtask

task spi_write;
  input [7:0] a;
  input [15:0] d;
  begin
    en <= 1'b1;
    addr <= a;
    tx <= d;
    timer = 24;
  end
endtask

task spi_close;
  begin
    en <= 1'b0;
    timer = 5;
  end
endtask

//----------------------------------------------------------------------
always @(posedge clk) begin
  if(~reset_b) begin
    state_next = `ST_RESET;
    timer = 0;
  end
  else begin
    if(timer == 0)
      case (state_next)
        `ST_RESET     : begin reset;                     state_next = `ST_SPI_WRITE; end
        `ST_SPI_WRITE : begin spi_write(8'hAA, 16'hAAAB); state_next = `ST_SPI_CLOSE; end
        `ST_SPI_CLOSE : begin spi_close;                 state_next = `ST_HALT;      end
        `ST_HALT      : $stop;
        default       : begin                            state_next = `ST_HALT;      end
      endcase
    else
      timer = timer - 1;
  end
end

endmodule
