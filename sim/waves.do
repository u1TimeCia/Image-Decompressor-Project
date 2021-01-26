# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data
add wave -hex UUT/M1_start
add wave -hex UUT/M2_start
add wave -hex UUT/M2_done


add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue



add wave -uns UUT/M2_unit/SRAM_address;
add wave -hex UUT/M2_unit/SRAM_read_data;
add wave -uns UUT/M2_unit/BASE_ADDRESS;



add wave -hex UUT/M2_unit/M2_state;
add wave -uns UUT/M2_unit/cs_counter;
add wave -hex UUT/M2_unit/s_prime_buf;

add wave -uns UUT/M2_unit/col_block_index;
add wave -uns UUT/M2_unit/row_block_index;

add wave -uns UUT/M2_unit/address_a;
add wave -hex UUT/M2_unit/write_data_a;
add wave -hex UUT/M2_unit/write_enable_a;
add wave -hex UUT/M2_unit/write_data_b;
add wave -hex UUT/M2_unit/write_enable_b;
add wave -hex UUT/M2_unit/S0;
add wave -hex UUT/M2_unit/S0_buf_w;
add wave -hex UUT/M2_unit/S0_w;
add wave -hex UUT/M2_unit/S8;
add wave -hex UUT/M2_unit/S8_buf_w;
add wave -hex UUT/M2_unit/S8_w;
add wave -hex UUT/M2_unit/col_index;
add wave -hex UUT/M2_unit/row_index;

add wave -uns UUT/M2_unit/address_a;
add wave -uns UUT/M2_unit/address_b;
add wave -hex UUT/M2_unit/read_data_a;
add wave -uns UUT/M2_unit/address_b;
add wave -uns UUT/M2_unit/add_buf1;
add wave -uns UUT/M2_unit/add_buf2;
add wave -hex UUT/M2_unit/read_data_b;
add wave -uns UUT/M2_unit/ct_counter;

add wave -hex UUT/M2_unit/T0;
add wave -hex UUT/M2_unit/T1;
add wave -hex UUT/M2_unit/T2;
add wave -hex UUT/M2_unit/T3;
add wave -hex UUT/M2_unit/T4;
add wave -hex UUT/M2_unit/T5;
add wave -hex UUT/M2_unit/T6;
add wave -hex UUT/M2_unit/T7;

add wave -hex UUT/M2_unit/Mult1_result;
add wave -hex UUT/M2_unit/Mult2_result;
add wave -hex UUT/M2_unit/Mult3_result;
add wave -hex UUT/M2_unit/Mult4_result;
add wave -uns UUT/M2_unit/C_0;
add wave -uns UUT/M2_unit/C_1;
add wave -uns UUT/M2_unit/C_2;
add wave -uns UUT/M2_unit/C_3;
add wave -uns UUT/M2_unit/cs_counter;
add wave -hex UUT/M2_unit/Mult1_op;
add wave -hex UUT/M2_unit/Mult2_op;
add wave -hex UUT/M2_unit/Mult3_op;
add wave -hex UUT/M2_unit/Mult4_op;


















