`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	S_Milestone_1,
	S_Milestone_2
} top_state_type;

typedef enum logic [8:0] {
	S_M1_IDLE,
    S_LI_0,
    S_LI_1,
    S_LI_2,
    S_LI_3,
    S_LI_4,
    S_LI_5,
    S_LI_6,
    S_LI_7,
    S_LI_8,
    S_LI_9,
    S_LI_10,
    S_LI_11,
    S_LI_12,
    S_LI_13,
	S_LI_14,
    S_CC_0,
    S_CC_1,
    S_CC_2,
    S_CC_3,
    S_CC_4,
    S_CC_5,
    S_CC_6,
    S_CC_7,
    S_CC_8,
    S_CC_9,
    S_CC_10,
    S_CC_11,
    S_CC_12,
    S_CC_13,
    S_LO_0,
    S_LO_1,
    S_LO_2,
    S_LO_3,
    S_LO_4,
    S_LO_5,
    S_LO_6,
    S_LO_7,
    S_LO_8,
	S_LO_9
} M1_state_type;

typedef enum logic [8:0] {
	IDLE,
	FETCH_ONLY,
	COMPUTE_T,
	MEGA_STATE_A,
	MEGA_STATE_B,
	COMPUTE_S,
	WRITE_S
} M2_state_type;

typedef enum logic [8:0] {
	Fetch_IDLE,
	Fetch_S0,
	Fetch_S1,
	Fetch_S2,
	Fetch_S3,
	Fetch_S4,
	Fetch_S5,
	Fetch_S6,
	Fetch_S7,
	Fetch_S8
} fetchS_state_type;

typedef enum logic [8:0] {
	compute_T_IDLE,
	Ct_Lead0,
	Ct_Lead1,
	Ct_Lead2,
	Ct_Lead3,
	Ct_Lead4,
	Ct_Lead5,
	Ct_Lead6,
	Ct_Lead7,
	Ct_Lead8,
	Ct_Lead9,
	Ct_Lead10,
	Ct_Lead11,
	Ct_Common0,
	Ct_Common1,
	Ct_Common2,
	Ct_Common3,
	Ct_Common4,
	Ct_Common5,
	Ct_Common6,
	Ct_Common7,
	Ct_LeadOut0,
	Ct_LeadOut1
} computeT_state_type;

typedef enum logic [8:0] {
	Compute_S_IDLE,
	LI0_CS,
	LI1_CS,
	LI2_CS,
	LI3_CS,
	LI4_CS,
	LI5_CS,
	LI6_CS,
	LI7_CS,
	LI8_CS,
	CC0_CS,
	CC1_CS,		
	CC2_CS,
	CC3_CS,
	CC4_CS,
	CC5_CS,
	CC6_CS,
	CC7_CS,
	LO0_CS,
	LO1_CS
} computeS_state_type;

typedef enum logic [8:0] {
	WS_IDLE,
	WS_0,
	WS_1,
	WS_2,
	WS_3
} writeS_state_type;

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

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
