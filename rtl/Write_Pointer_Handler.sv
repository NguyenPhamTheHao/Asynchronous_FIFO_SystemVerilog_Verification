module Write_Pointer_Handler #(
	parameter ADDR_WIDTH=4,
	parameter DATA_WIDTH=8
) (
	input logic wclk,
	input logic w_rstn,
	input logic w_en,
	input logic full,
	input logic [ADDR_WIDTH:0] g_rptr,
	output logic [ADDR_WIDTH:0] g_wptr,
	output logic [ADDR_WIDTH:0] b_wptr,
	output logic [ADDR_WIDTH:0] g_rptr_sync_1
);
logic [ADDR_WIDTH:0] g_rptr_sync_0;
// Poiter counter
always @(posedge wclk or negedge w_rstn) begin
	if(!w_rstn) begin
		b_wptr<=5'b00000;
		g_wptr<=5'b00000;
		g_rptr_sync_0<=5'b00000;
		g_rptr_sync_1<=5'b00000;
		end
	else begin
		if(w_en && !full ) begin
			b_wptr<=b_wptr+1;
			g_wptr<=(b_wptr+1) ^ ( (b_wptr+1)>>1);
		end
		else begin
			b_wptr<=b_wptr;
			g_wptr<=g_wptr;
		end
		g_rptr_sync_0<=g_rptr;
		g_rptr_sync_1<=g_rptr_sync_0;
		end
end
endmodule

	
	