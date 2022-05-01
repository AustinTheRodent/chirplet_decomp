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
  inputchirpimag: in std_logic_vector(0 to 1023);
  inputsignal: in std_logic_vector(0 to 1023);
  inputsignalimag: in std_logic_vector(0 to 1023);
  outvalid: out STD_LOGIC;
  output: out signed(0 to 95));
end xcorr;

architecture Behavioral of xcorr is

type arraysignal is array(0 to 100000) of signed(15 downto 0);
type signalbuffer is array(0 to 63) of signed(15 downto 0);
type outputbuffer is array(0 to 63) of signed(47 downto 0);

signal sig: arraysignal;
signal sigimag: arraysignal;
signal partialsum: outputbuffer := (others=>(others=>'0'));
signal partialsumimag: outputbuffer := (others=>(others=>'0'));

signal state: unsigned(23 downto 0):= to_unsigned(0,24);
signal finaladditionstate: unsigned(3 downto 0):=to_unsigned(0,4);
signal siginstate: unsigned(23 downto 0):= to_unsigned(0,24);
signal done: std_logic:='0';
    
begin
  process(clk) 
  begin 
    outvalid<=done;
    if rising_edge(clk) and chirpvalid='1' then -- add chirplet from axi port to partial convolution buffer
      if state/=1562 and state/=1563 then
        for j in 0 to 63 loop 
          partialsum(j) <= partialsum(j) + sig(to_integer(state&to_unsigned(j,6))) * signed(inputchirp(16*j to 16*j+15)) + sigimag(to_integer(state&to_unsigned(j,6))) * signed(inputchirpimag(16*j to 16*j+15));
          partialsumimag(j) <= partialsumimag(j) + sigimag(to_integer(state&to_unsigned(j,6))) * signed(inputchirp(16*j to 16*j+15)) - sig(to_integer(state&to_unsigned(j,6))) * signed(inputchirpimag(16*j to 16*j+15));
        end loop;
        state <=state+1;
      end if;
      if state=1562 then
        for j in 0 to 32 loop 
          partialsum(j) <= partialsum(j) + sig(to_integer(state&to_unsigned(j,6))) * signed(inputchirp(16*j to 16*j+15)) + sigimag(to_integer(state&to_unsigned(j,6))) * signed(inputchirpimag(16*j to 16*j+15));
          partialsumimag(j) <= partialsumimag(j) + sigimag(to_integer(state&to_unsigned(j,6))) * signed(inputchirp(16*j to 16*j+15)) - sig(to_integer(state&to_unsigned(j,6))) * signed(inputchirpimag(16*j to 16*j+15));
        end loop;
        state <=state+1;
      end if;
    end if;
    
    if rising_edge(clk) and signalvalid='1' then -- store signal
      if siginstate/=1562 and siginstate/=1563 then
        for j in 0 to 63 loop
          sig(to_integer(siginstate&to_unsigned(j,6))) <= signed(inputsignal(16*j to 16*j+15));
          sigimag(to_integer(siginstate&to_unsigned(j,6))) <= signed(inputsignalimag(16*j to 16*j+15));
        end loop;
      end if;
      if siginstate=1562 then
        for j in 0 to 32 loop
          sig(to_integer(siginstate&to_unsigned(j,6))) <= signed(inputsignal(16*j to 16*j+15));
          sigimag(to_integer(siginstate&to_unsigned(j,6))) <= signed(inputsignalimag(16*j to 16*j+15));
        end loop;
      end if;
      if siginstate=1563 then
        siginstate<=to_unsigned(0,24);
      else
        siginstate <= siginstate+1;
      end if;
    end if;
    
    if rising_edge(clk) then -- final addition and output
      if state=1563 and finaladditionstate/=6 then
        for j in 0 to 31 loop
          partialsum(j) <=partialsum(2*j)+partialsum(2*j+1);
          partialsumimag(j) <=partialsumimag(2*j)+partialsumimag(2*j+1);
        end loop;
        finaladditionstate<=finaladditionstate+1;
      elsif state=1563 then
        if done='1' then
          done<='0';
          state<=to_unsigned(0,24);
          finaladditionstate<=to_unsigned(0,4);
          for j in 0 to 63 loop
            partialsum(j) <=to_signed(0,48);
            partialsumimag(j) <=to_signed(0,48);
          end loop;
        else
          done<='1';
          output(0 to 47)<=partialsum(0);
          output(48 to 95)<=partialsumimag(0);
        end if;
      end if;
    end if;
  end process;
  
end Behavioral;
