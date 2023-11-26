`timescale 1ns / 1ps

module dpll_tb;
    reg clk;              // テスト用のクロック信号
    reg rst;              // リセット信号
    wire [2:0] io_in;           // DPLLの入力クロック
    wire [1:0] io_out;    // DPLLの出力
    wire [1:0] io_oeb;    // DPLLの出力

    // DPLLモジュールのインスタンス化
    dpll dpll_inst (
        .wb_clk_i(clk),
        .wb_rst_i(rst),
        .io_in(io_in),
        .io_out(io_out),
        .io_oeb(io_oeb)
    );

    reg clk_in;
    reg freq_select;
    assign clk_in = io_in[0];
    assign freq_select = io_in[2:1];

    assign io_oeb = 2'b00;

    always #12.5 clk <= (clk === 1'b0);

    // クロック信号の生成
    initial begin
        $dumpfile("dpll.vcd");      // VCDファイル名を設定
        $dumpvars(0, dpll_tb);      // このテストベンチのすべての信号をダンプ
        clk_in = 0;
        forever #20 clk_in = ~clk_in; // 100MHzのクロック
    end

    // テストシナリオ
    initial begin

        freq_select = 2'b00
        rst = 1;        // リセットをアサート
        #100;
        rst = 0;        // リセットを解除

        // Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (25) begin
			repeat (1000) @(posedge clk_in);
			// $display("+1000 cycles");
		end

        freq_select = 2'b01
        rst = 1;        // リセットをアサート
        #100;
        rst = 0;        // リセットを解除

        // Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (25) begin
			repeat (1000) @(posedge clk_in);
			// $display("+1000 cycles");
		end

        $finish;        // シミュレーション終了
    end

    // 結果の表示
    initial begin
        $monitor("Time = %t, clk_in = %b, io_out = %b", $time, clk_in, io_out);
    end
endmodule