library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;  
entity count4 is
    Port ( clk: in std_logic; -- clock input
           reset: in std_logic; -- reset input 
           counter: out std_logic_vector(3 downto 0) -- output 4-bit counter
     );
end count4;

architecture Behavioral of count4 is
signal counter_up: std_logic_vector(3 downto 0);
begin
-- up counter
process(clk,reset)
begin
if(rising_edge(clk)) then
    if(reset='1') then
         counter_up <= x"0";
    else
        counter_up <= counter_up + x"1";
    end if;
 end if;
end process;
 counter <= counter_up;

end Behavioral;



