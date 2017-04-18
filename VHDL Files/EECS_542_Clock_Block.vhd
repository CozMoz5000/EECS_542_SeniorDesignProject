--EECS 542 Clock Block
------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EECS_542_Clock_Block IS
  PORT(CLK_IN : IN STD_LOGIC;
       RESET : IN STD_LOGIC;
       MUX_SEL : IN STD_LOGIC_VECTOR(2 downto 0);
       CLK_OUT : OUT STD_LOGIC);
END ENTITY EECS_542_Clock_Block;

ARCHITECTURE Struct OF EECS_542_Clock_Block IS
    --User Signals
    Signal CLK_OUT_INTERNAL : STD_LOGIC := '0';
    Signal CLK_DIV_OUTPUTS : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL NOT_RESET : STD_LOGIC;
    
    --Componet Initalizations
    Component Multiplexer_8to1 is
        Port (Inputs : in  STD_LOGIC_VECTOR (7 downto 0);
              SelectIn : IN STD_LOGIC_VECTOR(2 downto 0);
              Enable : IN STD_LOGIC;
              Output : OUT STD_LOGIC);
    End Component;
    
    Component Clock_Divider IS
      GENERIC (divider : positive := 100000000);
      PORT(CLK_IN : IN STD_LOGIC;
           CLK_OUT_REDUCED : OUT STD_LOGIC);
    END Component;
begin
    --Create the inverse reset signal
    NOT_RESET <= NOT RESET;
    
    --Map the actual clock output to follow our internal signal
    CLK_OUT <= CLK_OUT_INTERNAL;
    
    --Map the input clock to the first output position
    CLK_DIV_OUTPUTS(0) <= CLK_IN;
    CLK_DIV_OUTPUTS(7) <= '0';
    
    --Initalize the MUX
    MUX_8to1 : Multiplexer_8to1 port map(Inputs => CLK_DIV_OUTPUTS, SelectIn => MUX_SEL, Enable => NOT_RESET, Output => CLK_OUT_INTERNAL);
    
    --Initalize the Clock Dividers
    --Number for the divider are the ammount of clock cyles of 100 MHz in half of the period plus 1
    CLK_DIV_50MHz : Clock_Divider generic map (divider => 2) port map (CLK_IN => CLK_IN, CLK_OUT_REDUCED => CLK_DIV_OUTPUTS(1));
    CLK_DIV_25MHz : Clock_Divider generic map (divider => 3) port map (CLK_IN => CLK_IN, CLK_OUT_REDUCED => CLK_DIV_OUTPUTS(2));
    CLK_DIV_10MHz : Clock_Divider generic map (divider => 6) port map (CLK_IN => CLK_IN, CLK_OUT_REDUCED => CLK_DIV_OUTPUTS(3));
    CLK_DIV_5MHz : Clock_Divider generic map (divider => 11) port map (CLK_IN => CLK_IN, CLK_OUT_REDUCED => CLK_DIV_OUTPUTS(4));
    CLK_DIV_1MHz : Clock_Divider generic map (divider => 51) port map (CLK_IN => CLK_IN, CLK_OUT_REDUCED => CLK_DIV_OUTPUTS(5));
    CLK_DIV_500KHz : Clock_Divider generic map (divider => 101) port map (CLK_IN => CLK_IN, CLK_OUT_REDUCED => CLK_DIV_OUTPUTS(6));
END ARCHITECTURE Struct;
------------------------------------------------