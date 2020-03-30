library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Clothes_washer is
port(
	--inputs
		clk: in std_logic;	         --INVECE DEL CLOCK N BIT DI TIMER
		spin_dry: std_logic; 			--asciuga ON/OFF
		start_wash: std_logic; 			--START
		Door_open: in std_logic; 		--SENSORE PORTA
		reset: in std_logic;    		--RESET
		
	--outputs							
		door_lock: out std_logic;		-- BLOCCO PORTO
		water_pump: out std_logic;    -- POMPA ACQUA
		soap: out std_logic;				-- POMPA SAPONE
		rotate_drum: out std_logic;   -- MOTORE
		drain: out std_logic          -- DRENARE L'ACQUA
		--LED/CICALINO DI OUTPUT
);

end Clothes_washer;

architecture Behavioral of Clothes_washer is
TYPE state_type IS (zero,one,two,three,four,five,six,seven);--INSERIRE STATO 8 
SIGNAL state: state_type;


begin

next_state_logic: process(clk)
begin
if(clk'event and clk='1') then
case state is

when zero =>
if door_open = '1' then
 if start_wash = '0' then
  state <= zero;
  end if;
elsif door_open = '0'  then
if start_wash='1' then
state <= one;

end if;
end if;

when one =>
state <= two;

when two =>
state <= three;

when three =>
state <= four;

when four =>
state <= five;

when five =>
state <= six;

when six =>
if (spin_dry='0')then
state <= zero;

elsif (spin_dry='1') then
state <= seven;

end if;

when seven =>
state <= zero;


end case;
end if;
end process;

output_logic:process(reset,state,clk)
begin

if reset = '0' then
case state is

when zero =>
door_lock <='0';
water_pump<='0';
soap<='0';
rotate_drum<='0';
drain<='0';

when one =>
door_lock <='1';
water_pump<='1';
soap<='1';
rotate_drum<='0';
drain<='0';

when two =>
door_lock <='1';
water_pump<='0';
soap<='0';
rotate_drum<='1';
drain<='0';

when three =>
door_lock <='1';
water_pump<='0';
soap<='0';
rotate_drum<='0';
drain<='1';

when four =>
door_lock <='1';
water_pump<='1';
soap<='0';
rotate_drum<='0';
drain<='0';

when five =>
door_lock <='1';
water_pump<='0';
soap<='0';
rotate_drum<='1';
drain<='0';

when six =>

door_lock <='1';
water_pump<='0';
soap<='0';
rotate_drum<='0';
drain<='1';

when seven =>
door_lock <='1';
water_pump<='0';
soap<='0';
rotate_drum<='1';
drain<='1';

end case;
elsif reset='1' then
door_lock <='0';
water_pump<='0';
soap<='0';
rotate_drum<='0';
drain<='0';
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