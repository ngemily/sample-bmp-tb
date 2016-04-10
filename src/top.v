`include "global.vh"

/**
*  Expect one 24-bit RGB pixel per clock cycle.  Swaps R and B channels.
*/
module top (
    input clk,
    input reset_n,
    input en,
    input  [`PIXEL_SIZE - 1:0] data,
    output [`PIXEL_SIZE - 1:0] out
);
    // Section data into RGB channels
    wire [`CHANNEL_SIZE - 1:0] R = data[7:0];
    wire [`CHANNEL_SIZE - 1:0] G = data[15:8];
    wire [`CHANNEL_SIZE - 1:0] B = data[23:16];

    // Swap R and B channels.
    assign out = {R, G, B};
endmodule
