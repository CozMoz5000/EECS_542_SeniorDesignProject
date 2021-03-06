--EECS 542 Control Unit
------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EECS_542_Control_Unit IS
  PORT(FPGA_CLK_100MHz : IN STD_LOGIC;
       GLOBAL_RESET : IN STD_LOGIC;
       START_SAMPILING_TRIGGER : IN STD_LOGIC;
       CLK_SEL : IN STD_LOGIC_VECTOR(2 downto 0);
       LOCAL_RESET : OUT STD_LOGIC;
       SAMPILING_COMPLETED : OUT STD_LOGIC;
       SAMPILING_CLK_OUT : OUT STD_LOGIC);
END ENTITY EECS_542_Control_Unit;

ARCHITECTURE Struct OF EECS_542_Control_Unit IS
    --User Signals
    Signal LOCAL_RESET_INTERNAL : STD_LOGIC := '0';
    Signal CLK_SEL_INTERNAL : STD_LOGIC_VECTOR(2 downto 0) :=  "000";
    Signal Local_Count : INTEGER := 0;
    Signal SAMPILING_COMPLETED_INTERNAL : STD_LOGIC := '0';
    Signal SAMPILING_CLK_OUT_INTERNAL : STD_LOGIC := '0';
    
    --State Machine Definitions
    TYPE STATE_TYPE IS (IDLE, SAMPILING);
    SIGNAL state : STATE_TYPE;
    
    --Componet Initalizations
    Component EECS_542_Clock_Block IS
    PORT(CLK_IN : IN STD_LOGIC;
         RESET : IN STD_LOGIC;
         MUX_SEL : IN STD_LOGIC_VECTOR(2 downto 0);
         CLK_OUT : OUT STD_LOGIC);
    END Component;
begin
    --State Transition Block
    PROCESS (FPGA_CLK_100MHz, GLOBAL_RESET)
    BEGIN
        IF GLOBAL_RESET = '1' THEN
            --Reset to IDLE State
            state <= IDLE;
        ELSIF (rising_edge(FPGA_CLK_100MHz)) THEN
         CASE state IS
            WHEN IDLE =>
               --Set the output value to match our parameters
               CLK_SEL_INTERNAL <= CLK_SEL;
               
               --Make sure we are not saying we are done
               SAMPILING_COMPLETED_INTERNAL <= '0';
               
               --Check to see if we should start sampiling
               IF (START_SAMPILING_TRIGGER = '1') THEN
                    --Move to the Sampiling state
                    state <= SAMPILING;
               END IF;
            WHEN SAMPILING =>              
                --Chcek if we need to stop sampiling
                IF (Local_Count = 160) THEN
                    --Head back to the IDLE STATE
                    state <= IDLE;
                    --Signal that we are done
                    SAMPILING_COMPLETED_INTERNAL <= '1';
                END IF;
         END CASE;
        END IF;
    END PROCESS;
    
    --Initalize the Clock Block
    Clock_Module : EECS_542_Clock_Block port map (CLK_IN => FPGA_CLK_100MHz, RESET => '0', MUX_SEL => CLK_SEL_INTERNAL, CLK_OUT => SAMPILING_CLK_OUT_INTERNAL);
    
    PROCESS(SAMPILING_CLK_OUT_INTERNAL)
    BEGIN
        IF (state = SAMPILING) THEN
            IF rising_edge(SAMPILING_CLK_OUT_INTERNAL) THEN
                --Incremnt the Counter
                Local_Count <= Local_Count + 1;
            END IF;
        ELSIF(state = IDLE) THEN
            Local_Count <= 0;
        END IF;
    END PROCESS;
    
    --Process to handle the resets based on the states
    PROCESS(state)
    BEGIN
        CASE state IS
            WHEN IDLE =>
                --Assert Local Reset to Componenets
                LOCAL_RESET_INTERNAL <= '1';
            WHEN SAMPILING =>
                --Deassert Local Reset
                LOCAL_RESET_INTERNAL <= '0';
        END CASE;
    END PROCESS;
    
    --Map the internal reset to the output
    LOCAL_RESET <= LOCAL_RESET_INTERNAL;
    SAMPILING_COMPLETED <= SAMPILING_COMPLETED_INTERNAL;
    
    SAMPILING_CLK_OUT <= SAMPILING_CLK_OUT_INTERNAL WHEN (state = SAMPILING) ELSE '0';
END ARCHITECTURE Struct;
------------------------------------------------