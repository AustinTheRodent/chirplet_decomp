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
  output: out signed(0 to 47));
end xcorr;

architecture Behavioral of xcorr is

type arraysignal is array(0 to 100000) of signed(15 downto 0);
type signalbuffer is array(0 to 63) of signed(15 downto 0);
type outputbuffer is array(0 to 63) of signed(47 downto 0);

signal sig: arraysignal;
signal partialsum: outputbuffer := (others=>(others=>'0'));

signal state: integer:= 0;
signal finaladditionstate: integer:=0;
signal siginstate: integer:= 0;
signal done: std_logic:='0';
    
begin
  process(clk) 
  begin 
    outvalid<=done;
    if rising_edge(clk) and chirpvalid='1' then -- add chirplet from axi port to partial convolution buffer
      if state/=1562 and state/=1563 then
        for j in 0 to 63 loop 
          partialsum(j) <= partialsum(j) + sig(state*64+j) * signed(inputchirp(16*j to 16*j+15));
        end loop;
        state <=state+1;
      end if;
      if state=1562 then
        for j in 0 to 32 loop 
          partialsum(j) <= partialsum(j) + sig(state*64+j) * signed(inputchirp(16*j to 16*j+15));
        end loop;
        state <=state+1;
      end if;
    end if;
    
    if rising_edge(clk) and signalvalid='1' then -- store signal
      if siginstate/=1562 and siginstate/=1563 then
        for j in 0 to 63 loop
          sig(siginstate*64+j) <= signed(inputsignal(16*j to 16*j+15));
        end loop;
      end if;
      if siginstate=1562 then
        for j in 0 to 32 loop
          sig(siginstate*64+j) <= signed(inputsignal(16*j to 16*j+15));
        end loop;
      end if;
      if siginstate=1563 then
        siginstate<=0;
      else
        siginstate <= siginstate+1;
      end if;
    end if;
    
    if rising_edge(clk) then -- final addition and output
      if state=1563 and finaladditionstate/=6 then
        for j in 0 to 31 loop
          partialsum(j) <=partialsum(2*j)+partialsum(2*j+1);
        end loop;
        finaladditionstate<=finaladditionstate+1;
      elsif state=1563 then
        if done='1' then
          done<='0';
          state<=0;
          finaladditionstate<=0;
          for j in 0 to 63 loop
            partialsum(j) <="000000000000000000000000000000000000000000000000";
          end loop;
        else
          done<='1';
          output<=partialsum(0);
        end if;
      end if;
    end if;
  end process;
  
end Behavioral;
