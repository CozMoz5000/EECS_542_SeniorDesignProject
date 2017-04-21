-- OK XEM7001 Board Wrapper
------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.FRONTPANEL.all;
use IEEE.numeric_std.all;

ENTITY OK_BoardWrapper IS
    Port(HI_In : in STD_LOGIC_VECTOR(7 downto 0);
		 HI_Out : out STD_LOGIC_VECTOR(1 downto 0);
		 HI_InOut : inout STD_LOGIC_VECTOR(15 downto 0);
		 HI_AA : inout STD_LOGIC;
		 HI_MuxSel : out STD_LOGIC;
         SW : IN STD_LOGIC_VECTOR (15 downto 0);
         CLK : IN STD_LOGIC;
         LED : OUT STD_LOGIC_VECTOR (7 downto 0));
END OK_BoardWrapper;

ARCHITECTURE Structural OF OK_BoardWrapper IS
    --Global Parameters
    Constant FIFO_DATA_DEPTH : INTEGER := 1200;
    Constant NUM_BITS_TO_REPRESENT_FIFO_DEPTH : INTEGER := 10;
    
    --Signal Declarations
    Signal LED_Internal : STD_LOGIC_VECTOR(7 downto 0);
    Signal USB_Clock : STD_LOGIC;
    Signal ok1 : STD_LOGIC_VECTOR(30 downto 0);
	Signal ok2 : STD_LOGIC_VECTOR(16 downto 0);
	Signal ok2s : STD_LOGIC_VECTOR(17*3-1 downto 0);
	Signal fifoNumOfElements : INTEGER range 0 to FIFO_DATA_DEPTH;
	
	--User Signals
	Signal okPipeReadRequest : STD_LOGIC;
	Signal okPipe_DataForPC : STD_LOGIC_VECTOR(15 downto 0);
	Signal okWireIn_ControlSignals : STD_LOGIC_VECTOR(15 downto 0);
	Signal okWireOut_StatusSignals : STD_LOGIC_VECTOR(15 downto 0);
	Signal okTriggerIn_StartSignal : STD_LOGIC_VECTOR(15 downto 0);
	Signal okTriggerOut_CompletedSignal : STD_LOGIC_VECTOR(15 downto 0);
	Signal LA_Test_Signals : STD_LOGIC_VECTOR(3 downto 0);
	Signal LA_Sampling_Clock_Select : STD_LOGIC_VECTOR(2 downto 0);
	Signal LA_StartSampling : STD_LOGIC;
	Signal LA_DoneSampling : STD_LOGIC;
	Signal fifoDataCount : STD_LOGIC_VECTOR(NUM_BITS_TO_REPRESENT_FIFO_DEPTH-1 downto 0);
	Signal LA_SampilingCompleted : STD_LOGIC;
	
	--Control Signals
	Signal LA_Reset : STD_LOGIC;   
	Signal LA_Sampiling_Clock : STD_LOGIC;
	Signal LA_CU_Reset : STD_LOGIC;
	
	--Componet Declarations
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
    end component;
    
    Component EECS_542_Control_Unit IS
      PORT(FPGA_CLK_100MHz : IN STD_LOGIC;
           GLOBAL_RESET : IN STD_LOGIC;
           START_SAMPILING_TRIGGER : IN STD_LOGIC;
           CLK_SEL : IN STD_LOGIC_VECTOR(2 downto 0);
           LOCAL_RESET : OUT STD_LOGIC;
           SAMPILING_COMPLETED : OUT STD_LOGIC;
           SAMPILING_CLK_OUT : OUT STD_LOGIC);
    END Component;
    
    Component UpCounter_4bit_AsyncReset is
        Port(Clock : IN  STD_LOGIC;
             Reset : IN STD_LOGIC;
             Q : OUT STD_LOGIC_VECTOR(3 downto 0));
    END Component;
