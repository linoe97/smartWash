library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL; 
 --implmenta la differente durata degli stati della washing machine
entity count4 is
    Port ( clk: in std_logic;    -- clock input
           manual_reset: in std_logic; -- reset input 
			  auto_reset: in std_logic; -- reset from state change
           counter: out std_logic_vector(3 downto 0) -- output 4-bit counter
     );
end count4;

architecture Behavioral of count4 is
	signal counter_fast: std_logic_vector(3 downto 0);
	signal counter_slow: std_logic_vector(3 downto 0);

	begin
	-- up counter
	process(clk,manual_reset,auto_reset)
	begin
	--condizioni di reset
	if(rising_edge(clk)) then
			if auto_reset='1' or manual_reset='1' then
				counter_fast <= "0000";
				counter_slow <= "0000";
			else
				counter_fast <= counter_fast + 1;
				if counter_fast="1111" then
						counter_slow<=counter_slow+1; --counter slow viene incrementato solo counter fast raggiunge 1111
				end if;
			end if;
	end if;
	end process;
	 counter <= counter_slow;

end Behavioral;



