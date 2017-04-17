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
    Component EECS_542_Clock_Block IS
        PORT(CLK_IN : IN STD_LOGIC;
             RESET : IN STD_LOGIC;
             MUX_SEL : IN STD_LOGIC_VECTOR(2 downto 0);
             CLK_OUT : OUT STD_LOGIC);
    END Component;
    
	--Internal Test Signal Declarations
	Constant Clock_Period : time := 5ns;
    signal Stimulus_Clock : STD_LOGIC;
    Signal Rst : STD_LOGIC;
    Signal CLK_SEL : STD_LOGIC_VECTOR(2 downto 0);
    Signal CLK_BLOCK_OUTPUT : STD_LOGIC;
BEGIN
	--Unit Under Test Module Declaration
    UUT : EECS_542_Clock_Block PORT MAP (
	   CLK_IN => Stimulus_Clock,
	   RESET => Rst,
	   MUX_SEL => CLK_SEL,
	   CLK_OUT => CLK_BLOCK_OUTPUT);
    
	--Stimulus Clock Generation Process
	Stimulus_Clock_Process : PROCESS
	BEGIN
		Stimulus_Clock <= '1';
		wait for Clock_Period;
		Stimulus_Clock <= '0';
		wait for Clock_Period;
	END PROCESS;
		
	--Test Stimulus Process
    Stimulus_Process : PROCESS
    BEGIN
        Rst <= '1';
        CLK_SEL <= "001";
        wait for 100 ns;
        Rst <= '0';
        Wait;
    END PROCESS;
END;