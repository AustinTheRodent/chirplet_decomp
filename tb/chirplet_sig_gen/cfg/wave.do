onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_minus_tau_sqr_dout_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_minus_tau_sqr_dout_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_minus_tau_sqr_din_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_minus_tau_sqr_din_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_minus_tau_dout_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_minus_tau_dout_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_minus_tau_sqr_din_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_m_tau_times_fc_din_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_m_tau_times_fc_dout_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/t_m_tau_times_fc_fixed_dout_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/fc_sine_lut_dout_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/phi_sine_lut_dout_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/fc_sine_lut_dout_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/fc_times_phi_din_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/alpha2_times_gauss_dout_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2220000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
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
WaveRestoreZoom {0 ps} {6531 ns}
