
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module M1 (
	input logic Clock,
	input logic resetn,
	input logic [15:0] SRAM_read_data,
	input logic start,
	
	output logic [17:0] SRAM_address,
	output logic done,
	output logic [15:0] SRAM_write_data,
	output logic SRAM_we_n
);

M1_state_type M1_state;	

logic [7:0] u_minus_5;
logic [7:0] u_minus_3;
logic [7:0] u_minus_1;
logic [7:0] u_plus_1;
logic [7:0] u_plus_3;
logic [7:0] u_plus_5;

logic [7:0] v_minus_5;
logic [7:0] v_minus_3;
logic [7:0] v_minus_1;
logic [7:0] v_plus_1;
logic [7:0] v_plus_3;
logic [7:0] v_plus_5;

logic signed [31:0] u_odd_prime;	//
logic signed [31:0] u_even_prime;	//
logic signed [31:0] v_odd_prime;	//
logic signed [31:0] v_even_prime;	//


logic signed [31:0] R[1:0];
logic signed [31:0] G[1:0];
logic signed [31:0] B[1:0];

logic [7:0] R_write[1:0];
logic [7:0] G_write[1:0];
logic [7:0] B_write[1:0];

logic [15:0] u_buf;
logic [15:0] v_buf;
logic [15:0] y_buf;
logic signed [31:0] a00y_odd_buff;	//

logic signed [31:0] Mult1_op_1;
logic signed [31:0] Mult1_op_2;
logic signed [31:0] Mult1_result;
logic signed [31:0] Mult2_op_1;
logic signed [31:0] Mult2_op_2;
logic signed [31:0] Mult2_result;
logic signed [31:0] Mult3_op_1;
logic signed [31:0] Mult3_op_2;
logic signed [31:0] Mult3_result;
logic signed [31:0] Mult4_op_1;
logic signed [31:0] Mult4_op_2;
logic signed [31:0] Mult4_result;

logic [17:0] u_address;
logic [17:0] v_address;
logic [17:0] y_address;
logic [17:0] rgb_address;

logic signed [31:0] uAC;
logic signed [31:0] vAC;

logic [31:0]cc_num;	//

assign Mult1_result = Mult1_op_1*Mult1_op_2;
assign Mult2_result = Mult2_op_1*Mult2_op_2;
assign Mult3_result = Mult3_op_1*Mult3_op_2;
assign Mult4_result = Mult4_op_1*Mult4_op_2;

assign R_write[1] = (R[1][31]) ? 8'd0 : (|R[1][30:24]) ? 8'd255 : R[1][23:16];
assign R_write[0] = (R[0][31]) ? 8'd0 : (|R[0][30:24]) ? 8'd255 : R[0][23:16];
assign G_write[1] = (G[1][31]) ? 8'd0 : (|G[1][30:24]) ? 8'd255 : G[1][23:16];
assign G_write[0] = (G[0][31]) ? 8'd0 : (|G[0][30:24]) ? 8'd255 : G[0][23:16];
assign B_write[1] = (B[1][31]) ? 8'd0 : (|B[1][30:24]) ? 8'd255 : B[1][23:16];
assign B_write[0] = (B[0][31]) ? 8'd0 : (|B[0][30:24]) ? 8'd255 : B[0][23:16];






always @(posedge Clock or negedge resetn) begin
	if (~resetn)begin
	 
		done <= 1'b0;
		
		u_minus_5 <= 8'd0;
		u_minus_3 <= 8'd0;
		u_minus_1 <= 8'd0;
		u_plus_1 <= 8'd0;
		u_plus_3 <= 8'd0;
		u_plus_5 <= 8'd0;

		v_minus_5 <= 8'd0;
		v_minus_3 <= 8'd0;
		v_minus_1 <= 8'd0;
		v_plus_1 <= 8'd0;
		v_plus_3 <= 8'd0;
		v_plus_5 <= 8'd0;
		
		u_even_prime <= 32'd0;	//
		u_odd_prime <= 32'd0;	//
		v_even_prime <= 32'd0;	//
		v_odd_prime <= 32'd0;	//

		R[0] <= 32'd0;
		R[1] <= 32'd0;
		G[0] <= 32'd0;
		G[1] <= 32'd0;
		B[0] <= 32'd0;
		B[1] <= 32'd0;
//		R_write[0] <= 8'd0;
//		R_write[1] <= 8'd0;
//		G_write[0] <= 8'd0;
//		G_write[1] <= 8'd0;
//		B_write[0] <= 8'd0;
//		B_write[1] <= 8'd0;

		u_buf <= 16'd0;
		v_buf <= 16'd0;
		y_buf <= 16'd0;
		a00y_odd_buff <= 32'd0;
	
		Mult1_op_1 <= 32'd0;
		Mult1_op_2 <= 32'd0;
//		Mult1_result <= 32'd0;
		Mult2_op_1 <= 32'd0;
		Mult2_op_2 <= 32'd0;
//		Mult2_result <= 32'd0;
		Mult3_op_1 <= 32'd0;
		Mult3_op_2 <= 32'd0;
