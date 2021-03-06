library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pwm is
    generic (   n : integer := 2; 			--2 bit resolution
                clock_div : integer := 1  --frequency divider rate (to set output frequency) //è il massimo di counter_clk_div
                );
    port (  clk, reset : in std_logic;
            duty : in std_logic_vector (n-1 downto 0);
            pwm_out : out std_logic
            );
end pwm;

architecture behavioral of pwm is
    signal counter : integer range 0 to 2**n-1;
    signal counter_clk_div : integer range 0 to clock_div;
    signal clk_div : std_logic ;

begin

   --frequency divider   (needed if frequency is too fast)
	proc_clk_div : process (clk) begin
		 if rising_edge(clk) then
			  clk_div <= '0';
			  if reset = '1' then
					counter_clk_div <= 0;
			  elsif counter_clk_div = clock_div then
					counter_clk_div <= 0;
					clk_div <= '1';
			  else counter_clk_div <= counter_clk_div + 1;
			  end if;
		 end if;
	end process;

	--PWM counter
	proc_counter : process (clk_div) is begin
		 if rising_edge(clk_div) then
			  if reset = '1' then
					counter <= 0;
			  elsif counter = 2**n-2 then
					counter <= 0;
			  else
					counter <= counter + 1;
			  end if;
		 end if;
	end process;

pwm_out <= '1' when counter < to_integer(unsigned(duty)) else '0'; 

--       duty: 10

--output: 00 -> 1
--			 01 -> 1
--        10 -> 0
--			 11 -> 0

end behavioral;
