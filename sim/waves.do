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
add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue



add wave -divider -height 20 {Top-level signals}

add wave UUT/M2_unit/state
add wave -dec UUT/M2_unit/SRAM_address
add wave -bin UUT/M2_unit/SRAM_we_n
add wave -dec UUT/M2_unit/SRAM_read_data
add wave -dec UUT/M2_unit/SRAM_write_data
add wave -dec UUT/M2_unit/block_counter


add wave -divider -height 20 {Top-level signals}

add wave UUT/M2_unit/FS_unit/state
add wave -dec UUT/M2_unit/FS_unit/SRAM_address
add wave -bin UUT/M2_unit/FS_unit/SRAM_we_n
add wave -dec UUT/M2_unit/FS_unit/SRAM_read_data
add wave -dec UUT/M2_unit/FS_unit/SRAM_write_data
add wave -dec UUT/M2_unit/FS_unit/fetch_buff
add wave -dec UUT/M2_unit/FS_unit/write_data_a

add wave -divider -height 20 {Top-level signals}

add wave UUT/M2_unit/CT_unit/state
add wave -dec UUT/M2_unit/CT_unit/read_data_a0
add wave -dec UUT/M2_unit/CT_unit/address_0
add wave -dec UUT/M2_unit/CT_unit/address_2
add wave -dec UUT/M2_unit/CT_unit/address_3
add wave -dec UUT/M2_unit/CT_unit/add3

add wave -divider -height 20 {Top-level signals}

add wave UUT/M2_unit/CS_unit/state

add wave -dec UUT/M2_unit/CS_unit/add3

add wave -divider -height 20 {Top-level signals}

add wave UUT/M2_unit/WS_unit/state
add wave -dec UUT/M2_unit/WS_unit/SRAM_address
add wave -bin UUT/M2_unit/WS_unit/SRAM_we_n
add wave -dec UUT/M2_unit/WS_unit/SRAM_read_data
add wave -dec UUT/M2_unit/WS_unit/SRAM_write_data
add wave -dec UUT/M2_unit/WS_unit/S0_clip
add wave -dec UUT/M2_unit/WS_unit/S1_clip


add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/M2_unit/WS_done
add wave -bin UUT/M2_unit/WS_enable
add wave -bin UUT/M2_unit/FS_done
add wave -bin UUT/M2_unit/FS_enable
add wave -bin UUT/M2_unit/CS_done
add wave -bin UUT/M2_unit/CS_enable
add wave -bin UUT/M2_unit/CT_done
add wave -bin UUT/M2_unit/CT_enable

