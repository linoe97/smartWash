library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all; 


entity clothes_washer is
	port(
		--inputs
			timer: in std_logic_vector(3 downto 0);			-- in ingresso dal timer 4bit
			slow_clk: in std_logic;	         					-- clock in uscita dal divisore di frequenza
			fast_clk: in std_logic;									-- clock di sistema
			spin_dry: in std_logic; 								-- ASCIUGATURA ON/OFF
			start_wash: in std_logic; 								-- START
			Door_open: in std_logic; 								-- SENSORE PORTA
			reset: in std_logic;    								-- RESET
			mode: in std_logic_vector(1 downto 0); 			-- 4 differenti modalità (normale, full power, eco e lana(wool) )
			

		--outputs							
			door_lock: out std_logic;								-- BLOCCO PORTA
			water_pump: out std_logic;    						-- POMPA ACQUA
			soap: out std_logic;										-- POMPA SAPONE
			temperature: out std_logic_vector(1 downto 0);	-- LIVELLO DI TEMPERATURA
			rotate_drum: out std_logic_vector(1 downto 0);  -- VELOCITA' MOTORE
			drain: out std_logic;          						-- DRENAGGIO ACQUA
			state_LED: out std_logic;								-- LED DI OUTPUT
			counter_reset: out std_logic;						   -- RESET DEL COUNTER OGNI CAMBIO DI STATO
			bcd_out: out std_logic_vector(3 downto 0));     -- CONTROLLER BCD-7SEG

	
end clothes_washer;

architecture behavior of clothes_washer is

type state_type is (zero,one,one_reset,two,two_reset,three,three_reset,four,four_reset,five,five_reset,six,six_reset,seven,seven_reset,eigth);--INSERIRE STATO 8 
signal state_current, state_next: state_type;


begin

--processo di RESET della FSM
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

--STATE REGISTER per il salvataggio dello stato corrente della FSM
State_register : process(fast_clk)
	begin
		
		if rising_edge(fast_clk) then 
		
				if state_current=zero or state_current=eigth then
						state_current<= state_next;
						
				elsif (state_current=two or state_current= five) then
				
					case mode is 
						
					--implementazione delle varie durate degli stati a seconda della modalità
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


	--NEXT STATE LOGIC, descrive la sequenza logica della FSM

next_state_logic: process(state_current, door_open, spin_dry, start_wash, reset)
	begin
		
			case state_current is

			when zero =>
				if reset='1' then
					state_next <= zero;
				else
					if door_open = '1' then
						state_next <= zero;
					elsif door_open = '0'  then
						if start_wash='1' then
							state_next <= one;
						elsif start_wash = '0' then
							state_next <= zero;
						end if;
					end if;
				end if;

			when one =>
			 if reset='1' then
				state_next <= zero;
			 else
				state_next <= one_reset;
			 end if;
				
			when one_reset =>
				state_next <= two;

			when two =>
			 if reset='1' then
				state_next <= zero;
			 else
				state_next <= two_reset;
			 end if;
				
			when two_reset =>
				state_next <= three;

			when three =>
			 if reset='1' then
				state_next <= zero;
			 else
				state_next <= three_reset;
			end if;
				
			when three_reset =>
				state_next <= four;

			when four =>
			 if reset='1' then
				state_next <= zero;
			 else
				state_next <= four_reset;
			end if;
				
			when four_reset =>
				state_next <= five;

			when five =>
			 if reset='1' then
				state_next <= zero;
			 else
				state_next <= five_reset;
			 end if;
				
			when five_reset =>
				state_next <= six;

			when six =>
			 if reset='1' then
				state_next <= zero;
			 else
				state_next <= six_reset;
			 end if;
			
			when six_reset =>
				if (spin_dry='0')then
					state_next <= eigth;
				elsif (spin_dry='1') then
					state_next <= seven;
				end if;

			when seven =>
			 if reset='1' then
				state_next <= zero;
			 else
				state_next <= seven_reset;
			 end if;
				
			when seven_reset=>
				state_next <= eigth;
			
			when eigth =>
			 if reset='1' then
				state_next <= zero;
			 else
				if 	door_open = '1' then
					state_next <= zero;
				elsif door_open = '0'  then
					state_next <= eigth;
				end if;
			 end if;
				
			when others =>
				state_next <= zero;
		
			end case;

	end process;

	--OUTPUT LOGIC
output_logic:process(reset,state_current,mode)
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
				state_LED<=fast_clk;
				bcd_out<="1000";
								
			when others =>
				door_lock <='1';
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
				state_LED<=fast_clk;
				bcd_out<="1000";
						
			when others =>
				door_lock <='1';
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
				state_LED<=fast_clk;
				bcd_out<="1000";
								
			when others =>
				door_lock <='1';
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
				state_LED<=fast_clk;
				bcd_out<="1000";
				
			when others =>
				door_lock <='1';
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
			door_lock <='0';
			water_pump<='0';
			soap<='0';
			rotate_drum<="00";
			drain<='0';
			temperature<="00";
			bcd_out<="1111";
		end if;
	end process;

end behavior;
