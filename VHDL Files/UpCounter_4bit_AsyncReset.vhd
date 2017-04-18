-- 4bit Up Counter with Asynchronous Reset
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity UpCounter_4bit_AsyncReset is
    Port(Clock : IN  STD_LOGIC;
         Reset : IN STD_LOGIC;
         Q : OUT STD_LOGIC_VECTOR(3 downto 0));
end UpCounter_4bit_AsyncReset;

architecture Behavioral of UpCounter_4bit_AsyncReset is
	Signal Count : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
    upcount : PROCESS(Clock)
	BEGIN
		IF rising_edge(Clock) THEN
		  IF Reset = '1' THEN
		      Count <= "0000";
		  ELSE
			Count <= Count + '1';
	      END IF;
		END IF;
	END PROCESS upcount;
	Q <= Count;
end Behavioral;
------------------------------------------------