`timescale 1ns/10ps

// クラシックなSARアルゴリズムとオフセット校正を行うモジュール
module sarlogic(
    input           clk,        // クロック入力
    input           rstn,       // リセット信号 (負論理)
    input           en,         // 有効化信号
    input           comp,       // コンパレータの出力
    input           cal,        // 校正信号

    output          valid,      // 結果が有効かどうかを示す信号
    output  [9:0]   result,     // SAR ADCの結果
    
    output  		sample,     // サンプリング信号
    output  [9:0]   ctlp,       // 制御信号 (ポジティブ)
    output  [9:0]   ctln,       // 制御信号 (ネガティブ)
    output  [4:0]   trim,       // トリム値
    output  [4:0]   trimb,      // トリム値 (補数)
    output          clkc);      // クロック信号 (出力用)

    // 内部レジスタと状態の定義
    reg             calibrate;  // 校正モードのフラグ
    reg     [2:0]   state;      // 状態を保持するレジスタ
    reg     [9:0]   mask;       // マスクレジスタ
    reg     [4:0]   trim_mask;  // トリム用マスク
    reg     [9:0]   result;     // 結果を保持するレジスタ
    reg     [4:0]   trim_val;   // トリム値を保持するレジスタ
    reg             sample;     // サンプリングフラグ
    reg             co_clk;     // 外部クロック制御用
    reg             en_co_clk;  // 外部クロック有効化フラグ
    reg     [3:0]   cal_count;  // 校正カウンタ
    reg     [3:0]   cal_itt;    // 校正イテレーションカウンタ

    // 状態定数の定義
    parameter sInit=0, sWait=1, sSample=2, sConv=3, sDone=4, sCal=5;

    // 初期状態の設定
    initial begin
        state <= sInit;
        // 以下、各種レジスタの初期化
        mask <= 0;
        trim_mask <= 0;
        result <= 0;
        co_clk <= 0;
        en_co_clk <= 0;
        cal_itt <= 0;
        cal_count <= 7;
        trim_val <= 0;
        calibrate <= 0;
    end

    // 外部クロック信号の生成
    always @(clk) begin
        clkc <= (~clk & en_co_clk);
    end

     always @(posedge clk or negedge rstn) begin
        // ネガティブエッジのリセットまたはポジティブエッジのクロックに反応
        if (!rstn) begin
            // リセット信号がアクティブな場合、初期状態と初期値にリセット
            state <= sInit;
            mask <= 0;
            trim_mask <= 0;
            result <= 0;
            co_clk <= 0;
            en_co_clk <= 0;
            cal_itt <= 0;
            cal_count <= 7;
            trim_val <= 0;
            calibrate <= 0;
        end
        else begin
            // 状態マシンのロジック
            case (state)

                sInit : begin
                    // 初期状態：トリム値を設定し、待機状態に移行
                    trim_val <= 5'b10000;
                    state <= sWait;
                end

                sWait : begin
                    // 待機状態：有効信号がアクティブになるのを待つ
                    if(en) begin
                        // 有効化されたら、変数をリセットし、サンプル状態に移行
                        result <= 0;
                        cal_itt <= 0;
                        cal_count <= 7;
                        state <= sSample;
                        calibrate <= cal;
                        mask <= 10'b1000000000;
                        en_co_clk <= 1;
                    end
                    else state <= sWait;
                end

		    	sSample : begin
                    // サンプル状態：校正モードか変換モードかを判断
                    if (calibrate) begin
                        // 校正モードの場合、校正状態に移行
                        state <= sCal;
                        trim_val <= 5'b00000;
		    		    trim_mask <= 5'b10000;
                    end
                    else begin
                        // 変換モードの場合、変換状態に移行
                        state <= sConv;
                    end
		    	end

                sConv : begin
                    // 変換状態：コンパレータの出力に基づき結果を更新
                	if (comp) result  <= result | mask;
                    mask <= mask >> 1;                
                    if (mask[0]) begin
                        // 全ビットの処理が完了したら、完了状態に移行
                        state <= sDone;
                        en_co_clk <=0;
                    end
                end

                sCal: begin
                    // 校正状態：トリム値の調整を行う
                    if(cal_itt == 7) begin
                        if (cal_count > 7) begin
                            trim_val <= trim_val | trim_mask;
                        end
                        trim_mask <= trim_mask >> 1;
                        if (trim_mask[0]) begin
                            // トリム処理が完了したら、完了状態に移行
                            state <= sDone;
                            en_co_clk <=0;
                            calibrate <= 0;
                        end else begin
                            cal_itt = 0;
                            state <= sCal;
                        end 
                        cal_count <= 7;
                    end else begin
                        if (comp) begin
                            cal_count <= cal_count - 1;
                        end else begin
		    				cal_count <= cal_count + 1;
                        end
                        cal_itt <= cal_itt + 1;
                    end 
                end

                sDone : begin
                    // 完了状態：次のサイクルの待機状態に移行
                    state <= sWait;
                end

            endcase
        end
    end

    // 出力信号のアサイン
    assign trim   = (trim_val | trim_mask );
    assign trimb  = ~(trim_val | trim_mask);
    assign sample = (state==sSample) || (state==sCal);
    assign valid  = state==sDone;
	assign ctlp   = result | mask;
	assign ctln   = ~(result | mask);

endmodule
