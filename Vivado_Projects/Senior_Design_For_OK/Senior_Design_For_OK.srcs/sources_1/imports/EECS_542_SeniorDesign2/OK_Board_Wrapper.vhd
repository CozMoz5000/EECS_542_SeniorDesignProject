-- OK XEM7001 Board Wrapper
------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE work.FRONTPANEL.all;

ENTITY OK_BoardWrapper IS
    Port(HI_In : in STD_LOGIC_VECTOR(7 downto 0);
		 HI_Out : out STD_LOGIC_VECTOR(1 downto 0);
		 HI_InOut : inout STD_LOGIC_VECTOR(15 downto 0);
		 HI_AA : inout STD_LOGIC;
		 HI_MuxSel : out STD_LOGIC;
         SW : IN STD_LOGIC_VECTOR (15 downto 0);
         CLK : IN STD_LOGIC;
         LED : OUT STD_LOGIC_VECTOR (15 downto 0));
END OK_BoardWrapper;

ARCHITECTURE Structural OF OK_BoardWrapper IS
    --Signal Declarations
    Signal LED_Internal : STD_LOGIC_VECTOR(7 downto 0);
    Signal USB_Clock : STD_LOGIC;
    Signal ok1 : STD_LOGIC_VECTOR(30 downto 0);
	Signal ok2 : STD_LOGIC_VECTOR(16 downto 0);
	Signal ok2s : STD_LOGIC_VECTOR(17*5-1 downto 0);
	
	--User Signals
	Signal okPipeReadRequest : STD_LOGIC;
	Signal okPipe_DataForPC : STD_LOGIC_VECTOR(15 downto 0);
	Signal okWireIn_ControlSignals : STD_LOGIC_VECTOR(15 downto 0);
	Signal okWireOut_StatusSignals : STD_LOGIC_VECTOR(15 downto 0);
	Signal okTriggerIn_StartSignal : STD_LOGIC_VECTOR(15 downto 0);
	Signal LA_Test_Signals : STD_LOGIC_VECTOR(3 downto 0);
	Signal LA_Sampling_Clock_Select : STD_LOGIC_VECTOR(2 downto 0);
	Signal LA_StartSampling : STD_LOGIC;
	
	--Control Signals
	Signal LA_Reset : STD_LOGIC;   
	
	--Component Decalrations 
	Component logic_analyser is
        Generic (   
            n_of_inputs : integer := 4;
            b_width : integer := 16;
            fifo_mem_size : integer := 256);
    
        Port ( 
            rst : in std_logic;
            clk : in std_logic;
            read_en : in std_logic;
            data_in : in std_logic_vector(n_of_inputs-1 downto 0);
            data_out : out std_logic_vector(b_width*n_of_inputs-1 downto 0));
    End Component;
BEGIN
    --Required as per OK Firmware
    HI_MuxSel <= '0';
    
    --Map Wire In Control Signals to more Readable Names
    LA_Reset <= okWireIn_ControlSignals(0);
    LA_Sampling_Clock_Select <= okWireIn_ControlSignals(3 downto 1);
    LA_StartSampling <= okTriggerIn_StartSignal(0);
    
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
    okWO : okWireOR generic map (N=>5) port map (ok2=>ok2, ok2s=>ok2s);
    
    --OK HDL Modules Declarations
    --Pipe for data transfer back to PC (Address: 0xA5)
    okPipeToPC : okPipeOut port map (ok1 => ok1, ok2 => ok2, ep_addr => x"A5", ep_datain => okPipe_DataForPC, ep_read => okPipeReadRequest);
    
    --Wire In for Control Signals (Address: 0x05)
    --Bit 0: LA Reset Signal (Active High)
    --Bit 1-3: Clock Rate Select Signal (0: 100M, 1: 50M, 2: 25M, 3: 10M, 4: 5M, 6: 1M, 7: 500K)
    okControlSignalsFromPC : okWireIn port map (ok1 => ok1, ep_addr => x"05", ep_dataout => okWireIn_ControlSignals);
    
    --Trigger In to start the Sampling (Address: 0x55)
    --Bit 0: Start Sampling
    okTriggerForSampling : okTriggerIn port map (ok1 => ok1, ep_addr => x"55", ep_clk => CLK, ep_trigger => okTriggerIn_StartSignal);
    
    --Wire Out for Status Signals (Address: 0x25)
    --Bit 0: Sampling Completed
    --Bit 1-X: Number of Elements in FIFO
    okStatusSignalsToPC : okWireOut port map (ok1 => ok1, ok2 => ok2, ep_addr => x"25", ep_datain => okWireOut_StatusSignals);
    
    --Main Senior Design Module Initalization
    Logic_Analyzer : logic_analyser generic map (n_of_inputs => 4, b_width => 4, fifo_mem_size => 1024)
                                    port map (  rst => LA_Reset,
                                                clk => CLK,
                                                read_en => okPipeReadRequest,
                                                data_in => LA_Test_Signals,
                                                data_out => okPipe_DataForPC);
                                                
    --LA Test Unit Initalization
    
END Structural;
------------------------------------------------