`include "global.vh"

`include "utils.sv"
`include "tasks.sv"

`timescale 1ns/100ps

module tb();
    integer i, ifh, ofh, dfh;

    // Frame buffer
    reg [`CHANNEL_SIZE - 1:0] mem[0:`MEM_SIZE];

    // Bitmap metadata
    integer width;
    integer height;
    integer size_of_data;
    integer offset_to_data;
    integer count;
    integer padding;
    integer bytes_per_pixel;

    // Inputs to DUT
    reg clk;
    reg reset_n;
    reg en;
    reg [`PIXEL_SIZE - 1:0] data;

    // Outputs from DUT
    wire [`PIXEL_SIZE - 1:0] out;

    // Instantiate the Device Under Test (DUT)
    top dut (
        .clk(clk),
        .reset_n(reset_n),
        .en(en),
        .data(data),
        .out(out)
    );

    // -----------------------
    // Initialization sequence
    // -----------------------
    initial begin
        // Initialize inputs
        clk = 0;
        reset_n = 0;
        count = 0;
        en = 0;

        // Take out of reset
        #20
        reset_n = 1;
        en = 1;
        data = 0;

        // Open files
        ifh = open_file(`IFILE, "rb");
        ofh = open_file(`OFILE, "wb");

        // Read bitmap
        read_bmp_head(
            .ifh(ifh),
            .width(width),
            .height(height),
            .size_of_data(size_of_data),
            .offset_to_data(offset_to_data),
            .padding(padding),
            .bytes_per_pixel(bytes_per_pixel)
        );

        read_bmp_data(
            .ifh(ifh),
            .bytes_per_row(width * bytes_per_pixel),
            .rows(height),
            .padding(padding),
            .mem(mem)
        );
    end

    // --------------------
    // Termination sequence
    // --------------------
    initial begin
        #`SIM_TIME

        // Write bitmap
        write_bmp_head(ifh, ofh);

        write_bmp_data(
            .ofh(ofh),
            .bytes_per_row(width * bytes_per_pixel),
            .rows(height),
            .padding(padding),
            .mem(mem)
        );

        // Close files
        $fclose(ifh);
        $fclose(ofh);

        // Exit
        $finish;
    end

    // ----------------
    // Clock generation
    // ----------------
    always
        #10 clk  = ~clk ;

    //-----------
    // Test logic
    //-----------
    always @ (posedge clk) begin
        /***** Input stimulus *****/
        data = {mem[count + 2], mem[count + 1], mem[count + 0]};

        /***** Output verification *****/
        mem[count + 0] = out[7:0];
        mem[count + 1] = out[15:8];
        mem[count + 2] = out[23:16];

        /***** Test bench logic *****/
        count += 3;
    end

endmodule