//		Mult3_result <= 32'd0;
		Mult4_op_1 <= 32'd0;
		Mult4_op_2 <= 32'd0;
//		Mult4_result <= 32'd0;

		u_address <= 18'd38400;
		v_address <= 18'd57600;
		y_address <= 18'd0;
		rgb_address <= 18'd146944;
		
		uAC <= 32'd0;	//
		vAC <= 32'd0; //
		
		cc_num <= 16'd0;	//
		
		SRAM_we_n <= 1'b1;
		SRAM_address <= 18'd0;
		SRAM_write_data <= 16'd0;
		
		M1_state <= M1_IDLE;
		
	end 
	else begin
		case (M1_state)
			M1_IDLE: begin
				done <= 1'b0;
				if(start)begin
					M1_state <= leadIn_0;
					SRAM_we_n <= 1'b1;
					cc_num <= 2;
				end
			end		 
			
			leadIn_0: begin
				SRAM_address <= u_address;
				u_address <= u_address + 1'd1;
				M1_state <= leadIn_1;		 
			end
			 
			leadIn_1: begin
	           SRAM_address <= v_address;
				  v_address <= v_address + 1'd1;
				  M1_state <= leadIn_2;	
			end
		     
			leadIn_2: begin	
				SRAM_address <= u_address;
				u_address <= u_address + 1'd1;
				M1_state <= leadIn_3;	
			end
			 
			leadIn_3: begin
				SRAM_address <= v_address;
				v_address <= v_address + 1'd1;
				  
				u_even_prime <= SRAM_read_data[15:8];	//
				 
				u_minus_5 <= SRAM_read_data[15:8];
				u_minus_3 <= SRAM_read_data[15:8];
				u_minus_1 <= SRAM_read_data[15:8];
				u_plus_1 <= SRAM_read_data[7:0];				  
				  
				u_buf <= SRAM_read_data;
				  
				M1_state <= leadIn_4;
			 end
				  
			leadIn_4: begin
			     SRAM_address <= y_address;
				  y_address <= y_address + 1'd1;
					
				  v_even_prime <= SRAM_read_data[15:8];		//
					
				  v_minus_5 <= SRAM_read_data[15:8];
				  v_minus_3 <= SRAM_read_data[15:8];
				  v_minus_1 <= SRAM_read_data[15:8];
				  v_plus_1   <= SRAM_read_data[7:0];
				  
				  v_buf <= SRAM_read_data;
				  
				  Mult1_op_1 <= u_minus_5;
				  Mult1_op_2 <= 21;
				  Mult2_op_1 <= u_minus_3;
				  Mult2_op_2 <= -52;
				  Mult3_op_1 <= u_minus_1;
				  Mult3_op_2 <= 159;
				  Mult4_op_1 <= u_plus_1;
				  Mult4_op_2 <= 159;
				  
				  M1_state <= leadIn_5;
			 end
		
			leadIn_5: begin	
			     SRAM_address <= u_address;
				  u_address <= u_address + 1'd1;
				  
				  uAC <= Mult1_result+Mult2_result+Mult3_result+Mult4_result;	//
				  
				  u_plus_3 <= SRAM_read_data[15:8];
         	  u_plus_5 <= SRAM_read_data[7:0];
				  
				  u_buf <= SRAM_read_data;

				  Mult1_op_1 <= {24'd0, SRAM_read_data[15:8]};
				  Mult1_op_2 <= -52;
				  Mult2_op_1 <= {24'd0, SRAM_read_data[7:0]};
				  Mult2_op_2 <= 21;
				  Mult3_op_1 <= v_minus_5;
				  Mult3_op_2 <= 21;
				  Mult4_op_1 <= v_minus_3;
				  Mult4_op_2 <= -52;		
				  M1_state <= leadIn_6;		  
			 end
			 
			leadIn_6: begin
			     SRAM_address <= v_address;
				  v_address <= v_address + 1'd1;
				  
				  uAC <= (uAC+Mult1_result+Mult2_result+128)>>>8;	//
				  vAC <= Mult3_result+Mult4_result;//
				  
				  v_plus_3 <= SRAM_read_data[15:8];
		        v_plus_5 <= SRAM_read_data[7:0];
				  
				  v_buf <= SRAM_read_data;
				  
				  Mult1_op_1 <= v_minus_1;
				  Mult1_op_2 <= 159;
				  Mult2_op_1 <= v_plus_1;
				  Mult2_op_2 <= 159;
				  Mult3_op_1 <= {24'd0, SRAM_read_data[15:8]};
				  Mult3_op_2 <= -52;
				  Mult4_op_1 <= {24'd0, SRAM_read_data[7:0]};
				  Mult4_op_2 <= 21;		
				  
				  M1_state <= leadIn_7;
			 end
			 
			 //
			 leadIn_7: begin
				y_buf <= SRAM_read_data;
				
				u_odd_prime <= uAC;
				
				vAC <= (vAC+Mult1_result+Mult2_result+Mult3_result+Mult4_result+128)>>>8;
				
				Mult1_op_1 <= {24'd0, SRAM_read_data[15:8]}-32'd16;
				Mult1_op_2 <= 76284;
				Mult2_op_1 <= v_even_prime-128;
				Mult2_op_2 <= 104595;
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= -25624;
				Mult4_op_1 <= v_even_prime-128;
				Mult4_op_2 <= -53281;					  
				
				M1_state <= leadIn_8;
			 end
			 
			 leadIn_8: begin
				u_buf <= SRAM_read_data;
				
				v_odd_prime <= vAC;
				
				u_plus_3 <= u_plus_5;
				u_plus_1 <= u_plus_3;	
				u_minus_1 <= u_plus_1;
				u_minus_3 <= u_minus_1;
				u_minus_5 <= u_minus_3;
				u_plus_5 <= SRAM_read_data[15:8];
				
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= 132251;
				Mult4_op_1 <= y_buf[7:0]-16;
				Mult4_op_2 <= 76284;		
				
				R[1] <= (Mult1_result+Mult2_result);
				G[1] <= (Mult1_result+Mult3_result+Mult4_result);
				
				M1_state <= leadIn_9;
			 end
			 
			 leadIn_9: begin
					SRAM_address <= y_address;
					y_address <= y_address+1'd1;
					
					v_buf <= SRAM_read_data;
					
					v_minus_5 <= v_minus_3;
					v_minus_3 <= v_minus_1;
					v_minus_1 <= v_plus_1;
					v_plus_1 <= v_plus_3;		
					v_plus_3 <= v_plus_5;
					v_plus_5 <= SRAM_read_data[15:8];
					
					Mult1_op_1 <= v_odd_prime-128;
					Mult1_op_2 <= 104595;
					Mult2_op_1 <= u_odd_prime-128;
					Mult2_op_2 <= -25624;
					Mult3_op_1 <= v_odd_prime-128;
					Mult3_op_2 <= -53281;
					Mult4_op_1 <= u_odd_prime-128;
					Mult4_op_2 <= 132251;	
					a00y_odd_buff <= Mult4_result;
					
					B[1] <= (Mult1_result+Mult3_result);
					//SRAM_we_n <= 1'b0;
					M1_state <= cc_0;
			 end
			 
			 cc_0:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_we_n <= 1'b0;
				
				SRAM_write_data[15:8] <= R_write[1];
				SRAM_write_data[7:0] <= G_write[1];
				
				R[0] <= (a00y_odd_buff+Mult1_result);
				G[0] <= (a00y_odd_buff+Mult2_result+Mult3_result);
				B[0] <= (a00y_odd_buff+Mult4_result);
				
				Mult1_op_1 <= u_minus_5;
				Mult1_op_2 <= 21;
				Mult2_op_1 <= u_minus_3;
				Mult2_op_2 <= -52;
				Mult3_op_1 <= u_minus_1;
				Mult3_op_2 <= 159;
				Mult4_op_1 <= u_plus_1;
				Mult4_op_2 <= 159;
				
				if(cc_num%2 == 1'd1)begin
					u_buf <= SRAM_read_data;
				end
				
				M1_state <= cc_1;
			 end
			 
			cc_1:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= B_write[1];
				SRAM_write_data[7:0] <= R_write[0];
				
				u_even_prime <= u_minus_1;
				v_even_prime <= v_minus_1;
				
				uAC <= Mult1_result+Mult2_result+Mult3_result+Mult4_result;	
				
				Mult1_op_1 <= u_plus_3;
				Mult1_op_2 <= -52;
				Mult2_op_1 <= u_plus_5;
				Mult2_op_2 <= 21;
				Mult3_op_1 <= v_minus_5;
				Mult3_op_2 <= 21;
				Mult4_op_1 <= v_minus_3;
				Mult4_op_2 <= -52;		
				M1_state <= leadIn_6;		
				
				if(cc_num%2 == 1'd1)begin
					v_buf <= SRAM_read_data;
				end
				
				M1_state <= cc_2;
			end
			 
			cc_2:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= G_write[0];
				SRAM_write_data[7:0] <= B_write[0];
				
				y_buf <= SRAM_read_data;
				
				u_odd_prime <= (uAC+Mult1_result+Mult2_result+128)>>>8;
				vAC <= Mult3_result+Mult4_result;
				
				Mult1_op_1 <= v_minus_1;
				Mult1_op_2 <= 159;
				Mult2_op_1 <= v_plus_1;
				Mult2_op_2 <= 159;
				Mult3_op_1 <= v_plus_3;
				Mult3_op_2 <= -52;
				Mult4_op_1 <= v_plus_5;
				Mult4_op_2 <= 21;		
				
				M1_state <= cc_3;
			end
			 
			 cc_3:begin
				if(cc_num%2 != 1'd1)begin
					SRAM_address <= u_address;
					u_address <= u_address+1'd1;
				end

				v_odd_prime <= (vAC+Mult1_result+Mult2_result+Mult3_result+Mult4_result+128)>>>8;
				
				Mult1_op_1 <= {24'd0, y_buf[15:8]}-32'd16;
				Mult1_op_2 <= 76284;
				Mult2_op_1 <= v_even_prime-128;
				Mult2_op_2 <= 104595;
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= -25624;
				Mult4_op_1 <= v_even_prime-128;
				Mult4_op_2 <= -53281;		
				SRAM_we_n <= 1'b1;
				M1_state <= cc_4;
			 end
			 
			  cc_4:begin
				  if(cc_num%2 != 1'd1)begin
						SRAM_address <= v_address;
						v_address <= v_address+1'd1;
				  end
				
					u_minus_5 <= u_minus_3;
					u_minus_3 <= u_minus_1;
					u_minus_1 <= u_plus_1;
					u_plus_1 <= u_plus_3;		
					u_plus_3 <= u_plus_5;
					if(cc_num%2 == 1'd1)begin
						u_plus_5 <= u_buf[15:8];
					end 
					else begin
						u_plus_5 <= u_buf[7:0];
					end
					v_minus_5 <= v_minus_3;
					v_minus_3 <= v_minus_1;
					v_minus_1 <= v_plus_1;
					v_plus_1 <= v_plus_3;		
					v_plus_3 <= v_plus_5;
					if(cc_num%2 == 1'd1)begin
						v_plus_5 <= v_buf[15:8];
					end
					else begin
						v_plus_5 <= v_buf[7:0];
					end
					R[1] <= (Mult1_result+Mult2_result);
					G[1] <= (Mult1_result+Mult3_result+Mult4_result);
					
					Mult3_op_1 <= u_even_prime-128;
					Mult3_op_2 <= 132251;
					Mult4_op_1 <= {24'd0,y_buf[7:0]} - 32'd16;
					Mult4_op_2 <= 76284;	
					
					M1_state <= cc_5;
			  end
			  
			 cc_5:begin
				SRAM_address <= y_address;
				y_address <= y_address+1'd1;
				
				Mult1_op_1 <= v_odd_prime-128;
				Mult1_op_2 <= 104595;
				Mult2_op_1 <= u_odd_prime-128;
				Mult2_op_2 <= -25624;
				Mult3_op_1 <= v_odd_prime-128;
				Mult3_op_2 <= -53281;
				Mult4_op_1 <= u_odd_prime-128;
				Mult4_op_2 <= 132251;	
				a00y_odd_buff <= Mult4_result;
				
				B[1] <= (Mult1_result+Mult3_result);
				cc_num <= cc_num+1'd1;
				
				if(cc_num == 155)begin
					M1_state <= leadOut_0;
					
				end
				else begin
					M1_state <= cc_0;
				end
			 end
			 
			 leadOut_0:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_we_n <= 1'b0;
				
				SRAM_write_data[15:8] <= R_write[1];
				SRAM_write_data[7:0] <= G_write[1];
				
				R[0] <= a00y_odd_buff+Mult1_result;
				G[0] <= a00y_odd_buff+Mult2_result+Mult3_result;
				B[0] <= a00y_odd_buff+Mult4_result;
				
				Mult1_op_1 <= u_minus_5;
				Mult1_op_2 <= 21;
				Mult2_op_1 <= u_minus_3;
				Mult2_op_2 <= -52;
				Mult3_op_1 <= u_minus_1;
				Mult3_op_2 <= 159;
				Mult4_op_1 <= u_plus_1;
				Mult4_op_2 <= 159;
				
				M1_state <= leadOut_1;
			 end
			 
			 leadOut_1:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= B_write[1];
				SRAM_write_data[7:0] <= R_write[0];
				
				u_even_prime <= u_minus_1;
				v_even_prime <= v_minus_1;
				
				uAC <= Mult1_result+Mult2_result+Mult3_result+Mult4_result;	
				
				Mult1_op_1 <= u_plus_3;
				Mult1_op_2 <= -52;
				Mult2_op_1 <= u_plus_5;
				Mult2_op_2 <= 21;
				Mult3_op_1 <= v_minus_5;
				Mult3_op_2 <= 21;
				Mult4_op_1 <= v_minus_3;
				Mult4_op_2 <= -52;			
				
				M1_state <= leadOut_2;
			 end
			 
			 leadOut_2:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= G_write[0];
				SRAM_write_data[7:0] <= B_write[0];
				
				y_buf <= SRAM_read_data;
				
				u_odd_prime <= (uAC+Mult1_result+Mult2_result+128)>>>8;
				vAC <= Mult3_result+Mult4_result;
				
				Mult1_op_1 <= v_minus_1;
				Mult1_op_2 <= 159;
				Mult2_op_1 <= v_plus_1;
				Mult2_op_2 <= 159;
				Mult3_op_1 <= v_plus_3;
				Mult3_op_2 <= -52;
				Mult4_op_1 <= v_plus_5;
				Mult4_op_2 <= 21;		
				
				M1_state <= leadOut_3;
			 end
			 
			 leadOut_3:begin
				v_odd_prime <= (vAC+Mult1_result+Mult2_result+Mult3_result+Mult4_result+128)>>>8;
				
				Mult1_op_1 <= {24'd0, y_buf[15:8]}-32'd16;
				Mult1_op_2 <= 76284;
				Mult2_op_1 <= v_even_prime-128;
				Mult2_op_2 <= 104595;
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= -25624;
				Mult4_op_1 <= v_even_prime-128;
				Mult4_op_2 <= -53281;		
				
				SRAM_we_n <= 1'b1;
				
				M1_state <= leadOut_4;
			 end
			 
			 leadOut_4:begin
				u_minus_5 <= u_minus_3;
				u_minus_3 <= u_minus_1;
				u_minus_1 <= u_plus_1;
				u_plus_1 <= u_plus_3;		
				u_plus_3 <= u_plus_5;
				u_plus_5 <= u_buf[7:0];
				
					
					
				v_minus_5 <= v_minus_3;
				v_minus_3 <= v_minus_1;
				v_minus_1 <= v_plus_1;
				v_plus_1 <= v_plus_3;		
				v_plus_3 <= v_plus_5;
				v_plus_5 <= v_buf[7:0];

				R[1] <= Mult1_result+Mult2_result;
				G[1] <= Mult1_result+Mult3_result+Mult4_result;
					
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= 132251;
				Mult4_op_1 <= {24'd0,y_buf[7:0]} - 32'd16;
				Mult4_op_2 <= 76284;	
					
				M1_state <= leadOut_5;
			 end
			 
			 leadOut_5:begin
				SRAM_address <= y_address;
				y_address <= y_address+1'd1;
				
				Mult1_op_1 <= v_odd_prime-128;
				Mult1_op_2 <= 104595;
				Mult2_op_1 <= u_odd_prime-128;
				Mult2_op_2 <= -25624;
				Mult3_op_1 <= v_odd_prime-128;
				Mult3_op_2 <= -53281;
				Mult4_op_1 <= u_odd_prime-128;
				Mult4_op_2 <= 132251;	
				a00y_odd_buff <= Mult4_result;
				
				B[1] <= Mult1_result+Mult3_result;
				
				
				
				M1_state <= leadOut_6;
			 end
			 
			 leadOut_6:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_we_n <= 1'b0;
				
				SRAM_write_data[15:8] <= R_write[1];
				SRAM_write_data[7:0] <= G_write[1];
				
				R[0] <= a00y_odd_buff+Mult1_result;
				G[0] <= a00y_odd_buff+Mult2_result+Mult3_result;
				B[0] <= a00y_odd_buff+Mult4_result;
				
				Mult1_op_1 <= u_minus_5;
				Mult1_op_2 <= 21;
				Mult2_op_1 <= u_minus_3;
				Mult2_op_2 <= -52;
				Mult3_op_1 <= u_minus_1;
				Mult3_op_2 <= 159;
				Mult4_op_1 <= u_plus_1;
				Mult4_op_2 <= 159;
				
				M1_state <= leadOut_7;
			 end
			 
			 leadOut_7:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= B_write[1];
				SRAM_write_data[7:0] <= R_write[0];
				
				u_even_prime <= u_minus_1;
				v_even_prime <= v_minus_1;
				
				uAC <= Mult1_result+Mult2_result+Mult3_result+Mult4_result;	
				
				Mult1_op_1 <= u_plus_3;
				Mult1_op_2 <= -52;
				Mult2_op_1 <= u_plus_5;
				Mult2_op_2 <= 21;
				Mult3_op_1 <= v_minus_5;
				Mult3_op_2 <= 21;
				Mult4_op_1 <= v_minus_3;
				Mult4_op_2 <= -52;			
				
				M1_state <= leadOut_8;
			 end
			 
			 leadOut_8:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= G_write[0];
				SRAM_write_data[7:0] <= B_write[0];
				
				y_buf <= SRAM_read_data;
				
				u_odd_prime <= (uAC+Mult1_result+Mult2_result+128)>>>8;
				vAC <= Mult3_result+Mult4_result;
				
				Mult1_op_1 <= v_minus_1;
				Mult1_op_2 <= 159;
				Mult2_op_1 <= v_plus_1;
				Mult2_op_2 <= 159;
				Mult3_op_1 <= v_plus_3;
				Mult3_op_2 <= -52;
				Mult4_op_1 <= v_plus_5;
				Mult4_op_2 <= 21;		
				
				M1_state <= leadOut_9;
			 end
			 
			 leadOut_9:begin
				v_odd_prime <= (vAC+Mult1_result+Mult2_result+Mult3_result+Mult4_result+128)>>>8;
				
				Mult1_op_1 <={24'd0, y_buf[15:8]}-32'd16;
				Mult1_op_2 <= 76284;
				Mult2_op_1 <= v_even_prime-128;
				Mult2_op_2 <= 104595;
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= -25624;
				Mult4_op_1 <= v_even_prime-128;
				Mult4_op_2 <= -53281;		
				
				SRAM_we_n <= 1'b1;
				
				M1_state <= leadOut_10;
			 end
			 
			  leadOut_10:begin
					u_minus_5 <= u_minus_3;
					u_minus_3 <= u_minus_1;
					u_minus_1 <= u_plus_1;
					u_plus_1 <= u_plus_3;		
					u_plus_3 <= u_plus_5;
									
					v_minus_5 <= v_minus_3;
					v_minus_3 <= v_minus_1;
					v_minus_1 <= v_plus_1;
					v_plus_1 <= v_plus_3;		
					v_plus_3 <= v_plus_5;

					R[1] <= Mult1_result+Mult2_result;
					G[1] <= Mult1_result+Mult3_result+Mult4_result;
					
					Mult3_op_1 <= u_even_prime-128;
					Mult3_op_2 <= 132251;
					Mult4_op_1 <= {24'd0,y_buf[7:0]} - 32'd16;
					Mult4_op_2 <= 76284;	
					
					M1_state <= leadOut_11;
			  end
			 
			 leadOut_11:begin
			   SRAM_address <= y_address;
				y_address <= y_address+1'd1;
				
				Mult1_op_1 <= v_odd_prime-128;
				Mult1_op_2 <= 104595;
				Mult2_op_1 <= u_odd_prime-128;
				Mult2_op_2 <= -25624;
				Mult3_op_1 <= v_odd_prime-128;
				Mult3_op_2 <= -53281;
				Mult4_op_1 <= u_odd_prime-128;
				Mult4_op_2 <= 132251;	
				a00y_odd_buff <= Mult4_result;
				
				B[1] <= Mult1_result+Mult3_result;
		
				M1_state <= leadOut_12;
			 end
			 
			 leadOut_12:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_we_n <= 1'b0;
				
				SRAM_write_data[15:8] <= R_write[1];
				SRAM_write_data[7:0] <= G_write[1];
				
				R[0] <= a00y_odd_buff+Mult1_result;
				G[0] <= a00y_odd_buff+Mult2_result+Mult3_result;
				B[0] <= a00y_odd_buff+Mult4_result;
				
				Mult1_op_1 <= u_minus_5;
				Mult1_op_2 <= 21;
				Mult2_op_1 <= u_minus_3;
				Mult2_op_2 <= -52;
				Mult3_op_1 <= u_minus_1;
				Mult3_op_2 <= 159;
				Mult4_op_1 <= u_plus_1;
				Mult4_op_2 <= 159;
				
				M1_state <= leadOut_13;
			 end
			 
			 leadOut_13:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= B_write[1];
				SRAM_write_data[7:0] <= R_write[0];
				
				u_even_prime <= u_minus_1;
				v_even_prime <= v_minus_1;
				
				uAC <= Mult1_result+Mult2_result+Mult3_result+Mult4_result;	
				
				Mult1_op_1 <= u_plus_3;
				Mult1_op_2 <= -52;
				Mult2_op_1 <= u_plus_5;
				Mult2_op_2 <= 21;
				Mult3_op_1 <= v_minus_5;
				Mult3_op_2 <= 21;
				Mult4_op_1 <= v_minus_3;
				Mult4_op_2 <= -52;			
				
				M1_state <= leadOut_14;
			 end
			 
			 leadOut_14:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= G_write[0];
				SRAM_write_data[7:0] <= B_write[0];
				
				y_buf <= SRAM_read_data;
				
				u_odd_prime <= (uAC+Mult1_result+Mult2_result+128)>>>8;
				vAC <= Mult3_result+Mult4_result;
				
				Mult1_op_1 <= v_minus_1;
				Mult1_op_2 <= 159;
				Mult2_op_1 <= v_plus_1;
				Mult2_op_2 <= 159;
				Mult3_op_1 <= v_plus_3;
				Mult3_op_2 <= -52;
				Mult4_op_1 <= v_plus_5;
				Mult4_op_2 <= 21;		
				
				M1_state <= leadOut_15;
			 end
			 
			 leadOut_15:begin
				v_odd_prime <= (vAC+Mult1_result+Mult2_result+Mult3_result+Mult4_result+128)>>>8;
				
				Mult1_op_1 <={24'd0, y_buf[15:8]}-32'd16;
				Mult1_op_2 <= 76284;
				Mult2_op_1 <= v_even_prime-128;
				Mult2_op_2 <= 104595;
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= -25624;
				Mult4_op_1 <= v_even_prime-128;
				Mult4_op_2 <= -53281;		
				
				SRAM_we_n <= 1'b1;
				
				M1_state <= leadOut_16;
			 end
			 
			 leadOut_16:begin
				u_minus_5 <= u_minus_3;
				u_minus_3 <= u_minus_1;
				u_minus_1 <= u_plus_1;
				u_plus_1 <= u_plus_3;		
				u_plus_3 <= u_plus_5;
					
					
				v_minus_5 <= v_minus_3;
				v_minus_3 <= v_minus_1;
				v_minus_1 <= v_plus_1;
				v_plus_1 <= v_plus_3;		
				v_plus_3 <= v_plus_5;

				R[1] <= Mult1_result+Mult2_result;
				G[1] <= Mult1_result+Mult3_result+Mult4_result;
					
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= 132251;
				Mult4_op_1 <= {24'd0,y_buf[7:0]} - 32'd16;
				Mult4_op_2 <= 76284;	
					
				M1_state <= leadOut_17;
			 end
			 
			 leadOut_17:begin
				SRAM_address <= y_address;
				y_address <= y_address+1'd1;
				
				Mult1_op_1 <= v_odd_prime-128;
				Mult1_op_2 <= 104595;
				Mult2_op_1 <= u_odd_prime-128;
				Mult2_op_2 <= -25624;
				Mult3_op_1 <= v_odd_prime-128;
				Mult3_op_2 <= -53281;
				Mult4_op_1 <= u_odd_prime-128;
				Mult4_op_2 <= 132251;	
				a00y_odd_buff <= Mult4_result;
				
				B[1] <= Mult1_result+Mult3_result;
				
				
				
				M1_state <= leadOut_18;
			 end
			 
			 leadOut_18:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_we_n <= 1'b0;
				
				SRAM_write_data[15:8] <= R_write[1];
				SRAM_write_data[7:0] <= G_write[1];
				
				R[0] <= a00y_odd_buff+Mult1_result;
				G[0] <= a00y_odd_buff+Mult2_result+Mult3_result;
				B[0] <= a00y_odd_buff+Mult4_result;
				
				Mult1_op_1 <= u_minus_5;
				Mult1_op_2 <= 21;
				Mult2_op_1 <= u_minus_3;
				Mult2_op_2 <= -52;
				Mult3_op_1 <= u_minus_1;
				Mult3_op_2 <= 159;
				Mult4_op_1 <= u_plus_1;
				Mult4_op_2 <= 159;
				
				M1_state <= leadOut_19;
			 end
			 
			 leadOut_19:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= B_write[1];
				SRAM_write_data[7:0] <= R_write[0];
				
				u_even_prime <= u_minus_1;
				v_even_prime <= v_minus_1;
				
				uAC <= Mult1_result+Mult2_result+Mult3_result+Mult4_result;	
				
				Mult1_op_1 <= u_plus_3;
				Mult1_op_2 <= -52;
				Mult2_op_1 <= u_plus_5;
				Mult2_op_2 <= 21;
				Mult3_op_1 <= v_minus_5;
				Mult3_op_2 <= 21;
				Mult4_op_1 <= v_minus_3;
				Mult4_op_2 <= -52;			
				
				M1_state <= leadOut_20;
			 end
			 
			 leadOut_20:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= G_write[0];
				SRAM_write_data[7:0] <= B_write[0];
				
				y_buf <= SRAM_read_data;
				
				u_odd_prime <= (uAC+Mult1_result+Mult2_result+128)>>>8;
				vAC <= Mult3_result+Mult4_result;
				
				Mult1_op_1 <= v_minus_1;
				Mult1_op_2 <= 159;
				Mult2_op_1 <= v_plus_1;
				Mult2_op_2 <= 159;
				Mult3_op_1 <= v_plus_3;
				Mult3_op_2 <= -52;
				Mult4_op_1 <= v_plus_5;
				Mult4_op_2 <= 21;		
				
				M1_state <= leadOut_21;
			 end
			 
			 leadOut_21:begin
				v_odd_prime <= (vAC+Mult1_result+Mult2_result+Mult3_result+Mult4_result+128)>>>8;
				
				Mult1_op_1 <= {24'd0, y_buf[15:8]}-32'd16;
				Mult1_op_2 <= 76284;
				Mult2_op_1 <= v_even_prime-128;
				Mult2_op_2 <= 104595;
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= -25624;
				Mult4_op_1 <= v_even_prime-128;
				Mult4_op_2 <= -53281;		
				
				SRAM_we_n <= 1'b1;
				
				M1_state <= leadOut_22;
			 end
			 
			 leadOut_22:begin
				u_minus_5 <= u_minus_3;
				u_minus_3 <= u_minus_1;
				u_minus_1 <= u_plus_1;
				u_plus_1 <= u_plus_3;		
				u_plus_3 <= u_plus_5;
					
					
				v_minus_5 <= v_minus_3;
				v_minus_3 <= v_minus_1;
				v_minus_1 <= v_plus_1;
				v_plus_1 <= v_plus_3;		
				v_plus_3 <= v_plus_5;

				R[1] <= Mult1_result+Mult2_result;
				G[1] <= Mult1_result+Mult3_result+Mult4_result;
					
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= 132251;
				Mult4_op_1 <= {24'd0,y_buf[7:0]} - 32'd16;
				Mult4_op_2 <= 76284;	
					
				M1_state <= leadOut_23;
			 end
			 
			 leadOut_23:begin
				SRAM_address <= y_address;
				y_address <= y_address+1'd1;
				
				Mult1_op_1 <= v_odd_prime-128;
				Mult1_op_2 <= 104595;
				Mult2_op_1 <= u_odd_prime-128;
				Mult2_op_2 <= -25624;
				Mult3_op_1 <= v_odd_prime-128;
				Mult3_op_2 <= -53281;
				Mult4_op_1 <= u_odd_prime-128;
				Mult4_op_2 <= 132251;	
				a00y_odd_buff <= Mult4_result;
				
				B[1] <= Mult1_result+Mult3_result;
				
				
				
				M1_state <= leadOut_24;
			 end
			 
			 leadOut_24:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_we_n <= 1'b0;
				
				SRAM_write_data[15:8] <= R_write[1];
				SRAM_write_data[7:0] <= G_write[1];
				
				R[0] <= a00y_odd_buff+Mult1_result;
				G[0] <= a00y_odd_buff+Mult2_result+Mult3_result;
				B[0] <= a00y_odd_buff+Mult4_result;
				
				Mult1_op_1 <= u_minus_5;
				Mult1_op_2 <= 21;
				Mult2_op_1 <= u_minus_3;
				Mult2_op_2 <= -52;
				Mult3_op_1 <= u_minus_1;
				Mult3_op_2 <= 159;
				Mult4_op_1 <= u_plus_1;
				Mult4_op_2 <= 159;
				
				M1_state <= leadOut_25;
			 end
			 
			 leadOut_25:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= B_write[1];
				SRAM_write_data[7:0] <= R_write[0];
				
				u_even_prime <= u_minus_1;
				v_even_prime <= v_minus_1;
				
				uAC <= Mult1_result+Mult2_result+Mult3_result+Mult4_result;	
				
				Mult1_op_1 <= u_plus_3;
				Mult1_op_2 <= -52;
				Mult2_op_1 <= u_plus_5;
				Mult2_op_2 <= 21;
				Mult3_op_1 <= v_minus_5;
				Mult3_op_2 <= 21;
				Mult4_op_1 <= v_minus_3;
				Mult4_op_2 <= -52;			
				
				M1_state <= leadOut_26;
			 end
			 
			 leadOut_26:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= G_write[0];
				SRAM_write_data[7:0] <= B_write[0];
				
				y_buf <= SRAM_read_data;
				
				u_odd_prime <= (uAC+Mult1_result+Mult2_result+128)>>>8;
				vAC <= Mult3_result+Mult4_result;
				
				Mult1_op_1 <= v_minus_1;
				Mult1_op_2 <= 159;
				Mult2_op_1 <= v_plus_1;
				Mult2_op_2 <= 159;
				Mult3_op_1 <= v_plus_3;
				Mult3_op_2 <= -52;
				Mult4_op_1 <= v_plus_5;
				Mult4_op_2 <= 21;		
				M1_state <= leadOut_27;
			 end
			 
			 leadOut_27:begin
				v_odd_prime <= (vAC+Mult1_result+Mult2_result+Mult3_result+Mult4_result+128)>>>8;
				
				Mult1_op_1 <= {24'd0, y_buf[15:8]}-32'd16;
				Mult1_op_2 <= 76284;
				Mult2_op_1 <= v_even_prime-128;
				Mult2_op_2 <= 104595;
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= -25624;
				Mult4_op_1 <= v_even_prime-128;
				Mult4_op_2 <= -53281;		
				
				SRAM_we_n <= 1'b1;
				
				M1_state <= leadOut_28;
			 end
			 
			leadOut_28:begin
				R[1] <= Mult1_result+Mult2_result;
				G[1] <= Mult1_result+Mult3_result+Mult4_result;
					
				Mult3_op_1 <= u_even_prime-128;
				Mult3_op_2 <= 132251;
				Mult4_op_1 <= {24'd0,y_buf[7:0]} - 32'd16;
				Mult4_op_2 <= 76284;	
					
				M1_state <= leadOut_29;
			 end
			 
			 leadOut_29:begin
				Mult1_op_1 <= v_odd_prime-128;
				Mult1_op_2 <= 104595;
				Mult2_op_1 <= u_odd_prime-128;
				Mult2_op_2 <= -25624;
				Mult3_op_1 <= v_odd_prime-128;
				Mult3_op_2 <= -53281;
				Mult4_op_1 <= u_odd_prime-128;
				Mult4_op_2 <= 132251;	
				a00y_odd_buff <= Mult4_result;
				
				B[1] <= Mult1_result+Mult3_result;
				
				
				
				M1_state <= leadOut_30;
			 end
			 
			 leadOut_30:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_we_n <= 1'b0;
				
				SRAM_write_data[15:8] <= R_write[1];
				SRAM_write_data[7:0] <= G_write[1];
				
				R[0] <= a00y_odd_buff+Mult1_result;
				G[0] <= a00y_odd_buff+Mult2_result+Mult3_result;
				B[0] <= a00y_odd_buff+Mult4_result;
				
				M1_state <= leadOut_31;
			 end
			 
			 leadOut_31:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= B_write[1];
				SRAM_write_data[7:0] <= R_write[0];	
				
				M1_state <= leadOut_32;
			 end
			 
			 leadOut_32:begin
				SRAM_address <= rgb_address;
				rgb_address <= rgb_address+1'd1;
				
				SRAM_write_data[15:8] <= G_write[0];
				SRAM_write_data[7:0] <= B_write[0];
				
				if(y_address >= 38400)begin
					M1_state <= M1_finish;
				end else begin
					M1_state <= M1_IDLE;
				end
			 end
			 
			 M1_finish:begin
				SRAM_we_n <= 1'b1;
				done <= 1'b1;
				M1_state <= M1_IDLE;
			 end
			 
			endcase
	end
end
endmodule
	 