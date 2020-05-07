library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL; 
 
entity frequency_divider is
    Port ( clk_in: in std_logic;				 -- clock input
           reset: in std_logic;	       -- reset input 
           clk_out: out std_logic		 -- output
     );
end frequency_divider;

architecture Behavioral of frequency_divider is
	
	signal temporal: STD_LOGIC;
	signal counter : integer range 0 to 15;
	
	begin
	freq_div: process (reset, clk_in) begin
	   if (reset = '1') then
            temporal <= '0';
            counter <= 0;
		 elsif rising_edge(clk_in) then
			  if (counter= 15) then
					counter <= 0;
					temporal <= NOT(temporal);
			  else 
					counter <= counter + 1;
			  end if;
		 end if;
	end process;
	
	clk_out <= temporal;
end Behavioral;
