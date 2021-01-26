
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module M2 (
	input logic Clock,
	input logic resetn,
	input logic [15:0] SRAM_read_data,
	input logic start,
	
	output logic [17:0] SRAM_address,
	output logic done,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n
);

M2_state_type M2_state;

logic rw_switch_flag;
logic ct_flag;

logic [6:0] address_a[2:0];
logic [6:0] address_b[2:0];
logic [31:0] write_data_a [2:0];
logic [31:0] write_data_b [2:0];
logic write_enable_a [2:0];
logic write_enable_b [2:0];
logic [31:0] read_data_a [2:0];
logic [31:0] read_data_b [2:0];

logic signed [31:0] Mult1_op;
logic signed [31:0] Mult2_op;
logic signed [31:0] Mult3_op;
logic signed [31:0] Mult4_op;

logic signed [15:0] C_0;
logic signed [15:0] C_1;
logic signed [15:0] C_2;
logic signed [15:0] C_3;

logic signed[31:0] S0,S0_buf,S8,S8_buf,S8_buf2;
logic [7:0] S0_w,S0_buf_w,S8_w,S8_buf_w,S8_buf2_w;
logic [6:0] S_0_base;
logic [6:0] S_8_base;
logic [6:0] add_buf1;
logic [6:0] add_buf2;


logic [6:0] ct_counter;
logic [6:0] ct_counter2;
logic [6:0] ct_counter3;
logic [6:0] cs_counter;
logic [6:0] cs_counter2;
logic [6:0] ws_counter;


logic [17:0] SRAM_base;

logic signed [31:0] T0;
logic signed [31:0] T1;
logic signed [31:0] T2;
logic signed [31:0] T3;
logic signed [31:0] T4;
logic signed [31:0] T5;
logic signed [31:0] T6;
logic signed [31:0] T7;
logic signed [31:0] T6_buf;
logic signed [31:0] T7_buf;

logic signed [15:0] ct_y_buff;


