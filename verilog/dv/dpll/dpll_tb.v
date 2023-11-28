// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

module dpll_tb;
	reg clock;
	reg RSTB;
	reg power1;

	wire gpio;
	wire [37:0] mprj_io;

    reg io_in = 0;
	reg [1:0] freq_ctl = 2'b0;
	wire [1:0] mprj_io_0;

	assign mprj_io_0 = mprj_io[9:8];
	// assign mprj_io_0 = {mprj_io[8:4],mprj_io[2:0]};

	// assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;
	// assign mprj_io[3] = 1'b1;
	assign mprj_io[3] = 1'b1;       // Force CSB high.

	// External clock is used by default.  Make this artificially fast for the
	// simulation.  Normally this would be a slow clock and the digital PLL
	// would be the fast clock.
    assign mprj_io[10] = io_in;
	assign mprj_io[12:11] = freq_ctl;

    always #2.5 io_in <= (io_in === 1'b0);

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		$dumpfile("dpll.vcd");
		$dumpvars(0, dpll_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (50) begin
			repeat (1000) @(posedge clock);
			$display("MPRJ-IO state = %b ", mprj_io);
			$display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Test Mega-Project IO Ports (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test Mega-Project IO Ports (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end

	initial begin
	    // Observe Output pins [7:0]
		wait(mprj_io_0 == 2'b00);
		wait(mprj_io_0 == 2'b01);
		wait(mprj_io_0 == 2'b10);
		wait(mprj_io_0 == 2'b11);
		
		`ifdef GL
	    	$display("Monitor: Test 1 Mega-Project IO (GL) Passed");
		`else
		    $display("Monitor: Test 1 Mega-Project IO (RTL) Passed");
		`endif
	    $finish;
	end

	initial begin
		clock = 0;
		$display("START  MPRJ-IO state = %b ", mprj_io);
		RSTB <= 1'b0;
		#1000;
		RSTB <= 1'b1;	    // Release reset
		#2000;
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		#200;
		power1 <= 1'b1;
	end

	always @(mprj_io) begin
		#1 $display("MPRJ-IO state = %b ", mprj_io[9:8]);
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD;
	wire VSS;
	
	assign VDD = power1;
	assign VSS = 1'b0;

	caravel uut (
		.VDD 	  (VDD),
		.VSS	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("dpll.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

endmodule
`default_nettype wire