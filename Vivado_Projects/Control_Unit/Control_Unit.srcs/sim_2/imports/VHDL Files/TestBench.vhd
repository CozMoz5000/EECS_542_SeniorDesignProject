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
    Component EECS_542_Control_Unit IS
        PORT(FPGA_CLK_100MHz : IN STD_LOGIC;
             GLOBAL_RESET : IN STD_LOGIC;
             START_SAMPILING_TRIGGER : IN STD_LOGIC;
             CLK_SEL : IN STD_LOGIC_VECTOR(2 downto 0);
             LOCAL_RESET : OUT STD_LOGIC;
             SAMPILING_CLK_OUT : OUT STD_LOGIC);
    END Component;
    
	--Internal Test Signal Declarations
	Constant Clock_Period : time := 50ms;
    signal Stimulus_Clock : STD_LOGIC;
BEGIN
	--Unit Under Test Module Declaration
    UUT : EECS_542_Control_Unit PORT MAP (
	   FPGA_CLK_100MHz => ,
	   GLOBAL_RESET => ,
	   START_SAMPILING_TRIGGER => ,
	   CLK_SEL => ,
	   LOCAL_RESET => ,
	   SAMPILING_CLK_OUT => );
    
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