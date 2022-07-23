----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2022 08:54:07 AM
-- Design Name: 
-- Module Name: xcorr_tb - Behavioral
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
use std.env.finish;

entity xcorr_tb is
end xcorr_tb;

architecture Behavioral of xcorr_tb is
  component xcorr
    Port (clk,reset,signalvalid,chirpvalid: in STD_LOGIC;
    inputchirp: in std_logic_vector(0 to 1023);
    inputchirpimag: in std_logic_vector(0 to 1023);
    inputsignal: in std_logic_vector(0 to 1023);
    inputsignimag: in std_logic_vector(0 to 1023);
    outvalid: out STD_LOGIC;
    output: out signed(0 to 95));
  end component;
  type signalbuffer is array(0 to 63) of signed(15 downto 0);
  
  signal clk,reset,signalvalid,chirpvalid: STD_LOGIC;
  signal inputchirp: std_logic_vector(0 to 1023);
  signal inputchirpimag: std_logic_vector(0 to 1023);
  signal inputsignal: std_logic_vector(0 to 1023);
  signal inputsignalimag: std_logic_vector(0 to 1023);
  signal outvalid: STD_LOGIC;
  signal output: signed(0 to 95);
  signal tbstate: unsigned(0 to 15):="0000000000000000";
  
begin
  UUT: xcorr port map(clk,reset,signalvalid,chirpvalid,inputchirp,inputchirpimag,inputsignal,inputsignalimag,outvalid,output);
  
  process
  begin
    -- clock rate of 10MHz, 8 out of 64 inputs generated per cycle so wait 8 cycles between inputs
    reset<= '0';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    
    if tbstate<316 then
      signalvalid<='1';
      for j in 0 to 63 loop
        inputsignal(16*j to 16*j+15)<=std_logic_vector(to_signed(1,16));
        inputsignalimag(16*j to 16*j+15)<=std_logic_vector(to_signed(1,16));
      end loop;
    end if;
    
    if tbstate>157 and tbstate<316 then
      signalvalid<='0';
      chirpvalid<='1';
      for j in 0 to 63 loop
        inputchirp(16*j to 16*j+15)<=std_logic_vector(to_signed(1,16));
        inputchirpimag(16*j to 16*j+15)<=std_logic_vector(to_signed(0,16));
      end loop;
    end if;
    
    if tbstate=316 then
      chirpvalid<='0';
    end if;
    tbstate <=tbstate+1;
  end process;
  process(outvalid,tbstate)
  begin
    if rising_edge(outvalid) then
      report("xcorr="&to_string(to_integer(output(0 to 47)))&"+"&to_string(to_integer(output(48 to 95)))&"i");
    elsif falling_edge(outvalid) then
      finish;
    end if;
  end process;
end Behavioral;
