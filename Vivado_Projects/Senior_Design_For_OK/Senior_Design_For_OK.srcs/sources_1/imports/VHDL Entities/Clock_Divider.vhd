--Clock Divider
------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Clock_Divider IS
  -- 1 sec period with 100MHz Clock
  -- Formula: Clock Frequency (100MHz:100,000,000) / Period (in seconds)
  GENERIC (divider : positive := 100000000);
  PORT(CLK_IN : IN STD_LOGIC;
       CLK_OUT_REDUCED : OUT STD_LOGIC);
END ENTITY Clock_Divider;

ARCHITECTURE Struct OF Clock_Divider IS
    Signal ClockDiv : natural range 1 to divider-1 := 1;
    Signal clk_out  : STD_LOGIC := '1';
begin

    Clock_Dividing_Process : PROCESS (CLK_IN) IS
    BEGIN
      IF rising_edge(CLK_IN) THEN
        IF (ClockDiv = (divider-1)) THEN
          ClockDiv <= 1;
          clk_out <= (NOT clk_out);
        ELSE
          ClockDiv <= (ClockDiv + 1);
          clk_out <= (clk_out);
        END IF;
      END IF;
    END PROCESS Clock_Dividing_Process;

    CLK_OUT_REDUCED <= clk_out;
END ARCHITECTURE Struct;
------------------------------------------------