dual_port_RAM0 dual_port_RAM_inst0 (
	.address_a ( address_a[0] ),
	.address_b ( address_b[0] ),
	.clock ( Clock ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
);

dual_port_RAM1 dual_port_RAM_inst1 (
	.address_a ( address_a[1] ),
	.address_b ( address_b[1] ),
	.clock ( Clock ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
);

dual_port_RAM2 dual_port_RAM_inst2 (
	.address_a ( address_a[2] ),
	.address_b ( address_b[2] ),
	.clock ( Clock ),
	.data_a ( write_data_a[2] ),
	.data_b ( write_data_b[2] ),
	.wren_a ( write_enable_a[2] ),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
);
	

logic [2:0] row_index, col_index;
logic [17:0] row_address, col_address;
logic [5:0] row_block_index;
logic [5:0] col_block_index;
logic [1:0] yuv_block_select;  
logic [5:0] max_col_block;
logic [7:0] ra;
logic [17:0] write_offset;
logic [17:0] write_offset0;

assign ra = {row_block_index[4:0], row_index};
assign row_address = (yuv_block_select == 2'd0) ? ({2'd0, ra, 8'd0} + {4'd0, ra, 6'd0}) : ({3'd0, ra, 7'd0} + {5'd0, ra, 5'd0})  ;


assign col_address = {col_block_index, col_index};

	
assign max_col_block = (yuv_block_select == 2'd0) ? 6'd39 : 6'd19;
	
logic [15:0] s_prime_buf;

logic [17:0] BASE_ADDRESS;
assign BASE_ADDRESS = (yuv_block_select == 2'd0) ? Y_BASE_ADDRESS : (yuv_block_select == 2'd1) ? U_BASE_ADDRESS : V_BASE_ADDRESS;

logic signed [31:0] Mult1_result;
logic signed [31:0] Mult2_result;
logic signed [31:0] Mult3_result;
logic signed [31:0] Mult4_result;

assign S0_buf_w = (S0_buf[31]) ? 8'd0 : (|S0_buf[30:24]) ? 8'd255 : S0_buf[23:16];
assign S0_w = (S0[31]) ? 8'd0 : (|S0[30:24]) ? 8'd255 : S0[23:16];
assign S8_buf_w = (S8_buf[31]) ? 8'd0 : (|S8_buf[30:24]) ? 8'd255 : S8_buf[23:16];
assign S8_w = (S8[31]) ? 8'd0 : (|S8[30:24]) ? 8'd255 : S8[23:16];
assign S8_buf2_w = (S8_buf2[31]) ? 8'd0 : (|S8_buf2[30:24]) ? 8'd255 : S8_buf2[23:16];

assign write_offset = (yuv_block_select == 2'd0) ? 18'd1119 : 18'd559;
assign write_offset0 = (yuv_block_select == 2'd0) ? 18'd157 : 18'd77;

assign Mult1_result  = Mult1_op*C_0;
assign Mult2_result = Mult2_op*C_1;
assign Mult3_result = Mult3_op*C_2;
assign Mult4_result = Mult4_op*C_3;

always_ff @ (posedge Clock or negedge resetn) begin
	if (resetn == 1'b0) begin
		done <= 1'd0;
		address_a[2] <= 7'd0;
		address_b[2] <= 7'd0;
		address_a[1] <= 7'd0;
		address_b[1] <= 7'd0;
		address_a[0] <= 7'd0;
		address_b[0] <= 7'd0;
		write_data_a[2] <= 32'd0;
		write_data_b[2] <= 32'd0;
		write_data_a[1] <= 32'd0;
		write_data_b[1] <= 32'd0;
		write_data_a[0] <= 32'd0;
		write_data_b[0] <= 32'd0;
		write_enable_a [2] <= 1'b0;
		write_enable_b [2] <= 1'b0;
		write_enable_a [1] <= 1'b0;
		write_enable_b [1] <= 1'b0;
		write_enable_a [0] <= 1'b0;
		write_enable_b [0] <= 1'b0;
		SRAM_we_n <= 1'b1;
		SRAM_address <= 18'd0;
		
		T0 <= 32'd0;
		T1 <= 32'd0;
		T2 <= 32'd0;
		T3 <= 32'd0;
		T4 <= 32'd0;
		T5 <= 32'd0;
		T6 <= 32'd0;
		T7 <= 32'd0;
		T6_buf <= 32'd0;
		T7_buf <= 32'd0;
		
		S0 <= 32'd0;
		S8 <= 32'd0;
		S0_buf <= 32'd0;
		S8_buf <= 32'd0;
		
		SRAM_base <= 18'd0;
		row_index <= 3'd0;
		col_index <= 3'd0;
		row_block_index <= 6'd0;
		col_block_index <= 6'd0;
		yuv_block_select <= 2'd0;
		
		s_prime_buf <= 15'd0;
		
		ct_flag <= 1'b0;
		rw_switch_flag <= 1'b0;
		
		M2_state <= M2_IDLE0;
		
	end else begin
		case (M2_state)
		M2_IDLE0: begin
			if (start) begin
				SRAM_address <= BASE_ADDRESS + row_address + col_address;
				col_index <= col_index + 3'd1;
				M2_state <= M2_IDLE1;
				address_a[2] <= 7'd0;
			end
		end
		M2_IDLE1: begin
			SRAM_address <= BASE_ADDRESS + row_address + col_address;
			col_index <= col_index + 3'd1;
			M2_state <= M2_IDLE2;
		end
		M2_IDLE2: begin
			SRAM_address <= BASE_ADDRESS + row_address + col_address;
			col_index <= col_index + 3'd1;
			M2_state <= LI_fetch_s_prime_cc;
		end
		LI_fetch_s_prime_cc: begin
			if (col_index == 3'd7) begin
				if (row_index == 3'd7) begin
					SRAM_address <= BASE_ADDRESS + row_address + col_address;
					row_index <= 3'd0;
					col_index <= 3'd0;
					M2_state <= LI_fetch_s_prime_lo0;
					
					address_a[2] <= address_a[2] + 7'd1;
					s_prime_buf <= SRAM_read_data;
					write_enable_a[2] <= 1'b0;
					
					rw_switch_flag <= ~rw_switch_flag;
						
				end else begin
					SRAM_address <= BASE_ADDRESS + row_address + col_address;
					col_index <= 3'd0;
					row_index <= row_index + 3'd1;
					
					s_prime_buf <= SRAM_read_data;
					address_a[2] <= address_a[2] + 7'd1;
					write_enable_a[2] <= 1'b0;	
					rw_switch_flag <= ~rw_switch_flag;											
				end
			end else begin
				SRAM_address <= BASE_ADDRESS + row_address + col_address;
				col_index <= col_index + 3'd1;
				if ( rw_switch_flag == 1'b0) begin
					s_prime_buf <= SRAM_read_data;
					write_enable_a[2] <= 1'b0;
					rw_switch_flag <= ~rw_switch_flag;
					if (SRAM_address != 18'd76802) begin
						address_a[2] <= address_a[2] + 7'd1;
					end
				end else begin
					write_data_a[2] <= {s_prime_buf, SRAM_read_data};
					write_enable_a[2] <= 1'b1;
					rw_switch_flag <= ~rw_switch_flag;
				end
			end
		end
		
		LI_fetch_s_prime_lo0: begin
			write_data_a[2] <= {s_prime_buf, SRAM_read_data};
			write_enable_a[2] <= 1'b1;		
			M2_state <= LI_fetch_s_prime_lo1;
		end
		
		LI_fetch_s_prime_lo1: begin
			address_a[2] <= address_a[2] + 7'd1;
			s_prime_buf <= SRAM_read_data;
			write_enable_a[2] <= 1'b0;
			M2_state <= LI_fetch_s_prime_lo2;
		end
	
		LI_fetch_s_prime_lo2: begin
			write_data_a[2] <= {s_prime_buf, SRAM_read_data};
			write_enable_a[2] <= 1'b1;	
			col_block_index <= col_block_index + 6'd1;
			
			
			M2_state <= LI_CT_0;	
		end
				
		
		LI_CT_0:begin
			ct_counter <= 7'd0;
			address_a[0] <= 7'd0;
			address_b[0] <= 7'd1;
			address_a[2] <= 7'd0;
			address_a[1] <= 7'd0;
			address_b[1] <= 7'd1;	
	
			write_enable_a[2] <= 1'b0;
			
			M2_state <= LI_CT_1;
		end

		LI_CT_1: begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
			M2_state <= LI_CT_2;
		end		
		
		LI_CT_2:begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;

			
			Mult1_op <= $signed(read_data_a[2][31:16]);
			Mult2_op <= $signed(read_data_a[2][31:16]);
			Mult3_op <= $signed(read_data_a[2][31:16]);
			Mult4_op <= $signed(read_data_a[2][31:16]);
			ct_y_buff <= $signed(read_data_a[2][15:0]);
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);
			
			M2_state <= LI_CT_cc0;
		end
		
		LI_CT_cc0:begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
			ct_counter <= ct_counter+7'd1;
			if (ct_counter != 7'd0) begin
				ct_counter2 <= ct_counter;
			end
			
			if (ct_flag) begin
				address_a[0] <= address_a[0] + 7'd2;
				address_b[0] <= address_b[0] + 7'd2;
				write_data_a[0] <= T2>>>8;
				write_data_b[0] <= T3>>>8;
			end
			
			if(ct_counter % (7'd8) == 7'd0) begin
				T0 <= Mult1_result;
				T1 <= Mult2_result;
				T2 <= Mult3_result;
				T3 <= Mult4_result;			
			end else begin
				T0 <= T0 + Mult1_result;
				T1 <= T1 + Mult2_result;
				T2 <= T2 + Mult3_result;
				T3 <= T3 + Mult4_result;
			end
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);
			
			M2_state <= LI_CT_cc1;
		end
		
		LI_CT_cc1:begin
			address_a[2] <= address_a[2]+7'd1;		
			ct_counter3 <= ct_counter + 7'd1;
			if ((address_a[1] == 7'd30) && (address_b[1] == 7'd31)) begin
				address_a[1] <= 7'd0;
				address_b[1] <= 7'd1;
			end else begin
				address_a[1] <= address_a[1]+7'd2;
				address_b[1] <= address_b[1]+7'd2;
			end
			
			if (ct_flag) begin
				address_a[0] <= address_a[0] + 7'd2;
				address_b[0] <= address_b[0] + 7'd2;
				write_data_a[0] <= T4>>>8;
				write_data_b[0] <= T5>>>8;
				T6_buf <= T6;
				T7_buf <= T7;
			end
			

			
			Mult1_op <= ct_y_buff;
			Mult2_op <= ct_y_buff;
			Mult3_op <= ct_y_buff;
			Mult4_op <= ct_y_buff;
			
			if(ct_counter2 % (7'd8) == 7'd0) begin
				T4 <= Mult1_result;
				T5 <= Mult2_result;
				T6 <= Mult3_result;
				T7 <= Mult4_result;			
			end else begin
				T4 <= T4 + Mult1_result;
				T5 <= T5 + Mult2_result;
				T6 <= T6 + Mult3_result;
				T7 <= T7 + Mult4_result;
			end
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);
			
			M2_state <= LI_CT_cc2;
		end
		
		LI_CT_cc2:begin
			//address_a[2] <= address_a[2]+7'd1;
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
			ct_counter <= ct_counter+7'd1;			
			
			if (ct_counter3 % (7'd8) == 7'd0) begin
				ct_flag <= ~ ct_flag;
			end
			
			if (ct_flag) begin
				address_a[0] <= address_a[0] + 7'd2;
				address_b[0] <= address_b[0] + 7'd2;
				write_data_a[0] <= T6_buf>>>8;
				write_data_b[0] <= T7_buf>>>8;
				ct_flag <= ~ct_flag;
			end
			
			T0 <= T0+Mult1_result;			
			T1 <= T1+Mult2_result;
			T2 <= T2+Mult3_result;
			T3 <= T3+Mult4_result;
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);
			
			M2_state <= LI_CT_cc3;
		end
		
		LI_CT_cc3:begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
		

			
			if (ct_flag) begin
				write_enable_a [0] <= 1'b1;
				write_enable_b [0] <= 1'b1;
				write_data_a[0] <= T0>>>8;
				write_data_b[0] <= T1>>>8;
				if(ct_counter != 7'd8) begin
					address_a[0] <= address_a[0]+7'd2;
					address_b[0] <= address_b[0]+7'd2;				
				end
			end else begin
				write_enable_a [0] <= 1'b0;
				write_enable_b [0] <= 1'b0;
			end
			
			T4 <= T4+Mult1_result;			
			T5 <= T5+Mult2_result;
			T6 <= T6+Mult3_result;
			T7 <= T7+Mult4_result;
			
			if(ct_counter != 7'd64)begin
				Mult1_op <= $signed(read_data_a[2][31:16]);
				Mult2_op <= $signed(read_data_a[2][31:16]);
				Mult3_op <= $signed(read_data_a[2][31:16]);
				Mult4_op <= $signed(read_data_a[2][31:16]);
				ct_y_buff <= $signed(read_data_a[2][15:0]);
				
				C_0 <= $signed(read_data_a[1][31:16]);
				C_1 <= $signed(read_data_a[1][15:0]);
				C_2 <= $signed(read_data_b[1][31:16]);
				C_3 <= $signed(read_data_b[1][15:0]);
				
				M2_state <= LI_CT_cc0;
			end
			else begin
				M2_state <= LO_CT0;
			end
		end			
		
		LO_CT0:begin
			ct_counter <= 7'd0;
		   ct_flag <= 1'b0;
			address_a[1] <= 7'd0;
			address_b[1] <= 7'd0;	
			address_a[0] <= address_a[0] + 7'd2;
			address_b[0] <= address_b[0] + 7'd2;
			write_data_a[0] <= T2>>>8;
			write_data_b[0] <= T3>>>8;
			
			M2_state <= LO_CT1;
		end
		
		LO_CT1:begin
			address_a[0] <= address_a[0] + 7'd2;
			address_b[0] <= address_b[0] + 7'd2;
			write_data_a[0] <= T4>>>8;
			write_data_b[0] <= T5>>>8;
			
			M2_state <= LO_CT2;
		end
		
		LO_CT2:begin
			address_a[0] <= address_a[0] + 7'd2;
			address_b[0] <= address_b[0] + 7'd2;
			write_data_a[0] <= T6_buf>>>8;
			write_data_b[0] <= T7_buf>>>8;
			
			M2_state <= LI_CS_FS;
			

		end
		
		LI_CS_FS: begin
			cs_counter2 <= 7'd0;
			//cs_counter3 <= 7'd0;
			
			write_enable_a [0] <= 1'b0;
			write_enable_b [0] <= 1'b0;
			address_a[1] <= 7'd0;
			address_b[1] <= 7'd4;
			address_a[0] <= 7'd0;
			address_b[0] <= 7'd8;	
		
			M2_state <= LI_CS_FS_0;
		end
		
		LI_CS_FS_0:begin

		
			address_a[2] <= 7'd0;
			address_b[2] <= 7'd64;
			
			//S_0_base <= 7'd64;
			//S_8_base <= 7'd70;

			//address_a[1] <= address_a[1]+7'd8;
			//address_b[1] <= address_b[1]+7'd8;
			//address_a[0] <= address_a[0]+7'd16;
			//address_b[0] <= address_b[0]+7'd16;		
			
			cs_counter <= 7'b0;

			SRAM_address <= BASE_ADDRESS + row_address + col_address;
			col_index <= col_index+3'd1;
			M2_state <= LI_CS_FS_1;
		end
		
		LI_CS_FS_1:begin
			address_a[1] <= address_a[1]+7'd8;
			address_b[1] <= address_b[1]+7'd8;
			address_a[0] <= address_a[0]+7'd16;
			address_b[0] <= address_b[0]+7'd16;
			
			SRAM_address <= BASE_ADDRESS + row_address + col_address;
			col_index <= col_index + 1'd1;
			
			C_0 <= $signed(read_data_a[1][31:16]);		//0
			C_1 <= $signed(read_data_a[1][15:0]);			//1
			C_2 <= $signed(read_data_b[1][31:16]);		//8
			C_3 <= $signed(read_data_b[1][15:0]);			//9
			Mult1_op <= read_data_a[0];			//T0
			Mult2_op <= read_data_a[0];			//T0
			Mult3_op <= read_data_b[0];			//T8
			Mult4_op <= read_data_b[0];			//T8
			
			M2_state <= LI_CS_FS_2;
		end
		
		LI_CS_FS_2:begin
			M2_state <= CC_CS_FS_0;
			
			address_a[1] <= address_a[1]+7'd8;
			address_b[1] <= address_b[1]+7'd8;
			address_a[0] <= address_a[0]+7'd16;
			address_b[0] <= address_b[0]+7'd16;
			
			add_buf1 <= 7'd0;
			add_buf2 <= 7'd4;
			
			SRAM_address <= BASE_ADDRESS + row_address + col_address;
			col_index <= col_index + 1'd1;
		end
		
		CC_CS_FS_0:begin	
			cs_counter2 <= cs_counter + 7'd1;
			
			address_a[0] <= address_a[0] + 7'd16;
			address_b[0] <= address_b[0] + 7'd16;
			address_a[1] <= address_a[1] + 7'd8;
			address_b[1] <= address_b[1] + 7'd8;	
			
			S0 <= Mult1_result + Mult3_result;			
			S8 <= Mult2_result + Mult4_result;
						
			C_0 <= $signed(read_data_a[1][31:16]);		//16
			C_1 <= $signed(read_data_a[1][15:0]);			//17
			C_2 <= $signed(read_data_b[1][31:16]);		//24
			C_3 <= $signed(read_data_b[1][15:0]);			//25
			Mult1_op <= read_data_a[0];			//T16
			Mult2_op <= read_data_a[0];			//T16
			Mult3_op <= read_data_b[0];			//T24
			Mult4_op <= read_data_b[0];			//T24
			
			if (cs_counter % (7'd2) == 7'd1) begin
				S0_buf <= S0;
				S8_buf <= S8;
			end
			
			if(cs_counter!= 7'd0) begin
				S8_buf2 <= S8;
			end
			
			if ((cs_counter%2 == 0) && cs_counter != 7'd0) begin
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= {16'd0, S0_buf_w, S0_w};
				address_b[2] <= 7'd64 + add_buf1;
				if(cs_counter%7'd8 == 0) begin
					add_buf1 <= add_buf1+7'd5;
				end
				else begin
					add_buf1 <= add_buf1+7'd1;
				end
			end		
			
			SRAM_address <= BASE_ADDRESS + row_address + col_address; //Y11, Y15
			

			
			if(cs_counter == 7'd15)begin
				SRAM_address <= BASE_ADDRESS + row_address + col_address;
				col_index <= 3'd0;
				row_index <= 3'd0;
				s_prime_buf <= SRAM_read_data;
				write_enable_a[2] <= 1'b0;

			end else begin
				if (cs_counter < 7'd15) begin
					if(col_index == 3'd7) begin
						col_index <= 3'd0;
						row_index <= row_index + 3'd1;
					end else begin
						col_index <= col_index + 3'd1;
					end
					SRAM_address <= BASE_ADDRESS + row_address + col_address; //Y11, Y15						
					s_prime_buf <= SRAM_read_data;
					write_enable_a[2] <= 1'b0;
				end else begin
					write_enable_a[2] <= 1'b0;
				end	
			end
			
			
			M2_state <= CC_CS_FS_1;
		end
		
		CC_CS_FS_1:begin
		
			if((cs_counter2%8 == 0) && (cs_counter != 7'd0)) begin
				address_a[0] <= 0;
				address_b[0] <= 7'd8;
				address_a[1] <= address_a[1] -7'd23;
				address_b[1] <= address_b[1] -7'd23;	
			end
			else begin
				address_a[0] <= address_a[0] - 7'd47;
				address_b[0] <= address_b[0] - 7'd47;
				address_a[1] <= address_a[1] - 7'd24;
				address_b[1] <= address_b[1] - 7'd24;
			end
	
					
			S0 <= S0 + Mult1_result + Mult3_result;			
			S8 <= S8 + Mult2_result + Mult4_result;
			
			cs_counter <= cs_counter + 7'd1;
			
			C_0 <= $signed(read_data_a[1][31:16]);		//32
			C_1 <= $signed(read_data_a[1][15:0]);			//33
			C_2 <= $signed(read_data_b[1][31:16]);		//40
			C_3 <= $signed(read_data_b[1][15:0]);			//41
			Mult1_op <= read_data_a[0];			//T32
			Mult2_op <= read_data_a[0];			//T32
			Mult3_op <= read_data_b[0];			//T40
			Mult4_op <= read_data_b[0];			//T40
			
			if(cs_counter == 7'd15)begin
				write_data_a[2] <= {s_prime_buf, SRAM_read_data};
				write_enable_a[2] <= 1'b1;	
				address_a[2] <= address_a[2] + 7'd1;
			end else begin
				if (cs_counter < 7'd15) begin
					SRAM_address <= BASE_ADDRESS + row_address + col_address; //Y12
					col_index <= col_index + 3'd1;
					
					write_data_a[2] <= {s_prime_buf, SRAM_read_data};
					write_enable_a[2] <= 1'b1;
					if (address_a[2] != 7'd0) begin
						address_a[2] <= address_a[2] + 7'd1;
					end
				end
				
			end
			
			if ((cs_counter%2 == 0) && cs_counter != 7'd0) begin
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= {16'd0, S8_buf_w, S8_buf2_w};
				address_b[2] <= 7'd64 + add_buf2;
				if(cs_counter%7'd8 == 0) begin
					add_buf2 <= add_buf2+7'd5;
				end
				else begin
					add_buf2 <= add_buf2+7'd1;
				end
			end
			
			M2_state <= CC_CS_FS_2;
		end
		
		CC_CS_FS_2:begin
			address_a[0] <= address_a[0] + 7'd16;
			address_b[0] <= address_b[0] + 7'd16;
			address_a[1] <= address_a[1] + 7'd8;
			address_b[1] <= address_b[1] + 7'd8;
		
			write_enable_b[2] <= 1'b0;
			
			S0 <= S0 + Mult1_result + Mult3_result;			
			S8 <= S8 + Mult2_result + Mult4_result;
						
			C_0 <= $signed(read_data_a[1][31:16]);		//48
			C_1 <= $signed(read_data_a[1][15:0]);			//49
			C_2 <= $signed(read_data_b[1][31:16]);		//56
			C_3 <= $signed(read_data_b[1][15:0]);			//57
			Mult1_op <= read_data_a[0];			//T48
			Mult2_op <= read_data_a[0];			//T48
			Mult3_op <= read_data_b[0];			//T56
			Mult4_op <= read_data_b[0];			//T56
			
			if(cs_counter == 7'd16)begin
				s_prime_buf <= SRAM_read_data;
				write_enable_a[2] <= 1'b0;	
			end else begin
				if (cs_counter < 7'd16) begin
					SRAM_address <= BASE_ADDRESS + row_address + col_address; //Y13
					col_index <= col_index + 3'd1;
					
					s_prime_buf <= SRAM_read_data;
					write_enable_a[2] <= 1'b0;
				end
			end
			
			M2_state <= CC_CS_FS_3;
		end
		
		CC_CS_FS_3:begin
			address_a[0] <= address_a[0] + 7'd16;
			address_b[0] <= address_b[0] + 7'd16;
			address_a[1] <= address_a[1] + 7'd8;
			address_b[1] <= address_b[1] + 7'd8;	
			
			S0 <= S0 + Mult1_result + Mult3_result;			
			S8 <= S8 + Mult2_result + Mult4_result;
			
			C_0 <= $signed(read_data_a[1][31:16]);		//0
			C_1 <= $signed(read_data_a[1][15:0]);			//1
			C_2 <= $signed(read_data_b[1][31:16]);		//8
			C_3 <= $signed(read_data_b[1][15:0]);			//9
			Mult1_op <= read_data_a[0];			//T1
			Mult2_op <= read_data_a[0];			//T1
			Mult3_op <= read_data_b[0];			//T9
			Mult4_op <= read_data_b[0];			//T9
			
			if(cs_counter == 7'd16)begin
				write_data_a[2] <= {s_prime_buf, SRAM_read_data};
				write_enable_a[2] <= 1'b1;	
				address_a[2] <= address_a[2] + 7'd1;		
				

			end else begin
				if (cs_counter < 7'd16) begin
					SRAM_address <= BASE_ADDRESS + row_address + col_address; //Y14
					col_index <= col_index + 3'd1;			
				
					write_data_a[2] <= {s_prime_buf, SRAM_read_data};
					write_enable_a[2] <= 1'b1;
					address_a[2] <= address_a[2] + 7'd1;			

				end 			
			end

			
			if (cs_counter == 7'd32) begin
				M2_state <= LO_CS_FS_0;
			end else begin
				M2_state <= CC_CS_FS_0;
			end
		end


		LO_CS_FS_0:begin	
			cs_counter <= 7'd0;
			cs_counter2 <= 7'd0;
			write_enable_b[2] <= 1'b1;
			write_data_b[2] <= {16'd0, S0_buf_w, S0_w};
			address_b[2] <= 7'd64 + add_buf1;
			add_buf1 <= add_buf1 + 7'd1;			
			M2_state <= LO_CS_FS_1;
		end
		
		LO_CS_FS_1:begin
		
			write_enable_b[2] <= 1'b1;
			write_data_b[2] <= {16'd0, S8_buf_w, S8_w};
			address_b[2] <= 7'd64 + add_buf2;
			add_buf2 <= add_buf2 + 7'd1;		
			M2_state <= LO_CS_FS_2;	
		end
		
		LO_CS_FS_2:begin
			write_enable_b[2] <= 1'b0;
			add_buf1 <= 7'd0;
			add_buf2 <= 7'd4;
			M2_state <= LO_CS_FS_3;	
		end
		
		LO_CS_FS_3: begin
			//write_data_a[2] <= {s_prime_buf, SRAM_read_data};
			//write_enable_a[2] <= 1'b1;	
			//address_a[2] <= address_a[2] + 7'd1;

			//col_block_index <= col_block_index + 6'd1;
			M2_state <= LI_WS_CT_0;
		end
		
		
		LI_WS_CT_0:begin
			ws_counter <= 7'd1;
			write_enable_a[2] <= 1'b0;		
			
			ct_counter <= 7'd0;
			address_a[0] <= 7'd0;
			address_b[0] <= 7'd1;
			address_a[2] <= 7'd0;
			address_a[1] <= 7'd0;
			address_b[1] <= 7'd1;	
			
			address_b[2] <= 7'd64;
	
			write_enable_a[2] <= 1'b0;
			
			M2_state <= LI_WS_CT_1;
		end

		LI_WS_CT_1: begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
			M2_state <= LI_WS_CT_2;
		end		
		
		LI_WS_CT_2:begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;

			
			Mult1_op <= $signed(read_data_a[2][31:16]);
			Mult2_op <= $signed(read_data_a[2][31:16]);
			Mult3_op <= $signed(read_data_a[2][31:16]);
			Mult4_op <= $signed(read_data_a[2][31:16]);
			ct_y_buff <= $signed(read_data_a[2][15:0]);
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);
			
			M2_state <= CC_WS_CT_0;
		end
		
		CC_WS_CT_0:begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
			ct_counter <= ct_counter+7'd1;
			ws_counter <= ws_counter + 7'd1;
			if (ct_counter != 7'd0) begin
				ct_counter2 <= ct_counter;
			end
			
			if (ct_flag) begin
				address_a[0] <= address_a[0] + 7'd2;
				address_b[0] <= address_b[0] + 7'd2;
				write_data_a[0] <= T2>>>8;
				write_data_b[0] <= T3>>>8;
			end
			
			if(ct_counter % (7'd8) == 7'd0) begin
				T0 <= Mult1_result;
				T1 <= Mult2_result;
				T2 <= Mult3_result;
				T3 <= Mult4_result;			
			end else begin
				T0 <= T0 + Mult1_result;
				T1 <= T1 + Mult2_result;
				T2 <= T2 + Mult3_result;
				T3 <= T3 + Mult4_result;
			end
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);
					
			address_b[2] <= address_b[2]+7'd1;
			SRAM_address <= SRAM_base;			//uv base?
			
			
			if (ws_counter != 32) begin
				if (ws_counter % 7'd4 == 0) begin
					if ((yuv_block_select == 2'd0) | ((col_block_index==6'd0)&&(row_block_index==6'd0)&&(yuv_block_select==2'd1))) begin
						SRAM_base <= SRAM_base + 18'd157;
					end else begin
						SRAM_base <= SRAM_base + 18'd77;
					end
				end
				else begin
					SRAM_base <= SRAM_base +1'b1;
				end
			end else begin
				if (((col_block_index == 6'd0) && (row_block_index != 6'd0) && (ws_counter == 7'd32)) | ((col_block_index == 6'd0) && (row_block_index == 6'd0) && (ws_counter == 7'd32) && (yuv_block_select != 2'd0)) )begin
					SRAM_base <= SRAM_base + 18'd1;
				end else begin
					SRAM_base <= SRAM_base - write_offset;
				end
			end
			SRAM_write_data <= read_data_b[2][15:0];
			SRAM_we_n <= 1'b0;			
			
			M2_state <= CC_WS_CT_1;
		end
		
		CC_WS_CT_1:begin
			address_a[2] <= address_a[2]+7'd1;		
			ct_counter3 <= ct_counter + 7'd1;
			if ((address_a[1] == 7'd30) && (address_b[1] == 7'd31)) begin
				address_a[1] <= 7'd0;
				address_b[1] <= 7'd1;
			end else begin
				address_a[1] <= address_a[1]+7'd2;
				address_b[1] <= address_b[1]+7'd2;
			end
			
			if (ct_flag) begin
				address_a[0] <= address_a[0] + 7'd2;
				address_b[0] <= address_b[0] + 7'd2;
				write_data_a[0] <= T4>>>8;
				write_data_b[0] <= T5>>>8;
				T6_buf <= T6;
				T7_buf <= T7;
			end

			Mult1_op <= ct_y_buff;
			Mult2_op <= ct_y_buff;
			Mult3_op <= ct_y_buff;
			Mult4_op <= ct_y_buff;
			
			if(ct_counter2 % (7'd8) == 7'd0) begin
				T4 <= Mult1_result;
				T5 <= Mult2_result;
				T6 <= Mult3_result;
				T7 <= Mult4_result;			
			end else begin
				T4 <= T4 + Mult1_result;
				T5 <= T5 + Mult2_result;
				T6 <= T6 + Mult3_result;
				T7 <= T7 + Mult4_result;
			end
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);			
			
			SRAM_we_n <= 1'b1;
			
			M2_state <= CC_WS_CT_2;
		end
		
		CC_WS_CT_2:begin
			//address_a[2] <= address_a[2]+7'd1;
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
			ct_counter <= ct_counter+7'd1;			
			
			if (ct_counter3 % (7'd8) == 7'd0) begin
				ct_flag <= ~ ct_flag;
			end
			
			if (ct_flag) begin
				address_a[0] <= address_a[0] + 7'd2;
				address_b[0] <= address_b[0] + 7'd2;
				write_data_a[0] <= T6_buf>>>8;
				write_data_b[0] <= T7_buf>>>8;
				ct_flag <= ~ct_flag;
			end
			
			T0 <= T0+Mult1_result;			
			T1 <= T1+Mult2_result;
			T2 <= T2+Mult3_result;
			T3 <= T3+Mult4_result;
			
			C_0 <= $signed(read_data_a[1][31:16]);
			C_1 <= $signed(read_data_a[1][15:0]);
			C_2 <= $signed(read_data_b[1][31:16]);
			C_3 <= $signed(read_data_b[1][15:0]);
			
			M2_state <= CC_WS_CT_3;
		end
		
		CC_WS_CT_3:begin
			address_a[1] <= address_a[1]+7'd2;
			address_b[1] <= address_b[1]+7'd2;
			
			if (ct_flag) begin
				write_enable_a [0] <= 1'b1;
				write_enable_b [0] <= 1'b1;
				write_data_a[0] <= T0>>>8;
				write_data_b[0] <= T1>>>8;
				if(ct_counter != 7'd8) begin
					address_a[0] <= address_a[0]+7'd2;
					address_b[0] <= address_b[0]+7'd2;				
				end
			end else begin
				write_enable_a [0] <= 1'b0;
				write_enable_b [0] <= 1'b0;
			end
			
			T4 <= T4+Mult1_result;			
			T5 <= T5+Mult2_result;
			T6 <= T6+Mult3_result;
			T7 <= T7+Mult4_result;
			
			if(ct_counter != 7'd64)begin
				Mult1_op <= $signed(read_data_a[2][31:16]);
				Mult2_op <= $signed(read_data_a[2][31:16]);
				Mult3_op <= $signed(read_data_a[2][31:16]);
				Mult4_op <= $signed(read_data_a[2][31:16]);
				ct_y_buff <= $signed(read_data_a[2][15:0]);
				
				C_0 <= $signed(read_data_a[1][31:16]);
				C_1 <= $signed(read_data_a[1][15:0]);
				C_2 <= $signed(read_data_b[1][31:16]);
				C_3 <= $signed(read_data_b[1][15:0]);
				
				M2_state <= CC_WS_CT_0;
			end
			else begin				
				M2_state <= LO_WS_CT_0;
			end
		end			
		
		LO_WS_CT_0:begin
			//buf new T6 and T7
			T6_buf <= T6;
			T7_buf <= T7;
			ct_counter <= 7'd0;
			ct_counter2 <= 7'd0;
			ct_counter3 <= 7'd0;
			ws_counter <= 7'd0;
		   ct_flag <= 1'b0;
			//address_a[2] <= address_a[2]-7'd1;
			address_a[1] <= 7'd0;
			address_b[1] <= 7'd0;	
			address_a[0] <= address_a[0] + 7'd2;
			address_b[0] <= address_b[0] + 7'd2;
			write_data_a[0] <= T2>>>8;
			write_data_b[0] <= T3>>>8;
			
			M2_state <= LO_WS_CT_1;
		end
		
		LO_WS_CT_1:begin
			address_a[0] <= address_a[0] + 7'd2;
			address_b[0] <= address_b[0] + 7'd2;
			write_data_a[0] <= T4>>>8;
			write_data_b[0] <= T5>>>8;
			
			M2_state <= LO_WS_CT_2;
		end
		
		LO_WS_CT_2:begin
			address_a[0] <= address_a[0] + 7'd2;
			address_b[0] <= address_b[0] + 7'd2;
			write_data_a[0] <= T6_buf>>>8;
			write_data_b[0] <= T7_buf>>>8;
	
			if((col_block_index == max_col_block) && (row_block_index == 6'd29) && (yuv_block_select == 2'd2)) begin
				write_enable_b[1] <= 1'b0;
				row_index <= 3'd0;
				col_index <= 3'd0;
				M2_state <= LI_CS_0;
			end else begin	
				write_enable_b[1] <= 1'b0;
				row_index <= 3'd0;
				col_index <= 3'd0;
				
				if(col_block_index == max_col_block) begin
					if (row_block_index == 6'd29)begin
						yuv_block_select <= yuv_block_select + 2'd1;
						row_block_index <= 6'd0;
						col_block_index <= 6'd0;
					end else begin
						row_block_index <= row_block_index + 6'd1;
						col_block_index <= 6'd0;
					end
				end else begin
					col_block_index <= col_block_index + 6'd1;
				end
				M2_state <= LI_CS_FS; //beginning of the mega state 1
			end
		end	
		
		
		//LEADOUT
		
		
		LI_CS_0: begin
			cs_counter2 <= 7'd0;
			
			write_enable_a [0] <= 1'b0;
			write_enable_b [0] <= 1'b0;
			address_a[1] <= 7'd0;
			address_b[1] <= 7'd4;
			address_a[0] <= 7'd0;
			address_b[0] <= 7'd8;	
		
			M2_state <= LI_CS_1;
		end
		
		LI_CS_1:begin

			address_a[2] <= 7'd0;
			address_b[2] <= 7'd64;
			
			//S_0_base <= 7'd64;
			//S_8_base <= 7'd70;

			//address_a[1] <= address_a[1]+7'd8;
			//address_b[1] <= address_b[1]+7'd8;
			//address_a[0] <= address_a[0]+7'd16;
			//address_b[0] <= address_b[0]+7'd16;		
			
			cs_counter <= 7'b0;

			M2_state <= LI_CS_2;
		end
		
		LI_CS_2:begin
			address_a[1] <= address_a[1]+7'd8;
			address_b[1] <= address_b[1]+7'd8;
			address_a[0] <= address_a[0]+7'd16;
			address_b[0] <= address_b[0]+7'd16;
			
			
			C_0 <= $signed(read_data_a[1][31:16]);		//0
			C_1 <= $signed(read_data_a[1][15:0]);			//1
			C_2 <= $signed(read_data_b[1][31:16]);		//8
			C_3 <= $signed(read_data_b[1][15:0]);			//9
			Mult1_op <= read_data_a[0];			//T0
			Mult2_op <= read_data_a[0];			//T0
			Mult3_op <= read_data_b[0];			//T8
			Mult4_op <= read_data_b[0];			//T8
			
			M2_state <= LI_CS_3;
		end
		
		LI_CS_3:begin
			M2_state <= CC_CS_0;
			
			address_a[1] <= address_a[1]+7'd8;
			address_b[1] <= address_b[1]+7'd8;
			address_a[0] <= address_a[0]+7'd16;
			address_b[0] <= address_b[0]+7'd16;
			
			add_buf1 <= 7'd0;
			add_buf2 <= 7'd4;
			
		end
		
		CC_CS_0:begin	
			cs_counter2 <= cs_counter + 7'd1;
			
			address_a[0] <= address_a[0] + 7'd16;
			address_b[0] <= address_b[0] + 7'd16;
			address_a[1] <= address_a[1] + 7'd8;
			address_b[1] <= address_b[1] + 7'd8;	
			
			S0 <= Mult1_result + Mult3_result;			
			S8 <= Mult2_result + Mult4_result;
						
			C_0 <= $signed(read_data_a[1][31:16]);		//16
			C_1 <= $signed(read_data_a[1][15:0]);			//17
			C_2 <= $signed(read_data_b[1][31:16]);		//24
			C_3 <= $signed(read_data_b[1][15:0]);			//25
			Mult1_op <= read_data_a[0];			//T16
			Mult2_op <= read_data_a[0];			//T16
			Mult3_op <= read_data_b[0];			//T24
			Mult4_op <= read_data_b[0];			//T24
			
			if (cs_counter % (7'd2) == 7'd1) begin
				S0_buf <= S0;
				S8_buf <= S8;
			end
			
			if(cs_counter!= 7'd0) begin
				S8_buf2 <= S8;
			end
			
			if ((cs_counter%2 == 0) && cs_counter != 7'd0) begin
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= {16'd0, S0_buf_w, S0_w};
				address_b[2] <= 7'd64 + add_buf1;
				if(cs_counter%7'd8 == 0) begin
					add_buf1 <= add_buf1+7'd5;
				end
				else begin
					add_buf1 <= add_buf1+7'd1;
				end
			end		
		
			M2_state <= CC_CS_1;
		end
		
		CC_CS_1:begin
		
			if((cs_counter2%8 == 0) && (cs_counter != 7'd0)) begin
				address_a[0] <= 0;
				address_b[0] <= 7'd8;
				address_a[1] <= address_a[1] -7'd23;
				address_b[1] <= address_b[1] -7'd23;	
			end
			else begin
				address_a[0] <= address_a[0] - 7'd47;
				address_b[0] <= address_b[0] - 7'd47;
				address_a[1] <= address_a[1] - 7'd24;
				address_b[1] <= address_b[1] - 7'd24;
			end
	
					
			S0 <= S0 + Mult1_result + Mult3_result;			
			S8 <= S8 + Mult2_result + Mult4_result;
			
			cs_counter <= cs_counter + 7'd1;
			
			C_0 <= $signed(read_data_a[1][31:16]);		//32
			C_1 <= $signed(read_data_a[1][15:0]);			//33
			C_2 <= $signed(read_data_b[1][31:16]);		//40
			C_3 <= $signed(read_data_b[1][15:0]);			//41
			Mult1_op <= read_data_a[0];			//T32
			Mult2_op <= read_data_a[0];			//T32
			Mult3_op <= read_data_b[0];			//T40
			Mult4_op <= read_data_b[0];			//T40	
			
			if ((cs_counter%2 == 0) && cs_counter != 7'd0) begin
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= {16'd0, S8_buf_w, S8_buf2_w};
				address_b[2] <= 7'd64 + add_buf2;
				if(cs_counter%7'd8 == 0) begin
					add_buf2 <= add_buf2+7'd5;
				end
				else begin
					add_buf2 <= add_buf2+7'd1;
				end
			end
			
			M2_state <= CC_CS_2;
		end
		
		CC_CS_2:begin
			address_a[0] <= address_a[0] + 7'd16;
			address_b[0] <= address_b[0] + 7'd16;
			address_a[1] <= address_a[1] + 7'd8;
			address_b[1] <= address_b[1] + 7'd8;
		
			write_enable_b[2] <= 1'b0;
			
			S0 <= S0 + Mult1_result + Mult3_result;			
			S8 <= S8 + Mult2_result + Mult4_result;
						
			C_0 <= $signed(read_data_a[1][31:16]);		//48
			C_1 <= $signed(read_data_a[1][15:0]);			//49
			C_2 <= $signed(read_data_b[1][31:16]);		//56
			C_3 <= $signed(read_data_b[1][15:0]);			//57
			Mult1_op <= read_data_a[0];			//T48
			Mult2_op <= read_data_a[0];			//T48
			Mult3_op <= read_data_b[0];			//T56
			Mult4_op <= read_data_b[0];			//T56
			
			M2_state <= CC_CS_3;
		end
		
		CC_CS_3:begin
			address_a[0] <= address_a[0] + 7'd16;
			address_b[0] <= address_b[0] + 7'd16;
			address_a[1] <= address_a[1] + 7'd8;
			address_b[1] <= address_b[1] + 7'd8;	
			
			S0 <= S0 + Mult1_result + Mult3_result;			
			S8 <= S8 + Mult2_result + Mult4_result;
			
			C_0 <= $signed(read_data_a[1][31:16]);		//0
			C_1 <= $signed(read_data_a[1][15:0]);			//1
			C_2 <= $signed(read_data_b[1][31:16]);		//8
			C_3 <= $signed(read_data_b[1][15:0]);			//9
			Mult1_op <= read_data_a[0];			//T1
			Mult2_op <= read_data_a[0];			//T1
			Mult3_op <= read_data_b[0];			//T9
			Mult4_op <= read_data_b[0];			//T9

		
			if (cs_counter == 7'd32) begin
				M2_state <= LO_CS_0;
			end else begin
				M2_state <= CC_CS_0;
			end
		end


		LO_CS_0:begin	
			cs_counter <= 7'd0;
			cs_counter2 <= 7'd0;
			write_enable_b[2] <= 1'b1;
			write_data_b[2] <= {16'd0, S0_buf_w, S0_w};
			address_b[2] <= 7'd64 + add_buf1;
			add_buf1 <= add_buf1 + 7'd1;			
			M2_state <= LO_CS_1;
		end
		
		LO_CS_1:begin
		
			write_enable_b[2] <= 1'b1;
			write_data_b[2] <= {16'd0, S8_buf_w, S8_w};
			address_b[2] <= 7'd64 + add_buf2;
			add_buf2 <= add_buf2 + 7'd1;		
			M2_state <= LO_CS_2;	
		end
		
		LO_CS_2:begin
			write_enable_b[2] <= 1'b0;
			add_buf1 <= 7'd0;
			add_buf2 <= 7'd4;
			M2_state <= LO_CS_3;	
		end
		
		LO_CS_3: begin
			//write_data_a[2] <= {s_prime_buf, SRAM_read_data};
			//write_enable_a[2] <= 1'b1;	
			//address_a[2] <= address_a[2] + 7'd1;

			//col_block_index <= col_block_index + 6'd1;
			address_b[2] <= 7'd64;
			M2_state <= LI_WS_0;
		end	
	
		
		LI_WS_0:begin
			ws_counter <= 7'd1;
			write_enable_a[2] <= 1'b0;		
			
			ct_counter <= 7'd0;

	
			write_enable_b[2] <= 1'b0;
			
			M2_state <= CC_WS_0;
		end

		CC_WS_0:begin

			ct_counter <= ct_counter+7'd1;
			ws_counter <= ws_counter + 7'd1;
					
			address_b[2] <= address_b[2]+7'd1;
			SRAM_address <= SRAM_base;			//uv base?
			
			
			if (ws_counter != 32) begin
				if (ws_counter % 7'd4 == 0) begin
					SRAM_base <= SRAM_base + 18'd77;
				end
				else begin
					SRAM_base <= SRAM_base +1'b1;
				end
			end else begin
				if (((col_block_index == 6'd0) && (row_block_index != 6'd0) && (ws_counter == 7'd32)) | ((col_block_index == 6'd0) && (row_block_index == 6'd0) && (ws_counter == 7'd32) && (yuv_block_select != 2'd0)) )begin
					SRAM_base <= SRAM_base + 18'd1;
				end else begin
					SRAM_base <= SRAM_base - write_offset;
				end
			end
			SRAM_write_data <= read_data_b[2][15:0];
			SRAM_we_n <= 1'b0;			
			
			M2_state <= CC_WS_1;
		end
		
		CC_WS_1:begin
			SRAM_we_n <= 1'b1;
			ct_counter <= ct_counter+7'd1;
			M2_state <= CC_WS_2;
		end

	
		CC_WS_2:begin		
			if(ct_counter != 7'd64)begin	
				M2_state <= CC_WS_0;
			end
			else begin				
				M2_state <= LO_WS_0;
			end
		end			
		
		LO_WS_0:begin
			M2_state <= finish;
		end

		finish: begin
			done <= 1'b1;
			M2_state <= M2_IDLE0;
		end	
	
	
	
	
	
		
		endcase
		
	end
end

endmodule

	
