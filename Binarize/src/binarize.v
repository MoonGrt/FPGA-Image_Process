module binarization (
    // module clock
    input clk,   // 时钟信号
    input rst_n, // 复位信号（低有效）

    // 图像处理前的数据接口
    input       pre_frame_vsync,  // vsync信号
    input       pre_frame_hsync,  // hsync信号
    input       pre_frame_de,     // data enable信号
    input [7:0] color,

    // 图像处理后的数据接口
    output     post_frame_vsync,  // vsync信号
    output     post_frame_hsync,  // hsync信号
    output     post_frame_de,     // data enable信号
    output reg monoc,             // monochrome（1=白，0=黑）
    output     monoc_fall

    //user interface
);

    // reg define
    reg monoc_d0;
    reg pre_frame_vsync_d;
    reg pre_frame_hsync_d;
    reg pre_frame_de_d;

    //*****************************************************
    //**                    main code
    //*****************************************************

    assign monoc_fall       = (!monoc) & monoc_d0;
    assign post_frame_vsync = pre_frame_vsync_d;
    assign post_frame_hsync = pre_frame_hsync_d;
    assign post_frame_de    = pre_frame_de_d;

    // 寄存以找下降沿
    always @(posedge clk) begin
        monoc_d0 <= monoc;
    end

    // 二值化
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) monoc <= 1'b0;
        else if (color > 8'd90)  // 阈值
            monoc <= 1'b1;
        else monoc <= 1'b0;
    end

    // 延时2拍以同步时钟信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_frame_vsync_d <= 1'd0;
            pre_frame_hsync_d <= 1'd0;
            pre_frame_de_d    <= 1'd0;
        end else begin
            pre_frame_vsync_d <= pre_frame_vsync;
            pre_frame_hsync_d <= pre_frame_hsync;
            pre_frame_de_d    <= pre_frame_de   ;
        end
    end

endmodule
