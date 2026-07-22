module AsynFF #(
	parameter ADDR_WIDTH=4,
	parameter DATA_WIDTH=8
) (
	input logic wclk,
	input logic w_en,
	input logic w_rstn,
	input logic [DATA_WIDTH-1:0] wr_data,
	//Read operation
	input logic rclk,
	input logic r_en,
	input logic r_rstn,
	output logic [DATA_WIDTH-1:0] rd_data,
	output logic empty,
	output logic full
);
//Interface for WPH
logic [ADDR_WIDTH:0] b_wptr;
logic [ADDR_WIDTH:0] g_wptr;
//Interface for RPH
logic [ADDR_WIDTH:0] b_rptr;
logic [ADDR_WIDTH:0] g_rptr;
//Interface for Comparison Pointer
logic [ADDR_WIDTH:0] g_wptr_sync_1;
logic [ADDR_WIDTH:0] g_rptr_sync_1;
//Instance
FIFO_mem #(
	.ADDR_WIDTH	(ADDR_WIDTH),
	.DATA_WIDTH	(DATA_WIDTH)
)u_FIFO_mem 
(	.wclk		(wclk),
	.w_en		(w_en),
	.b_wptr		(b_wptr),
	.wr_data	(wr_data),
	.rclk		(rclk),
	.r_en		(r_en),
	.r_rstn		(r_rstn),
	.b_rptr		(b_rptr),
	.rd_data	(rd_data),
	.empty		(empty),
	.full		(full)
);
Write_Pointer_Handler  #(
	.ADDR_WIDTH	(ADDR_WIDTH),
	.DATA_WIDTH	(DATA_WIDTH)
)u_Write_Pointer_Handler
 (	.wclk		(wclk),
	.w_rstn		(w_rstn),
	.w_en		(w_en),
	.full		(full),
	.g_wptr		(g_wptr),
	.b_wptr		(b_wptr),
	.g_rptr		(g_rptr),
	.g_rptr_sync_1	(g_rptr_sync_1)
);
Read_Pointer_Handler  #(
	.ADDR_WIDTH	(ADDR_WIDTH),
	.DATA_WIDTH	(DATA_WIDTH)
)u_Read_Pointer_Handler
 (	.rclk		(rclk),
	.r_rstn		(r_rstn),
	.r_en		(r_en),
	.empty		(empty),
	.g_rptr		(g_rptr),
	.b_rptr		(b_rptr),
	.g_wptr		(g_wptr),
	.g_wptr_sync_1	(g_wptr_sync_1)
);
Comparison_Pointer  #(
	.ADDR_WIDTH	(ADDR_WIDTH),
	.DATA_WIDTH	(DATA_WIDTH)
)u_Comparison_Pointer 
(	.g_wptr		(g_wptr),
	.g_rptr		(g_rptr),
	.g_rptr_sync_1	(g_rptr_sync_1),
	.g_wptr_sync_1	(g_wptr_sync_1),
	.full		(full),
	.empty		(empty)
);
endmodule
