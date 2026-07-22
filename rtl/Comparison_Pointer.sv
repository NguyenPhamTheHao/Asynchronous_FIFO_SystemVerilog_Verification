module Comparison_Pointer #(
	parameter ADDR_WIDTH=4,
	parameter DATA_WIDTH=8
) (
	input logic [ADDR_WIDTH:0] g_wptr,
	input logic [ADDR_WIDTH:0] g_rptr,
	input logic [ADDR_WIDTH:0] g_wptr_sync_1,
	input logic [ADDR_WIDTH:0] g_rptr_sync_1,
	output logic empty,
	output logic full
);
//Interface of Gray to Binayry
logic [ADDR_WIDTH:0] g_wptr_g2b;
logic [ADDR_WIDTH:0] g_rptr_g2b;
logic [ADDR_WIDTH:0] g_wptr_sync_1_g2b;
logic [ADDR_WIDTH:0] g_rptr_sync_1_g2b;
//Function of converting Gray to Binary
function automatic [ADDR_WIDTH:0] gray2bin(input logic [ADDR_WIDTH:0] gray);
	integer i;
	begin
	gray2bin[ADDR_WIDTH]=gray[ADDR_WIDTH];
	for(i=ADDR_WIDTH-1;i>=0;i=i-1) gray2bin[i]=gray2bin[i+1]^gray[i];
	end
endfunction
//Converting Gray to Binary
assign g_wptr_g2b=gray2bin(g_wptr);
assign g_rptr_g2b=gray2bin(g_rptr);
assign g_wptr_sync_1_g2b=gray2bin(g_wptr_sync_1);
assign g_rptr_sync_1_g2b=gray2bin(g_rptr_sync_1);
//Full Empty logic
assign empty=(g_rptr_g2b==g_wptr_sync_1_g2b);
assign full=(g_wptr_g2b[ADDR_WIDTH]!=g_rptr_sync_1_g2b[ADDR_WIDTH]) &&(g_wptr_g2b[ADDR_WIDTH-1:0]==g_rptr_sync_1_g2b[ADDR_WIDTH-1:0]);
endmodule