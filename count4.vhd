library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL; 
 
entity count4 is
    Port ( clk: in std_logic; -- clock input
           manual_reset: in std_logic; -- reset input 
			  auto_reset: in std_logic; -- reset from state change
           counter: out std_logic_vector(3 downto 0) -- output 4-bit counter
     );
end count4;

architecture Behavioral of count4 is
	signal counter_up: std_logic_vector(3 downto 0);
	begin
	-- up counter
	process(clk,manual_reset,auto_reset)
	begin
	if(rising_edge(clk)) then
		 --if (auto_reset'event and (auto_reset = '1' or auto_reset = '0')) then
		 if 	 auto_reset='1'  then
				counter_up <= "0000";
		 elsif  manual_reset='1' then
				counter_up <= "0000";
		 else
			  counter_up <= counter_up + 1;
		 end if;
	 end if;
	end process;
	 counter <= counter_up;

end Behavioral;



