# Single Color Leds
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports { HW_LED[0] }];
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports { HW_LED[1] }];
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports { SW_LED[0] }];
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports { SW_LED[1] }];
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports { BTN[0] }];
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports { BTN[1] }];
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports { BTN[2] }];
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports { BTN[3] }];

set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports { rpio_02_r }];
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports { rpio_03_r }];

set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports { rpio_14_r }];
set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33 } [get_ports { rpio_15_r }];
set_property -dict { PACKAGE_PIN C20   IOSTANDARD LVCMOS33 } [get_ports { rpio_18_r }];

#dual dma bs:
set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS33 } [get_ports { rpio_25_r }];
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports { rpio_08_r }];
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { rpio_07_r }];
