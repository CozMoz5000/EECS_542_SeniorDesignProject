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
    
    Component UpCounter_4bit_AsyncReset is
        Port(Clock : IN  STD_LOGIC;
             Reset : IN STD_LOGIC;
             Q : OUT STD_LOGIC_VECTOR(3 downto 0));
    end Component;
    
    Component logic_analyser is
        generic(   
            n_of_inputs                 : integer := 2;    --Number of inputs we are sampling
            b_width                     : integer := 4;    --Number of samples per input that the buffer can store. 
                                                           --This number times n_of_inputs is the total data that a FIFO row will contain.
            fifo_mem_size               : integer := 8     --Depth of the FIFO
        );
    
        Port ( 
            rst                         : in std_logic;     --an asynchronous master reset signal ... clears all data in the entire circuit
            clk                         : in std_logic;     --The FPGA sampling clock (determined by the control unit)
            usb_clk                     : in std_logic;     --The USB clock -- independent 
            read_en                     : in std_logic;     --The read enable signal supplied by the USB. The USB reads from a FIFO row when this is high and we are on the rising edge of the usb clock
            data_in                     : in std_logic_vector(n_of_inputs-1 downto 0);  --a vector of data coming from external circuits - (1 bit per circuit-node)
            data_out                    : out std_logic_vector(b_width*n_of_inputs-1 downto 0); --the vector contained in a FIFO row, given to the USB at every read. 
                                                                                                --The format is: [ckt1_sample1, ckt1_sample2, ... ckt1_sampleN , ckt2_sample1, ... ckt2_sampleN, ...]
            fifo_remaining_data         : out integer range 0 to fifo_mem_size          --keeps track of the the total number of data remaining in the FIFO (to be read). Updated everytime a read/write to the FIFO happens
        );
    end Component;
    
	--Internal Test Signal Declarations
	Constant Clock_Period : time := 10ns;
	Constant USB_Clock_Period : time := 20.8ns;
    Signal Stimulus_Clock : STD_LOGIC;
    Signal USB_Clock : STD_LOGIC;
    Signal Global_Reset, Start_Sample, Local_Reset, Sampiling_Clock : STD_LOGIC := '0';
    Signal Clock_Select : STD_LOGIC_VECTOR(2 downto 0);
    Signal LA_Read_Enable : STD_LOGIC;
    Signal LA_Data_Out : STD_LOGIC_VECTOR(15 downto 0);
    Signal LA_Test_Signals : STD_LOGIC_VECTOR(3 downto 0);
    
    --Global Parameters
    Constant FIFO_DATA_DEPTH : INTEGER := 35;
    Constant NUM_BITS_TO_REPRESENT_FIFO_DEPTH : INTEGER := 10;
    
    --Signal Declarations
    Signal fifoNumOfElements : INTEGER range 0 to FIFO_DATA_DEPTH;
BEGIN
	--Unit Under Test Module Declaration
    UUT : EECS_542_Control_Unit PORT MAP (FPGA_CLK_100MHz => Stimulus_Clock,
                                          GLOBAL_RESET => Global_Reset,
                                          START_SAMPILING_TRIGGER => Start_Sample,
                                          CLK_SEL => Clock_Select,
                                          LOCAL_RESET => Local_Reset,
                                          SAMPILING_CLK_OUT => Sampiling_Clock);
    
    UUT1 : logic_analyser GENERIC MAP (n_of_inputs => 4, b_width => 4, fifo_mem_size => FIFO_DATA_DEPTH)
                          PORT MAP (rst => Local_Reset,
                                    clk => Sampiling_Clock,
                                    usb_clk => USB_Clock,
                                    read_en => LA_Read_Enable,
                                    data_in => LA_Test_Signals,
                                    data_out => LA_Data_Out,
                                    fifo_remaining_data => fifoNumOfElements);
    
	--Stimulus Clock Generation Process
	Stimulus_Clock_Process : PROCESS
	BEGIN
		Stimulus_Clock <= '1';
		wait for Clock_Period/2;
		Stimulus_Clock <= '0';
		wait for Clock_Period/2;
	END PROCESS;
    
    USB_Clock_Process : PROCESS
    BEGIN
        USB_Clock <= '1';
        wait for USB_Clock_Period/2;
        USB_Clock <= '0';
        wait for USB_Clock_Period/2;
    END PROCESS;
    
    --Test Unit Init
    Test_Unit : UpCounter_4bit_AsyncReset port map (Clock => Sampiling_Clock, Reset => Local_Reset, Q => LA_Test_Signals);
    
	--Test Stimulus Process
    Stimulus_Process : PROCESS
    BEGIN
        --Initial Conditions
        Global_Reset <= '1';
        Clock_Select <= "001";
        Start_Sample <= '0';
        LA_Read_Enable <= '0';
        
        wait for 10 ns;
        --Undo Resets
        Global_Reset <= '0';
        wait for 22 ns;
        --Start Sampiling
        Start_Sample <= '1';
        wait for 10ns;
        Start_Sample <= '0';
        
        wait for 840.8ns;
        LA_Read_Enable <= '1';
        
        wait for USB_Clock_Period*10;
        LA_Read_Enable <= '0';
        
        Wait;
    END PROCESS;
END;