-- Copyright (c) 2014, Juha Turunen
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met: 
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer. 
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution. 
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

entity spi_slave_ep1_top is port (
	clk_50 : in std_logic;
	
	p4 : in std_logic;
	p6 : in std_logic;
	p7 : out std_logic;
	leds : out std_logic_vector(3 downto 0);
	
	seven_seg_an : out std_logic_vector(3 downto 0);
	seven_seg : out std_logic_vector(7 downto 0)
);
end spi_slave_ep1_top;


architecture Behavioral of spi_slave_ep1_top is

signal spi_sclk_raw, spi_mosi_raw, spi_miso : std_logic;
signal spi_sclk, spi_mosi : std_logic;
signal display_anodes : std_logic_vector(3 downto 0);
signal display_segments : std_logic_vector(7 downto 0);
signal incoming_data, incoming_data_next : std_logic_vector(15 downto 0);
signal output_byte, output_byte_next, spi_data_byte : std_logic_vector(7 downto 0);
signal reset, spi_tick : std_logic;
begin

	reset <= '0';

	process(clk_50)
	begin
		if (clk_50'event and clk_50 = '1') then
			incoming_data <= incoming_data_next;
			output_byte <= output_byte_next;
		end if;
	end process;

	spi_mosi_raw <= p4;
	spi_sclk_raw <= p6;
	p7 <= spi_miso;
	
	leds(0) <= spi_sclk_raw;
	leds(1) <= spi_sclk_raw;
	
	-- Synchronize foreign signals
	sclk_sync : entity work.two_stage_synch 
	generic map (WIDTH => 2)
	port map (
		clk => clk_50,
		input(0) => spi_mosi_raw,
		input(1) => spi_sclk_raw,
		output(0) => spi_mosi,
		output(1) => spi_sclk
	);
	
	
	displays : entity work.seven_seg_scanner port map (
		clk => clk_50,
		value3 => incoming_data(15 downto 12),
		value2 => incoming_data(11 downto 8),
		value1 => incoming_data(7 downto 4),
		value0 => incoming_data(3 downto 0),
		segments => display_segments,
		anodes => display_anodes
	);
	
	seven_seg_an <= display_anodes;
	seven_seg <= display_segments;
	
	spi_slave : entity work.spi_slave port map (
		clk => clk_50,
		reset => reset,
		sclk => spi_sclk,
		mosi => spi_mosi,
		miso => spi_miso,
		data_in => output_byte,
		data_out => spi_data_byte,
		byte_tick => spi_tick
	);
	
	process(spi_tick, output_byte, incoming_data, spi_data_byte)
	begin
		incoming_data_next <= incoming_data;
		output_byte_next <= output_byte;
		
		if (spi_tick = '1') then
			output_byte_next <= output_byte + 1;
			incoming_data_next <= incoming_data(7 downto 0) & spi_data_byte;
		end if;
	end process;
	
end Behavioral;