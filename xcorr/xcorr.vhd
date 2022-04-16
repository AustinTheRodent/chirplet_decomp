----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2022 12:25:51 PM
-- Design Name: 
-- Module Name: xcorr - Behavioral
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

entity xcorr is
    Port (clk,signalvalid,chirpvalid: in STD_LOGIC;
    inputchirp: in std_logic_vector(0 to 1023);
    inputsignal: in std_logic_vector(0 to 1023);
    outvalid: out STD_LOGIC;
    output: out unsigned(0 to 47));
end xcorr;

architecture Behavioral of xcorr is

type arraysignal is array(0 to 100000) of unsigned(15 downto 0);
type signalbuffer is array(0 to 63) of unsigned(15 downto 0);
type outputbuffer is array(0 to 63) of unsigned(47 downto 0);

signal sig: arraysignal;
signal partialsum: outputbuffer;

signal state: integer;
signal finaladditionstate: integer;
signal siginstate: integer;
    
begin
  process(clk) -- add chirplet from axi port to partial convolution buffer
  begin 
    if chirpvalid='1' then
      if state/=1564 then
        for j in 0 to 63 loop 
          partialsum(j) <= partialsum(j) + sig(state*64+j) * unsigned(inputchirp(16j to 16j+15));
        end loop;
        state <=state+1;
      end if;
    end if;
  end process;
  
  process(clk) -- store signal
  begin 
    if signalvalid='0' then
      for j in 0 to 63 loop
        partialsum(siginstate*64+j) <= unsigned(inputsignal(16j to 16j+15));
      end loop;
      siginstate <=siginstate+1;
      if siginstate=1563 then
        siginstate<=0;
      else
        siginstate <= siginstate+1;
      end if;
    end if;
  end process;
  
  process(clk) -- final addition and output
  begin 
    if state=1564 and finaladditionstate/=6 then
      for j in 0 to 31 loop
        partialsum(j) <=partialsum(2j)+partialsum(2j+1);
      end loop;
      finaladditionstate<=finaladditionstate+1;
    elsif state=1564 and finaladditionstate/=6 then
      if outvalid='1' then
        outvalid<='0';
        state<=0;
        finaladditionstate<=0;
      else
        outvalid<='1';
        output<=partialsum(0);
      end if;
    end if;
  end process;
  
end Behavioral;
