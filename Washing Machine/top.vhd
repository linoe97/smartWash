library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity top is
	generic(
			n : integer := 2; -- risoluzione di 2 bit
         clock_div : integer := 4  --frequency divider rate (per settare la frequenza di output)
   );
	port(
		--INPUT
			clk: in std_logic;	         						-- clk
			spin_dry: in std_logic; 								-- asciuga ON/OFF
			start_wash: in std_logic; 						      -- START
			Door_open: in std_logic; 								-- SENSORE PORTA
			reset: in std_logic;    								-- RESET (UNICO PER TUTTI E 3 I COMPONENTI)
			mode: in std_logic_vector(1 downto 0); 			-- 4 differenti modalità (normale, full power, eco e lana(wool) )
		--OUTPUT
			door_lock: out std_logic;								-- BLOCCO PORTA
			water_pump: out std_logic;    						-- POMPA ACQUA
			soap: out std_logic;										-- POMPA SAPONE
			temperature_PWM_OUT: out std_logic;					-- LIVELLO TEMPERATURA
			rotate_drum_PWM_OUT: out std_logic;  				-- VELOCITA' MOTORE
			drain: out std_logic;          						-- DRENAGGIO ACQUA
			state_LED: out std_logic;			               -- LED DI OUTPUT	
			sev_seg: out std_logic_vector(6 downto 0)
	);
end top;



architecture bh of top is
--vengono definiti i singoli componenti utilizzati

	component clothes_washer
		port(
		--inputs
			timer: in std_logic_vector(3 downto 0);			-- timer 4bit
			slow_clk: in std_logic;	         					-- clock dal clock divider
			fast_clk: in std_logic;									-- clock di sistema
			spin_dry: in std_logic; 									
			start_wash: in std_logic; 									
			Door_open: in std_logic; 								
			reset: in std_logic;    								
			mode: in std_logic_vector(1 downto 0); 						
		--outputs							
			door_lock: out std_logic;								
			water_pump: out std_logic;    						
			soap: out std_logic;										
			temperature: out std_logic_vector(1 downto 0);	
			rotate_drum: out std_logic_vector(1 downto 0);  
			drain: out std_logic;          						
			state_LED: out std_logic;								
			counter_reset: out std_logic;						   -- resetta il coounter quando vi è cambio di stato
			bcd_out: out std_logic_vector(3 downto 0)
		);
	end component;
	
	
	
	component frequency_divider is
    port ( clk_in							: in std_logic;					 -- clock input
           reset						: in std_logic;	     			    -- reset input 
           clk_out					: out std_logic		 			    -- output
     );
	end component;
	
	component count4 is
		port ( clk: in std_logic;    -- clock input
           manual_reset				: in std_logic; 									-- reset input 
			  auto_reset				: in std_logic; 									-- reset dal cambio di stato della FSM
           counter					: out std_logic_vector(3 downto 0) 			-- output 4-bit counter
		);
	end component;
	
	component pwm is
		generic (n 						: integer := 2; 				
               clock_div 			: integer := 4  					
      );
		port (clk, reset 				: in std_logic;
            duty 						: in std_logic_vector (n-1 downto 0);
            pwm_out 					: out std_logic
      );
	end component;
	   
	
	
	
	component bcd_7seg is
		port (BCD 					: in STD_LOGIC_VECTOR (3 downto 0);
				sev_seg 				: out STD_LOGIC_VECTOR (6 downto 0));
	end component;
	
	signal divided_clk			: std_logic;
	signal reset_counter			: std_logic;
	signal timerr 					: std_logic_vector(3 downto 0);
	signal drum_velocity_duty 	: std_logic_vector(1 downto 0);
	signal temp_duty 				: std_logic_vector(1 downto 0);
	signal BCD_sign				: std_logic_vector(3 downto 0);
	
	
begin 
	
	
	frequ_div: frequency_divider port map (clk, reset, divided_clk);
	cloth_wash: clothes_washer port map (timerr,divided_clk,clk,spin_dry,start_wash,Door_open,reset,mode,door_lock,water_pump,soap,temp_duty,drum_velocity_duty,drain,state_LED,reset_counter,BCD_sign);
	timer: count4 port map (clk,reset,reset_counter,timerr);
	pwm_drum: pwm
		generic map (n=>n,clock_div=>clock_div)
		port map (clk=>clk, reset=>reset, duty=>drum_velocity_duty, pwm_out=>rotate_drum_PWM_OUT);
	pwm_temp: pwm
		generic map (n=>n, clock_div=>clock_div)
		port map (clk=>clk, reset=>reset,duty=>temp_duty,pwm_out=>temperature_PWM_OUT);
	bcd_sev_seg: bcd_7seg port map (BCD_sign, sev_seg);
	
end bh;