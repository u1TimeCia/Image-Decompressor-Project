`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [2:0] {
	S_IDLE,
	S_UART_RX,
	S_M1,
	S_M2
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic[5:0] {
	M1_IDLE,
	leadIn_0,
	leadIn_1,
	leadIn_2,
	leadIn_3,
	leadIn_4,
	leadIn_5,
	leadIn_6,
	leadIn_7,
	leadIn_8,
	leadIn_9,
	cc_0,
	cc_1,
	cc_2,
	cc_3,
	cc_4,
	cc_5,
	leadOut_0,
	leadOut_1,
	leadOut_2,
	leadOut_3,
	leadOut_4,
	leadOut_5,
	leadOut_6,
	leadOut_7,
	leadOut_8,
	leadOut_9,
	leadOut_10,
	leadOut_11,
	leadOut_12,
	leadOut_13,
	leadOut_14,
	leadOut_15,
	leadOut_16,
	leadOut_17,
	leadOut_18,
	leadOut_19,
	leadOut_20,
	leadOut_21,
	leadOut_22,
	leadOut_23,
	leadOut_24,
	leadOut_25,
	leadOut_26,
	leadOut_27,
	leadOut_28,
	leadOut_29,
	leadOut_30,
	leadOut_31,
	leadOut_32,
	
	M1_finish
} M1_state_type;

typedef enum logic[5:0] {
	M2_IDLE0,
	M2_IDLE1,
	M2_IDLE2,
	LI_fetch_s_prime_cc,
	LI_fetch_s_prime_lo0,
	LI_fetch_s_prime_lo1,
	LI_fetch_s_prime_lo2,
	LI_CT_0,
	LI_CT_1,
	LI_CT_2,
	LI_CT_cc0,
	LI_CT_cc1,
	LI_CT_cc2,
	LI_CT_cc3,
	LO_CT0,
	LO_CT1,
	LO_CT2,
	LI_CS_FS,
	LI_CS_FS_0,
	LI_CS_FS_1,
	LI_CS_FS_2,
	CC_CS_FS_0,
	CC_CS_FS_1,
	CC_CS_FS_2,
	CC_CS_FS_3,
	LO_CS_FS_0,
	LO_CS_FS_1,
	LO_CS_FS_2,
	LO_CS_FS_3,
	LI_WS_CT_0,
	LI_WS_CT_1,
	LI_WS_CT_2,
	CC_WS_CT_0,
	CC_WS_CT_1,
	CC_WS_CT_2,
	CC_WS_CT_3,
	LO_WS_CT_0,
	LO_WS_CT_1,
	LO_WS_CT_2,
	LI_CS_0,
	LI_CS_1,
	LI_CS_2,
	LI_CS_3,
	CC_CS_0,
	CC_CS_1,
	CC_CS_2,
	CC_CS_3,
	LO_CS_0,
	LO_CS_1,
	LO_CS_2,
	LO_CS_3,
	LI_WS_0,
	LI_WS_1,
	CC_WS_0,
	CC_WS_1,
	CC_WS_2,
	LO_WS_0,
	finish

} M2_state_type;

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

// Define the offset for yuv in the memory		
parameter Y_BASE_ADDRESS = 18'd76800,
	U_BASE_ADDRESS = 18'd153600,
	V_BASE_ADDRESS = 18'd192000,
	BLUE_ODD_BASE_ADDRESS = 18'd242944;


`define DEFINE_STATE 1
`endif