BEGIN
    --Required as per OK Firmware
    HI_MuxSel <= '0';
    
    --Map Wire In Control Signals to more Readable Names
    LA_Reset <= okWireIn_ControlSignals(0);
    LA_Sampling_Clock_Select <= okWireIn_ControlSignals(3 downto 1);
    LA_StartSampling <= okTriggerIn_StartSignal(0);
    
    --Map the integer of remaining FIFO elements to a STD_LOGIC_VECTOR
    fifoDataCount <= std_logic_vector(to_unsigned(fifoNumOfElements, fifoDataCount'length));
    
    --Map the output signals of the LA to the Wire Out bits
    okWireOut_StatusSignals(9 downto 0) <= fifoDataCount;
    
    --Map the sampling completed signal from the control unit to the Trigger Out
    okTriggerOut_CompletedSignal(0) <= LA_DoneSampling;
    
    --Map a internal signal to the actual LED's on the board
    LED(7) <= '0' when (LED_Internal(7) = '1') else 'Z';
    LED(6) <= '0' when (LED_Internal(6) = '1') else 'Z';
    LED(5) <= '0' when (LED_Internal(5) = '1') else 'Z';
    LED(4) <= '0' when (LED_Internal(4) = '1') else 'Z';
    LED(3) <= '0' when (LED_Internal(3) = '1') else 'Z';
    LED(2) <= '0' when (LED_Internal(2) = '1') else 'Z';
    LED(1) <= '0' when (LED_Internal(1) = '1') else 'Z';
    LED(0) <= '0' when (LED_Internal(0) = '1') else 'Z';
    
    --Initalize the OK Host Module and OR Module
    okHI : okHost port map (hi_in=>HI_In, hi_out=>HI_Out, hi_inout=>HI_InOut, hi_aa=>HI_AA, ti_clk=>USB_Clock, ok1=>ok1, ok2=>ok2);
    okWO : okWireOR generic map (N=>3) port map (ok2=>ok2, ok2s=>ok2s);
    
    --OK HDL Modules Declarations
    --Pipe for data transfer back to PC (Address: 0xA5)
    okPipeToPC : okPipeOut port map (ok1 => ok1, ok2 => ok2s(3*17-1 downto 2*17 ), ep_addr => x"A5", ep_datain => okPipe_DataForPC, ep_read => okPipeReadRequest);
    
    --Wire In for Control Signals (Address: 0x05)
    --Bit 0: LA Reset Signal (Active High)
    --Bit 1-3: Clock Rate Select Signal (0: 100M, 1: 50M, 2: 25M, 3: 10M, 4: 5M, 6: 1M, 7: 500K)
    okControlSignalsFromPC : okWireIn port map (ok1 => ok1, ep_addr => x"05", ep_dataout => okWireIn_ControlSignals);
    
    --Trigger In to start the Sampling (Address: 0x55)
    --Bit 0: Start Sampling
    okTriggerInForSampling : okTriggerIn port map (ok1 => ok1, ep_addr => x"55", ep_clk => CLK, ep_trigger => okTriggerIn_StartSignal);
    
    --Trigger Out to flag we are done with the Sampling (Address: 0x6A)
    --Bit 0: Completed Sampling
    okTriggerOutForSampling : okTriggerOut port map (ok1 => ok1, ok2 => ok2s( 2*17-1 downto 1*17 ), ep_addr => x"6A", ep_clk => CLK, ep_trigger => okTriggerOut_CompletedSignal);
    
    --Wire Out for Status Signals (Address: 0x25)
    --Bit 0: Sampling Completed
    --Bit 1-10: Number of Elements in FIFO
    okStatusSignalsToPC : okWireOut port map (ok1 => ok1, ok2 => ok2s( 1*17-1 downto 0*17 ), ep_addr => x"25", ep_datain => okWireOut_StatusSignals);
    
    --Main Senior Design Module Initalization
    Logic_Analyzer : logic_analyser generic map (n_of_inputs => 4, b_width => 4, fifo_mem_size => FIFO_DATA_DEPTH)
                                    port map (  rst => LA_CU_Reset,
                                                clk => LA_Sampiling_Clock,
                                                usb_clk => USB_Clock,
                                                read_en => okPipeReadRequest,
                                                data_in => LA_Test_Signals,
                                                data_out => okPipe_DataForPC,
                                                fifo_remaining_data => fifoNumOfElements);
                                                
    --LA Test Unit Initalization
    Test_Unit : UpCounter_4bit_AsyncReset port map (Clock => LA_Sampiling_Clock, Reset => LA_CU_Reset, Q => LA_Test_Signals);
    
    --Control Module Unit Initalization
    Control_Unit : EECS_542_Control_Unit port map(FPGA_CLK_100MHz => CLK,
                                                  GLOBAL_RESET => LA_Reset,
                                                  START_SAMPILING_TRIGGER => LA_StartSampling,
                                                  CLK_SEL => LA_Sampling_Clock_Select,
                                                  LOCAL_RESET => LA_CU_Reset,
                                                  SAMPILING_COMPLETED => LA_DoneSampling,
                                                  SAMPILING_CLK_OUT => LA_Sampiling_Clock);
                                                  
    --LED Mappings
    LED_Internal <= fifoDataCount(9 downto 2);
END Structural;
------------------------------------------------