`include "timescale.v"

module FpgaTemperature #(
    parameter SYSTEM_FREQUENCY = 15000000,
    parameter MEASURE_INTERVAL_MS = 5000
)
(
    output logic [7:0] o_Temperature,
    input i_Enable,
    input i_Clk,
    input i_Rstn
);
    localparam ONE_CLOCK_TIME_NS = 1000000000/SYSTEM_FREQUENCY;
    localparam TEMP_CLOCK_VALUE = (MEASURE_INTERVAL_MS * 1000000)/ONE_CLOCK_TIME_NS;
    localparam TEMP_CALC_TICKS = 71000 / ONE_CLOCK_TIME_NS;

    logic [$clog2(TEMP_CLOCK_VALUE)-1:0] count;
    logic [7:0] dtr_out;
    logic start_pulse;
    logic state;

    DTR DTR_Instance
    (
        .STARTPULSE(start_pulse),
        .DTROUT7(dtr_out[7]),
        .DTROUT6(dtr_out[6]),
        .DTROUT5(dtr_out[5]),
        .DTROUT4(dtr_out[4]),
        .DTROUT3(dtr_out[3]),
        .DTROUT2(dtr_out[2]),
        .DTROUT1(dtr_out[1]),
        .DTROUT0(dtr_out[0])
    );

    always @(posedge i_Clk or negedge i_Rstn) begin
        if(i_Rstn == 0) begin
            start_pulse <= 1'b0;
            count <= '0;
            o_Temperature <= '0;
            state <= 1'b0;
        end else begin
            if(i_Enable) begin
                if(state == 0) begin
                    if(count < TEMP_CLOCK_VALUE)
                        count <= count + 1'b1;
                    else begin
                        count <= '0;
                        state <= 1'b1;
                        start_pulse <= 1'b1;
                    end
                end else begin
                    start_pulse <= 1'b0;
                    if(count < TEMP_CALC_TICKS)
                        count <= count + 1'b1;
                    else begin
                        o_Temperature <= dtr_out;
                        count <= '0;
                        state <= 1'b0;
                    end
                end
            end else begin
                start_pulse <= 1'b0;
                count <= '0;
                state <= 1'b0;
            end
        end
    end

endmodule : FpgaTemperature
