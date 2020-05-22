module dtr_tb;
    localparam SYSTEM_FREQUENCY = 15000000;

    bit[7:0] fpga_temperature;
    bit sys_resetn, sys_clk;

    FpgaTemperature #(
        .SYSTEM_FREQUENCY(SYSTEM_FREQUENCY),
        .MEASURE_INTERVAL_MS(10)
    )
    FpgaTemperature_instance
    (
        .o_Temperature(fpga_temperature),
        .i_Clk(sys_clk),
        .i_Enable(sys_resetn),
        .i_Rstn(sys_resetn)
    );

    initial begin
        sys_clk = 0;
        sys_resetn = 0;
        #1000;
        sys_resetn = 1;
        $display("Run simulation");
    end

    real period_1 = (1000000000.0/SYSTEM_FREQUENCY)/2.0;
    always #(period_1) sys_clk = !sys_clk;

endmodule : dtr_tb