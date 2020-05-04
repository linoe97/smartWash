library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all; 


entity clothes_washer is
	port(
		--inputs
			timer: in std_logic_vector(3 downto 0);			-- dal timer 4bit
			clk: in std_logic;	         						-- INVECE DEL CLOCK N BIT DI TIMER
			spin_dry: in std_logic; 								-- asciuga ON/OFF
			start_wash: in std_logic; 								-- START
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
			state_LED: out std_logic;								-- LED/CICALINO DI OUTPUT (settare diversamente ad esempio fare on off quando è finito)
			counter_reset: out std_logic;						   -- resets the counter on state change
			bcd_out: out std_logic_vector(3 downto 0));     -- 7seg bcd controller

	
end clothes_washer;

architecture behavior of clothes_washer is

type state_type is (zero,one,one_reset,two,two_reset,three,three_reset,four,four_reset,five,five_reset,six,six_reset,seven,seven_reset,eigth);--INSERIRE STATO 8 
signal state_current, state_next: state_type;


begin



reset_auto: process(state_current)
begin
		if state_current=zero or state_current=eigth then
			counter_reset<='1';
		elsif state_current=one or state_current=two or state_current=three or state_current=four or state_current=five or state_current=six or state_current= seven then
			counter_reset<='0';
		else 
			counter_reset<='1';
		end if;
end process;



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
					when others => state_current <= state_next;

					end case;
					
				elsif (state_current=seven) then
					if timer = "1111" then 
							state_current<= state_next;						
					end if;
				
				elsif state_current=one or state_current=three or state_current=four or  state_current=six then
					if timer = "0011" then 
							state_current<= state_next;
						
					end if;
				else
					state_current<= state_next;
				end if;
					
		end if;
				
	end process; 


	--NEXT STATE LOGIC

next_state_logic: process(state_current, door_open, spin_dry, start_wash)
	begin
		
		case state_current is

		when zero =>
			if door_open = '1' then
				state_next <= zero;
			elsif door_open = '0'  then
				if start_wash='1' then
					state_next <= one;
				elsif start_wash = '0' then
					state_next <= zero;
				end if;
			end if;

		when one =>
			state_next <= one_reset;
			
		when one_reset =>
			state_next <= two;

		when two =>
			state_next <= two_reset;
			
		when two_reset =>
			state_next <= three;

		when three =>
			state_next <= three_reset;
			
		when three_reset =>
			state_next <= four;

		when four =>
			state_next <= four_reset;
			
		when four_reset =>
			state_next <= five;

		when five =>
			state_next <= five_reset;
			
		when five_reset =>
			state_next <= six;

		when six =>
			state_next <= six_reset;
		
		when six_reset =>
			if (spin_dry='0')then
				state_next <= eigth;
			elsif (spin_dry='1') then
				state_next <= seven;
			end if;

		when seven =>
			state_next <= seven_reset;
			
		when seven_reset=>
			state_next <= eigth;
		
		when eigth =>
			if 	door_open = '1' then
				state_next <= zero;
			elsif door_open = '0'  then
				state_next <= eigth;
			end if;
			
		when others =>
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
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="0000";
				

			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="11";
				state_LED<='1';
				bcd_out<="0001";


			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="10";
				state_LED<='1';
				bcd_out<="0010";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0011";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0100";

			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0101";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0110";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0111";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<=clk;
				bcd_out<="1000";
				
			when others =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="1111";

			end case;
			
			--eco mode
			
			when "01" => 
			case state_current is
			when zero =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="0000";

			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="11";
				state_LED<='1';
				bcd_out<="0001";

			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="10";
				state_LED<='1';
				bcd_out<="0010";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0011";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0100";

			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0101";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0110";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0111";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<=clk;
				bcd_out<="1000";
			
			when others =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="1111";

			end case;
			
			--full power mode
			
			when "10" => 
			case state_current is
			when zero =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="0000";
				
			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="11";
				state_LED<='1';
				bcd_out<="0001";

			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="10";
				state_LED<='1';
				bcd_out<="0010";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0011";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0100";

			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0101";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0110";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0111";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<=clk;
				bcd_out<="1000";
				
			when others =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="1111";

			end case;
			
			--wool mode
			
			when "11" => 			
			case state_current is
			when zero =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="0000";

			when one =>
				door_lock <='1';
				water_pump<='1';
				soap<='1';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0001";

			when two =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0010";

			when three =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0011";

			when four =>
				door_lock <='1';
				water_pump<='1';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0100";
				
			when five =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='0';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0101";

			when six =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0110";

			when seven =>
				door_lock <='1';
				water_pump<='0';
				soap<='0';
				rotate_drum<="11";
				drain<='1';
				temperature<="00";
				state_LED<='1';
				bcd_out<="0111";
				
			when eigth =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<=clk;
				bcd_out<="1000";
				
			when others =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				state_LED<='0';
				bcd_out<="1111";

			end case;
			
		when others =>
				door_lock <='0';
				water_pump<='0';
				soap<='0';
				rotate_drum<="00";
				drain<='0';
				temperature<="00";
				bcd_out<="1111";
				
		end case;
		
		elsif reset='1' then
			door_lock <='1';
			water_pump<='0';
			soap<='0';
			rotate_drum<="00";
			drain<='0';
			temperature<="00";
			bcd_out<="1111";
		end if;
	end process;

end behavior;


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