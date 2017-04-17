-- 2 to 1 Multiplexer
-- Requires: Basic Gates(AND, OR)
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity Multiplexer_2to1 is	
   port(X1, X2, Sel: in std_logic;
        Z: out std_logic);
end Multiplexer_2to1;

architecture Struct of Multiplexer_2to1 is 
	component ANDGate is
		port( A, B : in std_logic;
				 C : out std_logic);
	end component;

	component ORGate is
		port( A, B : in std_logic;
				 C : out std_logic);
	end component;
	
	signal AND1Out : STD_LOGIC;
	signal AND2Out : STD_LOGIC;
begin
   G1: ANDGate port map(X1, NOT Sel, AND1Out);
   G2: ANDGate port map(X2, Sel, AND2Out);
   G3: ORGate port map(AND1Out, AND2Out, Z);
end Struct;
------------------------------------------------

-- 4 to 1 Multiplexer
-- Requires: Mutiplexers(2 to 1 Multiplexer)
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity Multiplexer_4to1 is	
   port(X1, X2, X3, X4, Sel0, Sel1: in std_logic;
        Z: out std_logic);
end Multiplexer_4to1;

architecture Struct of Multiplexer_4to1 is 
	component Multiplexer_2to1 is
		port(X1, X2, Sel: in std_logic;
			Z: out std_logic);
	end component;
	
	signal Mux1Out : STD_LOGIC;
	signal Mux2Out : STD_LOGIC;
begin
   G1: Multiplexer_2to1 port map(X1, X2, Sel0, Mux1Out);
   G2: Multiplexer_2to1 port map(X3, X4, Sel0, Mux2Out);
   G3: Multiplexer_2to1 port map(Mux1Out, Mux2Out, Sel1, Z);
end Struct;
------------------------------------------------

-- 8 to 1 Multiplexer
-- Requires: Mutiplexers(2 to 1 Multiplexer, 4 to 1 Multiplexer), Basic Gates(AND)
------------------------------------------------
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity Multiplexer_8to1 is
    Port (Inputs : in  STD_LOGIC_VECTOR (7 downto 0);
		  SelectIn : IN STD_LOGIC_VECTOR(2 downto 0);
		  Enable : IN STD_LOGIC;
          Output : OUT STD_LOGIC);
end Multiplexer_8to1;

architecture Struct of Multiplexer_8to1 is

	component Multiplexer_2to1 is
		port(X1, X2, Sel: in std_logic;
			Z: out std_logic);
	end component;
	
	component Multiplexer_4to1 is
		port(X1, X2, X3, X4, Sel0, Sel1: in std_logic;
			Z: out std_logic);
	end component;
	
	component ANDGate is
        port( A, B : in std_logic;
                 C : out std_logic);
    end component;
    
	signal Mux1Out : STD_LOGIC;
    signal Mux2Out : STD_LOGIC;
    signal Mux3Out : STD_LOGIC;
begin
	G1: Multiplexer_4to1 port map(Inputs(0), Inputs(1), Inputs(2), Inputs(3), SelectIn(0), SelectIn(1), Mux1Out);
	G2: Multiplexer_4to1 port map(Inputs(4), Inputs(5), Inputs(6), Inputs(7), SelectIn(0), SelectIn(1), Mux2Out);
	G3: Multiplexer_2to1 port map(Mux1Out, Mux2Out, SelectIn(2), Mux3Out);
	G4: ANDGate port map(Mux3Out, Enable, Output);
end Struct;
------------------------------------------------