module Read_Pointer_Handler #(
	parameter ADDR_WIDTH=4,
	parameter DATA_WIDTH=8
) (
	input logic rclk,
	input logic r_rstn,
	input logic r_en,
	input logic empty,
	input logic [ADDR_WIDTH:0] g_wptr,
	output logic [ADDR_WIDTH:0] g_rptr,
	output logic [ADDR_WIDTH:0] b_rptr,
	output logic [ADDR_WIDTH:0] g_wptr_sync_1
);
logic [ADDR_WIDTH:0] g_wptr_sync_0;
// Poiter counter
always @(posedge rclk or negedge r_rstn) begin
	if(!r_rstn) begin
		b_rptr<=5'b00000;
		g_rptr<=5'b00000;
		g_wptr_sync_0<=5'b00000;
		g_wptr_sync_1<=5'b00000;
		end
	else begin
		if(r_en && !empty) begin
			b_rptr<=b_rptr+1;
			g_rptr<=(b_rptr+1) ^ ( (b_rptr+1)>>1);
		end
		else begin
			b_rptr<=b_rptr;
			g_rptr<=g_rptr;
		end
		g_wptr_sync_0<=g_wptr;
		g_wptr_sync_1<=g_wptr_sync_0;
		end
end
endmodule
	
	
	