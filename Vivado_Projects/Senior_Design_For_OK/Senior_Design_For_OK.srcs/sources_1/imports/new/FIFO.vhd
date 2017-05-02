--This FIFO uses a built-in BRAM. For writing it operates on the fifo write clk and for reading it operates on the usb_read_clk and read_en signal. 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity FIFO is
    generic(
        mem_size                    : integer;             --depth of the FIFO
        mem_width                   : integer             --width of the FIFO
    );   
    port(
        signal fpga_clk             : in std_logic;
        signal fifo_write_clk       : in std_logic;
        signal usb_read_clk         : in std_logic;
        signal read_en              : in std_logic;
        signal rst                  : in std_logic;
        signal data_in              : in std_logic_vector(15 downto 0);
        signal data_out             : out std_logic_vector(15 downto 0);
        signal fifo_full            : out std_logic;   -- a bit that indicates whether or not the FIFO is full
        signal num_of_data          : out std_logic_vector(14 downto 0)
    );    
end FIFO;

architecture Behavioral of FIFO is

Component bram_fifo IS
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
  );
END Component;

signal effective_read_en : std_logic := '0';

begin


--effective_read_en <= read_en and usb_read_clk;

b_fifo: bram_fifo port map(
            wr_clk => fpga_clk,
            rd_clk => usb_read_clk,
            rst => rst,
            din => data_in,
            dout => data_out,
            wr_en => fifo_write_clk,
            rd_en => read_en,
            full => fifo_full,
            empty => open,
            rd_data_count => num_of_data
        );


                                                     
end Behavioral;


