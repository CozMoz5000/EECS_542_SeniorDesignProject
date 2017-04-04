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
BEGIN
    --Required as per OK Firmware
    HI_MuxSel <= '0';
    
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
    
END Structural;
------------------------------------------------