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
    Port (clk,signalvalid,chirpvalid: in STD_LOGIC;
    inputchirp: in std_logic_vector(0 to 1023);
    inputsignal: in std_logic_vector(0 to 1023);
    outvalid: out STD_LOGIC;
    output: out signed(0 to 47));
  end component;
  type signalbuffer is array(0 to 63) of signed(15 downto 0);
  
  signal clk,signalvalid,chirpvalid: STD_LOGIC;
  signal inputchirp: std_logic_vector(0 to 1023);
  signal inputsignal: std_logic_vector(0 to 1023);
  signal outvalid: STD_LOGIC;
  signal output: signed(0 to 47);
  signal tbstate: unsigned(0 to 15):="0000000000000000";
  
begin
  UUT: xcorr port map(clk,signalvalid,chirpvalid,inputchirp,inputsignal,outvalid,output);
  
  process
  begin
    -- clock rate of 10MHz
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    
    if tbstate<1564 then
      signalvalid<='1';
      for j in 0 to 63 loop
        inputsignal(16*j to 16*j+15)<=std_logic_vector(to_signed(1,16));
      end loop;
    end if;
    
    if tbstate>1563 and tbstate<3128 then
      signalvalid<='0';
      chirpvalid<='1';
      for j in 0 to 63 loop
        inputchirp(16*j to 16*j+15)<=std_logic_vector(to_signed(1,16));
      end loop;
    end if;
    
    if tbstate=3128 then
      chirpvalid<='0';
    else
      tbstate <=tbstate+1;
    end if;
  end process;
  process(outvalid)
  begin
    if rising_edge(outvalid) then
      report("xcorr="&to_string(to_integer(output)));
    elsif falling_edge(outvalid) then
      finish;
    end if;
  end process;
end Behavioral;
