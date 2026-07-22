module FIFO_mem #(
	parameter ADDR_WIDTH=4,
	parameter DATA_WIDTH=8
)(	//Write operation
	input logic wclk,
	input logic w_en,
	input logic [DATA_WIDTH-1:0] wr_data,
	input logic full,
	input logic [ADDR_WIDTH:0] b_wptr,
	//Read operation
	input logic rclk,
	input logic r_en,
	input logic r_rstn,
	input logic empty,
	input logic [ADDR_WIDTH:0] b_rptr,
	output logic [DATA_WIDTH-1:0] rd_data
);
//FIFO Capacity
localparam DEPTH=(1<<ADDR_WIDTH);
logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];
//Write process
always @(posedge wclk) begin
	if(w_en && !full) begin
	mem[b_wptr[ADDR_WIDTH-1:0]]<=wr_data;
	end
end
//Read Process
always @(posedge rclk) begin
	if(!r_rstn) begin
		rd_data<=0;
	end
	else begin
	if(r_en &&!empty) begin
	rd_data<=mem[b_rptr[ADDR_WIDTH-1:0]];
	end
end
end
endmodule

	