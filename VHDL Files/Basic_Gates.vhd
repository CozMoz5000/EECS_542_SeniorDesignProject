-- Inverter
------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_unsigned.all;

ENTITY Inverter IS	
	PORT(A : IN STD_LOGIC;
         B : OUT STD_LOGIC);
END Inverter;
ARCHITECTURE Behavioral OF Inverter IS 
BEGIN
   B <= NOT A; 
END Behavioral;
------------------------------------------------

-- 2-Input AND Gate
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;

ENTITY ANDGate IS	
	PORT(A,B : IN STD_LOGIC;
         C : OUT STD_LOGIC);
END ANDGate;
ARCHITECTURE Behavioral OF ANDGate IS 
BEGIN
   C <= A AND B; 
END Behavioral;
------------------------------------------------

-- 2-Input OR Gate
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;

ENTITY ORGate IS	
	PORT(A,B : IN STD_LOGIC;
         C : OUT STD_LOGIC);
END ORGate;
ARCHITECTURE Behavioral OF ORGate IS 
BEGIN
   C <= A OR B; 
END Behavioral;
------------------------------------------------

-- 2-Input NOR Gate
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NORGate is	
   port( A, B : in std_logic;
            C : out std_logic);
end NORGate;
architecture Behavioral of NORGate is 
begin
   C <= (NOT (A OR B)); 
end Behavioral;
------------------------------------------------

-- 2 Input XOR Gate
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;

ENTITY XORGate IS	
	PORT(A,B : IN STD_LOGIC;
         C : OUT STD_LOGIC);
END XORGate;
ARCHITECTURE Behavioral OF XORGate IS 
BEGIN
   C <= A XOR B; 
END Behavioral;
------------------------------------------------