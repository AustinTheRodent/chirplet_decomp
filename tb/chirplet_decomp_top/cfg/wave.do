onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/clk
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/reset
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/enable
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/num_samps_out
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_tau
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_t_step
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_alpha1
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_f_c
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_alpha2
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_phi
add wave -noupdate -radix decimal /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_beta
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_valid
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/din_ready
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/dout
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/dout_valid
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/dout_ready
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_chirp_gen/dout_last
add wave -noupdate -radix hexadecimal -childformat {{/tb_chirplet_decomp_top/u_dut/registers.CONTROL -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.STATUS -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.CHIRP_GEN_NUM_SAMPS_OUT -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_TAU -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_T_STEP -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA1 -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_F_C -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA2 -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_PHI -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_BETA -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.XCORR_REF_SAMP -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.CONTROL_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.STATUS_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.CHIRP_GEN_NUM_SAMPS_OUT_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_TAU_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_T_STEP_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA1_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_F_C_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA2_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_PHI_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_BETA_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.XCORR_REF_SAMP_wr_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.CONTROL_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.STATUS_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.CHIRP_GEN_NUM_SAMPS_OUT_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_TAU_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_T_STEP_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA1_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_F_C_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA2_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_PHI_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.DIN_BETA_rd_pulse -radix hexadecimal} {/tb_chirplet_decomp_top/u_dut/registers.XCORR_REF_SAMP_rd_pulse -radix hexadecimal}} -expand -subitemconfig {/tb_chirplet_decomp_top/u_dut/registers.CONTROL {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.STATUS {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.CHIRP_GEN_NUM_SAMPS_OUT {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_TAU {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_T_STEP {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA1 {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_F_C {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA2 {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_PHI {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_BETA {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.XCORR_REF_SAMP {-height 15 -radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.CONTROL_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.STATUS_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.CHIRP_GEN_NUM_SAMPS_OUT_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_TAU_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_T_STEP_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA1_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_F_C_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA2_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_PHI_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_BETA_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.XCORR_REF_SAMP_wr_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.CONTROL_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.STATUS_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.CHIRP_GEN_NUM_SAMPS_OUT_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_TAU_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_T_STEP_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA1_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_F_C_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_ALPHA2_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_PHI_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.DIN_BETA_rd_pulse {-radix hexadecimal} /tb_chirplet_decomp_top/u_dut/registers.XCORR_REF_SAMP_rd_pulse {-radix hexadecimal}} /tb_chirplet_decomp_top/u_dut/registers
add wave -noupdate /tb_chirplet_decomp_top/G_CHIRPLET_SAMPS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1293545 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 248
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {3255 ns}
