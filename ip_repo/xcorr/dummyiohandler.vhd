-- placeholder i/o to allow implementation due to not enough

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/05/2022 09:18:02 PM
-- Design Name: 
-- Module Name: dummyiohandler - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dummyiohandler is
  Port (clk,signalvalid,chirpvalid: in STD_LOGIC;
  inputsignal: in std_logic_vector(0 to 127);
  inputsignalimag: in std_logic_vector(0 to 127);
  outvalid: out STD_LOGIC;
  output: out signed(0 to 95));
end dummyiohandler;

architecture Behavioral of dummyiohandler is

component xcorr is
  Port (clk,reset,signalvalid,chirpvalid: in STD_LOGIC;
  inputchirp: in std_logic_vector(0 to 1023);
  inputchirpimag: in std_logic_vector(0 to 1023);
  inputsignal: in std_logic_vector(0 to 1023);
  inputsigimag: in std_logic_vector(0 to 1023);
  outvalid: out STD_LOGIC;
  output: out signed(0 to 95));
end component;

signal inputchirp: std_logic_vector(0 to 127);
signal inputchirpimag: std_logic_vector(0 to 127);
signal tmp1: std_logic_vector(0 to 1023);
signal tmp2: std_logic_vector(0 to 1023);
signal tmp3: std_logic_vector(0 to 1023);
signal tmp4: std_logic_vector(0 to 1023);
signal reset: std_logic := '0';

begin
  xcorrmodule : xcorr port map(clk=>clk,reset=>reset,signalvalid=>signalvalid,chirpvalid=>chirpvalid,
  inputchirp=>tmp1,
  inputchirpimag=>tmp2,
  inputsignal=>tmp3,
  inputsigimag=>tmp4,
  outvalid=>outvalid,
  output=>output);


end Behavioral;
