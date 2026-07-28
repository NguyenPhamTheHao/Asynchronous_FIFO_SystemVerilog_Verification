interface interf #(parameter DATA_WIDTH=8,
                   parameter ADDR_WIDTH = 4) (
    input logic wclk,
    input logic rclk
);
//DUT input = TB output
logic w_rstn;
logic w_en;
logic [DATA_WIDTH-1:0] wr_data;

logic r_rstn;
logic r_en;
//DUT output =TB input
logic empty;
logic full;
logic [DATA_WIDTH-1:0] rd_data;
//Modport
modport TB(
    input full, empty, rd_data, wclk, rclk,
    output  w_rstn, r_rstn, w_en, r_en, wr_data
);
//SystemVerilog Assertion
`ifndef SYNTHESIS
//Assertion 1
property reset_write_domain;
    @(posedge wclk) $rose(w_rstn) |-> (!full) && 
                                     (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr =='0) &&
                                     (testbench.u_AsynFF.u_Write_Pointer_Handler.g_wptr =='0);
endproperty
check_reset_write_domain: assert property(reset_write_domain) 
    else $error("[SVA ERROR @%0t] Reset write domain FAIL: Full flag or Write pointer is not reset to 0 ",$time);

//Assertion 2
property reset_read_domain;
    @(posedge rclk) $rose(r_rstn) |-> (empty) &&
                                      (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr=='0) &&
                                      (testbench.u_AsynFF.u_Read_Pointer_Handler.g_rptr=='0) &&
                                      (rd_data =='0);
endproperty
check_reset_read_pointer: assert property(reset_read_domain) 
    else $error("[SVA] ERROR @%0t] Reset read domain FAIL: Empty flag or Read data or Read Pointer is Invalid", $time);

//Assertion 3
property no_write_when_full_state;
    @(posedge wclk) disable iff (!w_rstn)
    (w_en && full) |-> ($stable(testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr)) &&
                        ($stable(testbench.u_AsynFF.u_Write_Pointer_Handler.g_wptr));
endproperty
check_no_write_when_full_state: assert property(no_write_when_full_state) 
    else $error("[SVA] ERROR @%0t] No write when full state FAIL: Write operation still running when FIFO is Full",$time);

//Assertion 4
property no_read_when_empty_state;
    @(posedge wclk) disable iff (!r_rstn)
    (r_en && empty) |-> ($stable(testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr)) &&
                        ($stable(testbench.u_AsynFF.u_Read_Pointer_Handler.g_rptr));
endproperty
check_no_read_when_empty_state: assert property(no_read_when_empty_state) 
    else $error("[SVA] ERROR @%0t] No read when empty state FAIL: Read operation still running when FIFO is Empty",$time);

//Assertion 5
property write_ptr_increase_gray_code;
    logic [ADDR_WIDTH:0] expect_b_wptr;
    @(posedge wclk) disable iff (!w_rstn)
    (w_en && !full, expect_b_wptr=testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr+1'b1) 
    |=> (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr==expect_b_wptr) &&
        (testbench.u_AsynFF.u_Write_Pointer_Handler.g_wptr==(expect_b_wptr) ^ (expect_b_wptr>>1));
endproperty
check_write_ptr_increase_gray_code: assert property(write_ptr_increase_gray_code)
    else $error("[SVA] ERROR @%0t] Write pointer increase & Gray code check FAIL: Binary write pointer or Gray write pointer",$time);

//Assertion 6
property read_ptr_increase_gray_code;
        logic [ADDR_WIDTH:0] expected_b_rptr;
        @(posedge rclk) disable iff (!r_rstn)
        (r_en && !empty, expected_b_rptr = testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr + 1'b1) |=> 
        (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr == expected_b_rptr) &&
        (testbench.u_AsynFF.u_Read_Pointer_Handler.g_rptr == (expected_b_rptr ^ (expected_b_rptr >> 1)));
    endproperty
check_read_ptr_increase_gray_code: assert property(read_ptr_increase_gray_code)
    else $error("[SVA ERROR @%0t] Read Pointer or Gray Code Mismatch!", $time);

//Assertion 7
property multiclk_empty_deassert;
    @(posedge wclk) disable iff (!w_rstn || !r_rstn)
    (w_en && !full && empty) |-> ##1 @(posedge rclk) ##[0:3] !empty;
endproperty
    
check_multiclk_empty_deassert: assert property(multiclk_empty_deassert)
    else $error("[SVA ERROR @%0t] Multi-Clock Timeout: Empty flag did not drop on rclk after Write!", $time);    

//Assertion 8
property rollover_write_ptr;
    logic msb_b_wptr;
    @(posedge wclk) disable iff (!w_rstn)
    ( (w_en && !full) && (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr[ADDR_WIDTH-1:0]=='1), 
       msb_b_wptr=testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr[ADDR_WIDTH])
    |=> (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr[ADDR_WIDTH]==!msb_b_wptr) &&
        (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr[ADDR_WIDTH-1:0]=='0);
endproperty
check_rollover_write_ptr: assert property(rollover_write_ptr)
    else $error("[SVA ERROR @%0t] Rollover Write pointer FAIL",$time);

//Assertion 9
property rollover_read_ptr;
    logic msb_b_rptr;
    @(posedge rclk) disable iff (!r_rstn)
    ( (r_en && !empty) && (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr[ADDR_WIDTH-1:0]=='1), 
       msb_b_rptr=testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr[ADDR_WIDTH])
    |=> (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr[ADDR_WIDTH]==!msb_b_rptr) &&
        (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr[ADDR_WIDTH-1:0]=='0);
endproperty
check_rollover_read_ptr: assert property(rollover_read_ptr)
    else $error("[SVA ERROR @%0t] Rollover Read pointer FAIL",$time);

    cov_rollover_write_ptr: cover property (
        @(posedge wclk) disable iff (!w_rstn)
        ((w_en && !full) && (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr[ADDR_WIDTH-1:0] == '1))
        |=> (testbench.u_AsynFF.u_Write_Pointer_Handler.b_wptr[ADDR_WIDTH-1:0] == '0)
    );

    cov_rollover_read_ptr: cover property (
        @(posedge rclk) disable iff (!r_rstn)
        ((r_en && !empty) && (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr[ADDR_WIDTH-1:0] == '1))
        |=> (testbench.u_AsynFF.u_Read_Pointer_Handler.b_rptr[ADDR_WIDTH-1:0] == '0)
    );

    
    cov_multiclk_empty_deassert: cover property (
        @(posedge wclk) disable iff (!w_rstn || !r_rstn)
        (w_en && !full && empty) |-> ##1 @(posedge rclk) ##[0:3] !empty
    );
    `endif                                 
endinterface
