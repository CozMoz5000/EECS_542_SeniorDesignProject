--Library Inclusions
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;

--Test Bech Entitiy Declaration
ENTITY test_tb IS 
END test_tb;

--Begin Test Arch
ARCHITECTURE behavior OF test_tb IS
   -- Component Declaration for the Unit Under Test (UUT) Module
    COMPONENT XXXXXXXXXXXXXXXXXXX
    Port (XXXXXXXXXXXXXXXXXXX);
    END COMPONENT;
    
	--Internal Test Signal Declarations
	Constant Clock_Period : time := 50ms;
    signal Stimulus_Clock : STD_LOGIC;
BEGIN
	--Unit Under Test Module Declaration
    UUT : XXXXXXXXXXXXXXXXXXX PORT MAP (
	
	);
    
	--Stimulus Clock Generation Process
	Stimulus_Clock_Process : PROCESS
	BEGIN
		Stimulus_Clock <= '0';
		wait for Clock_Period;
		Stimulus_Clock <= '1';
		wait for Clock_Period;
	END PROCESS;
		
	--Test Stimulus Process
    Stimulus_Process : PROCESS
    BEGIN
        wait for XXXX ms;
        Wait;
    END PROCESS;
END;