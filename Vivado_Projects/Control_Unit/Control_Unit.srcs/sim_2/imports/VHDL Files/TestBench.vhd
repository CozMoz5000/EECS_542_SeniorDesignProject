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
	Constant Clock_Period : time := 10ns;
    signal Stimulus_Clock : STD_LOGIC;
    Signal Clock_Select : STD_LOGIC_VECTOR(2 downto 0);
    Signal G_Reset, L_Reset : STD_LOGIC;
    Signal CLK_For_LA, Start_Sample : STD_LOGIC;
BEGIN
	--Unit Under Test Module Declaration
    UUT : EECS_542_Control_Unit PORT MAP (
	   FPGA_CLK_100MHz => Stimulus_Clock,
	   GLOBAL_RESET => G_Reset,
	   START_SAMPILING_TRIGGER => Start_Sample,
	   CLK_SEL => Clock_Select,
	   LOCAL_RESET => L_Reset,
	   SAMPILING_CLK_OUT => CLK_For_LA);
    
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
        G_Reset <= '1';
        Clock_Select <= "001";
        Start_Sample <= '0';
        wait for 100 ns;
        
        G_Reset <= '0';
        wait for 20ns;
        Start_Sample <= '1';
        wait for 10ns;
        Start_Sample <= '0';
        
        Wait;
    END PROCESS;
END;