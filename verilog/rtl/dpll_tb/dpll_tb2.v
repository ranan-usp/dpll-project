`timescale 1ns / 1ps

module dpll_tb;
    reg clk;              // テスト用のクロック信号
    reg rst;              // リセット信号
    reg [1:0] freq_select;           // 周波数選択用入力
    reg clk_fin;           
    wire [1:0] io_out;    // DPLLの出力
    wire [1:0] io_oeb;    // DPLLの出力

    // DPLLモジュールのインスタンス化
    dpll dpll_inst (
        .wb_clk_i(clk),
        .wb_rst_i(rst),
        .freq_select(freq_select),
        .clk_fin(clk_fin),
        .io_out(io_out),
        .io_oeb(io_oeb)
    );
    
    assign io_oeb = 2'b00;

    always #12.5 clk <= ~clk; // 修正: クロック生成

    // クロック信号の生成
    initial begin
        $dumpfile("dpll.vcd");
        $dumpvars(0, dpll_tb);
        clk = 0;
        clk_fin = 0;
        rst = 1;
        #100;
        rst = 0;
        forever #20 clk_fin = ~clk_fin; // 修正: 100MHzのクロック
    end

    // テストシナリオ
    initial begin
        
        // freq_selectごとにリセットし、出力を観察
        #50000; // 安定化のためのウェイト
        freq_select = 2'b00;
        #50000;
        freq_select = 2'b01;
        #50000;
        freq_select = 2'b10;
        #50000;

        $finish;
    end

    // 結果の表示
    initial begin
        $monitor("Time = %t, clk_fin = %b, freq_select = %b, io_out = %b", $time, clk_fin, freq_select, io_out);
    end
endmodule
