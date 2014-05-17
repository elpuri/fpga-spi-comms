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

entity seven_seg_scanner is port (
	clk : in std_logic;
	anodes : out std_logic_vector(3 downto 0);
	segments : out std_logic_vector(7 downto 0);
	value0 : in std_logic_vector(3 downto 0);
	value1 : in std_logic_vector(3 downto 0);
	value2 : in std_logic_vector(3 downto 0);
	value3 : in std_logic_vector(3 downto 0)
);
end seven_seg_scanner;

architecture Behavioral of seven_seg_scanner is

signal tick : std_logic;
signal clk_div : std_logic_vector(15 downto 0);
signal active_segment : std_logic_vector(1 downto 0);
signal encoded_segments : std_logic_vector(6 downto 0);
signal current_value : std_logic_vector(3 downto 0);

begin
	process(clk)
	begin
		if (clk'event and clk = '1') then
			clk_div <= clk_div + 1;
			if (tick = '1') then
				active_segment <= active_segment + 1;
			end if;
		end if;
	end process;
	
	tick <= '1' when clk_div = 0 else '0';

	process(active_segment)
	begin
		case active_segment is
			when "00" =>
				anodes <= "1110";
				current_value <= value0;
			when "01" =>
				anodes <= "1101";
				current_value <= value1;
			when "10" =>
				anodes <= "1011";
				current_value <= value2;
			when "11" =>
				anodes <= "0111";
				current_value <= value3;
		end case;
	end process;
	
	encoder : entity work.bin_to_7seg port map (
		value => current_value,
		display => encoded_segments
	);
	
	segments <= encoded_segments & "1";
end;
