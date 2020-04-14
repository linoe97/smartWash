library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; 


entity Clothes_washer is
	port(
		--inputs
			timer: in std_logic_vector(3 downto 0);			-- dal timer 4bit
			clk: in std_logic;	         						-- INVECE DEL CLOCK N BIT DI TIMER
			spin_dry: std_logic; 									-- asciuga ON/OFF
			start_wash: std_logic; 									-- START
			Door_open: in std_logic; 								-- SENSORE PORTA
			reset: in std_logic;    								-- RESET
			mode: in std_logic_vector(1 downto 0); 			-- 3 o 4 differenti modalità (normale, full power, eco e lana(wool) )
			
			--inserire un input di timer (durata di ogni stato) anzichè il clock
			--e fare in modo che per ogni modalità ci sia una differente durata
			--when 0010
			--when 0111
			--when 1111

		--outputs							
			door_lock: out std_logic;								-- BLOCCO PORTO
			water_pump: out std_logic;    						-- POMPA ACQUA
			soap: out std_logic;										-- POMPA SAPONE
			temperature: out std_logic_vector(1 downto 0);	-- livelo temperatura
			rotate_drum: out std_logic_vector(1 downto 0);  -- velocità MOTORE
			drain: out std_logic;          						-- DRENARE L'ACQUA
			state_LED: out std_logic);								-- LED/CICALINO DI OUTPUT (settare diversamente ad esempio fare on off quando è finito)

	
end Clothes_washer;

architecture Behavioral of Clothes_washer is
type state_type is (zero,one,two,three,four,five,six,seven,eigth);--INSERIRE STATO 8 
signal state_current, state_next: state_type;


begin


State_register : process(clk)
	begin
		if rising_edge(clk) then 
			if state_current=zero or state_current=eigth then
					state_current<= state_next;
					
			elsif (state_current=two or state_current= five) then
				case mode is 
					
				--implementazione delle varie durate
				-- normale				
				when "00" => 
					if (timer = "0111")then 
						state_current<= state_next;
					end if;
				--eco
				when "01" => 
					if (timer = "0011")then 
						state_current<= state_next;
					end if;
				--fullpower
				when "10" => 
					if (timer = "1111")then 
						state_current<= state_next;
					end if;
				--wool
				when "11" => 
					if (timer = "0111")then 
						state_current<= state_next;
					end if;
					
				end case;
				
			elsif (state_current=seven) then
				if timer = "1111" then 
						state_current<= state_next;
				end if;
			
			else 
				if timer = "0011" then 
						state_current<= state_next;
				end if;
			end if;
		end if;
				
	end process; 


	--NEXT STATE LOGIC

next_state_logic: process(state_current, door_open, spin_dry, start_wash)
	begin
		case state_current is

		when zero =>
			if door_open = '1' then
				if start_wash = '0' then
					state_next <= zero;
				end if;
			elsif door_open = '0'  then
				if start_wash='1' then
					state_next <= one;
				end if;
			end if;

		when one =>
			state_next <= two;

		when two =>
			state_next <= three;

		when three =>
			state_next <= four;

		when four =>
			state_next <= five;

		when five =>
			state_next <= six;

		when six =>
			if (spin_dry='0')then
				state_next <= eigth;
			elsif (spin_dry='1') then
				state_next <= seven;
			end if;

		when seven =>
			state_next <= eigth;
		
		when eigth =>
			state_next <= zero;
	
		end case;

	end process;

	--OUTPUT LOGIC
output_logic:process(reset,state_current,clk,mode)
	begin

		if reset = '0' then
			
			case mode is 
			
			--normal mode
			
			when "00" => 
			case state_current is
			when zero =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="11";

			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="10";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			end case;
			
			--eco mode
			
			when "01" => 
			case state_current is
			when zero =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="11";

			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="10";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			end case;
			
			--full power mode
			
			when "10" => 
			case state_current is
			when zero =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="11";

			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="10";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			end case;
			
			--wool mode
			
			when "11" => 			
			case state_current is
			when zero =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				
			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";

			end case;
			
		
		end case;
		
		elsif reset='1' then
			door_lock <='0';
			water_pump<='0';
			soap<='0';
			rotate_drum<="00";
			drain<='0';
			temperature<="00";
		end if;
	end process;

end Behavioral;

--SEQUENCE WHEN NOT spin dry
--                                 decimal equivalent
--            0 0 1 X  0 0 0 0 0   =>0
--            0 0 0 0  0 0 0 0 0   =>0
--            0 1 0 1  0 0 0 0 0 =>0
--Wash fill   1 2 X X  1 1 1 0 0 =>28
--Wash spin   2 3 X X  1 0 0 1 0 =>18
--Drain       3 4 X X  1 0 0 0 1 =>17
--Rinse fill  4 5 X X  1 1 0 0 0 =>24
--Rinse spin  5 6 X X  1 0 0 1 0 =>18
--not Drain   6 0 X 0  1 0 0 0 1 =>17
--            0 0 0 0  0 0 0 0 0   =>0

--SEQUENCE WHEN spin dry
--            0 0 1 X  0 0 0 0 0   =>0
--            0 0 0 0  0 0 0 0 0   =>0
--            0 1 0 1  0 0 0 0 0 =>0
--Wash fill   1 2 X X  1 1 1 0 0 =>28
--Wash spin   2 3 X X  1 0 0 1 0 =>18
--Drain       3 4 X X  1 0 0 0 1 =>17
--Rinse fill  4 5 X X  1 1 0 0 0 =>24
--Rinse spin  5 6 X X  1 0 0 1 0 =>18
--Drain       6 7 X 1  1 0 0 0 1 =>17
--Spin dry    7 0 X X 1 0 0 1 1 =>19
--            0 0 0 0  0 0 0 0 0   =>0