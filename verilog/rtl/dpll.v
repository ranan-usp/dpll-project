`default_nettype none

module dpll (

`ifdef USE_POWER_PINS
    inout vdd,	// User area 1 1.8V supply
    inout vss,	// User area 1 digital ground
`endif
    input wb_clk_i,              // Master clock
    input wb_rst_i,            // System reset (active high)
    input [1:0] freq_select,     // 周波数選択用入力
    input clk_fin,               // PLL clock input
    output [1:0] io_out,    // PLL output clock // PLL output 8x clock
    output [1:0] io_oeb    // PLL output clock // PLL output 8x clock

);

reg k_count_enable = 0;
reg [7:0] k_count;
reg k_count_down = 1;      // 1 to count down, 0 to count up
reg k_count_borrow = 0;
reg k_count_carry = 0;
reg id_increment = 0;
reg id_decrement = 0;
reg id_increment_done = 0;
reg id_decrement_done = 0;
reg id_out = 0;
reg [8:0] n_count;

reg clk_fout;
reg clk8x_fout;

assign io_out[0] = clk_fout;
assign io_out[1] = clk8x_fout;

assign io_oeb = 2'b00;

// Phase detector (simple XOR)
always@(*) begin
    k_count_enable = clk_fin ^ clk_fout;
end

// Up/down K-counter with borrow and carry outputs
always@(posedge wb_clk_i) begin
    if (wb_rst_i == 1'b1) begin
        k_count <= 0;
    end
    else if (k_count_enable == 1) begin
        if (k_count_down == 0) begin
            k_count <= k_count + 1;

            if (k_count == 8'hFF) begin
                k_count_carry <= 1;
            end
            else begin
                k_count_carry <= 0;
            end
        end
        else begin
            k_count <= k_count - 1;

            if (k_count == 8'h00) begin
                k_count_borrow <= 1;
            end
            else begin
                k_count_borrow <= 0;
            end
        end
    end
    else begin
        k_count_carry <= 0;
        k_count_borrow <= 0;
    end
end

// Generate increment command to the I/D counter from the K-counter's carry output
always@(posedge wb_clk_i) begin
    if (wb_rst_i == 1'b1) begin
        id_increment <= 0;
    end
    else if ((id_increment == 0) && (k_count_carry == 1)) begin
        id_increment <= 1;
    end
    else if (id_increment_done == 1) begin
        id_increment <= 0;
    end
end

// Generate decrement command to the I/D counter from the K-counter's borrow output
always@(posedge wb_clk_i) begin
    if (wb_rst_i == 1'b1) begin
        id_decrement <= 0;
    end
    else if ((id_decrement == 0) && (k_count_borrow == 1)) begin
        id_decrement <= 1;
    end
    else if (id_decrement_done == 1) begin
        id_decrement <= 0;
    end
end

// I/D counter: Generate the enable signal for the N-counter. When id_increment is received,
// add an additional 'high' cycle to id_out. When id_decrement is received, add an additional
// 'low' cycles to id_out.
always@(posedge wb_clk_i) begin
    if (wb_rst_i == 1'b1) begin
        id_out <= 0;
        id_increment_done <= 0;
        id_decrement_done <= 0;
    end
    else if (id_out == 0) begin
        if (id_decrement == 1) begin
            id_out <= 0;
            id_decrement_done <= 1;
        end
        else begin
            id_out <= 1;
            id_decrement_done <= 0;
        end
    end
    else if (id_out == 1) begin
        if (id_increment == 1) begin
            id_out <= 1;
            id_increment_done <= 1;
        end
        else begin
            id_out <= 0;
            id_increment_done <= 0;
        end
    end
end

// N-counter: Counter rate controlled by I/D counter
always@(posedge wb_clk_i) begin
    if (wb_rst_i == 1'b1) begin
        n_count <= 0;
    end
    else if (id_out == 1) begin
        n_count <= n_count + 1;
    end
end

always@(*) begin
    case(freq_select)
        2'b00: begin
            clk_fout = n_count[6];  // 既存の8倍周波数
            clk8x_fout = n_count[3]; // 既存の16倍周波数
        end
        2'b01: begin
            clk_fout = n_count[7];  // 4倍周波数
            clk8x_fout = n_count[6]; // 8倍周波数
        end
        2'b10: begin
            clk_fout = n_count[8];  // 2倍周波数
            clk8x_fout = n_count[7]; // 4倍周波数
        end
        2'b11: begin
            clk_fout = n_count[8];  // 2倍周波数
            clk8x_fout = n_count[7]; // 4倍周波数
        end
        
        // 他のケースを追加できます
    endcase
end
endmodule
