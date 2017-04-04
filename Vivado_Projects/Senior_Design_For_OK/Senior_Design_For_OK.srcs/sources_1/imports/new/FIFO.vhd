
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FIFO is
    generic(
        mem_size : integer;
        mem_width : integer
    );
    port(
        signal fifo_write_clk            : in std_logic;
        signal read_en              : in std_logic;
        signal rst                  : in std_logic;
        signal data_in              : in std_logic_vector(mem_width-1 downto 0);
        signal data_out             : out std_logic_vector(mem_width-1 downto 0);
        signal fifo_state           : out std_logic
    );    
end FIFO;

architecture Behavioral of FIFO is


signal zero_data : std_logic_vector(mem_width-1 downto 0) := (others => '0');
signal write_address, read_address : integer range 0 to mem_size-1 := 0;

type fifo_mem_type is array(0 to mem_size-1) of std_logic_vector(mem_width-1 downto 0);
signal fifo_mem : fifo_mem_type := (others => zero_data);
signal master_write_controller, master_read_controller : std_logic := '1';
signal effective_write_clk, effective_read_en : std_logic;
signal first_write_cycle_passed : std_logic := '0';

begin

    effective_write_clk <= master_write_controller and fifo_write_clk;
    effective_read_en <= master_read_controller and read_en;
    
    write_to_mem: process (effective_write_clk, rst)
        begin
            if(rst = '1') then
                fifo_mem <= (others => zero_data);
            else 
                if(rising_edge(effective_write_clk)) then
                    fifo_mem(write_address) <= data_in;  
                end if;
            end if;
        end process;
                    
    read_from_mem: process(read_address, rst)
        begin
            if(rst = '1') then
                data_out <= (others => '0');
            else
                data_out <= fifo_mem(read_address);
            end if;
        end process;
                                          
    update_write_pointer: process (effective_write_clk, rst)
        begin
            if(rst = '1') then
                write_address <= 0;
                first_write_cycle_passed <= '0';
                master_write_controller <= '1';
            else                           
                if(rising_edge(effective_write_clk)) then
                    if(first_write_cycle_passed = '0' and (write_address /= read_address)) then
                        first_write_cycle_passed <= '1';
                    end if; 
                    if(first_write_cycle_passed = '1' and (write_address = read_address)) then
                        master_write_controller <= '0'; 
                        if( write_address = 0 ) then
                            write_address <= mem_size - 1;
                        else
                            write_address <= write_address - 1;
                        end if;                            
                    elsif(write_address >= mem_size - 1) then                               
                        write_address <= 0;
                    else 
                        write_address <= write_address + 1;
                    end if;                               
                end if;
            end if;
          end process;
       
   update_read_pointer: process (effective_read_en, rst)
        begin
            if(rst = '1') then
                master_read_controller <= '1';
                read_address <= 0;
            elsif(rising_edge(effective_read_en)) then
                if(master_write_controller = '0' and (write_address = read_address)) then
                    master_read_controller <= '0';
                elsif(read_address >= mem_size - 1) then                               
                    read_address <= 0;
                else 
                    read_address <= read_address + 1;
                end if;
            end if;
        end process;
        
   fifo_state <= master_write_controller;
                                                     
end Behavioral;


