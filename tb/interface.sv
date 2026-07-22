interface interf #(
	parameter DATA_WIDTH=8)
(	input logic wclk,
	input logic rclk
);
//DUT input = TB output
logic w_en;
logic w_rstn;
logic [DATA_WIDTH-1:0] wr_data;
logic r_en;
logic r_rstn;
//DUT output = TB input
logic empty;
logic full;
logic [DATA_WIDTH-1:0] rd_data;
//Modport Declaration
modport testbench(
	input empty, full, rd_data, wclk, rclk,
	output w_en, w_rstn, r_en, r_rstn, wr_data
);
endinterface