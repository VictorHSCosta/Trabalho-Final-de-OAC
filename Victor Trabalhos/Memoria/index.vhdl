library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity mem_rv is
    port (
        clock   : in std_logic;
        we      : in std_logic;  -- Write Enable
        address : in std_logic_vector; -- Exemplo: 8 bits de endereço
        datain  : in std_logic_vector; -- Exemplo: 32 bits de dados de entrada
        dataout : out std_logic_vector  -- Exemplo: 32 bits de dados de saída
    );
end entity mem_rv;

architecture RTL of mem_rv is
    type ram_type is array (0 to (2**address'length - 1)) of std_logic_vector(datain'range);
    signal ram : ram_type;
    signal read_address : std_logic_vector(address'range);

    -- Function to convert std_logic_vector to an integer string
    impure function slv_to_string(slv: std_logic_vector) return string is
        variable l : line;
        variable result : string(1 to 8);  -- Adjust this range for your required string length
        variable value : integer;
    begin
        value := to_integer(unsigned(slv));  -- Convert std_logic_vector to integer
        write(l, value, RIGHT, 8);           -- Write integer to line
        result := l.all;                     -- Convert line to string
        return result;
    end function;

begin

process(clock)
    file text_file : text open write_mode is "arquivo.txt";  -- Declare file
    variable text_line : line;  -- Declare line for writing
begin
    if rising_edge(clock) then
        if we = '1' then
            -- Write to RAM when 'we' is enabled
            ram(to_integer(unsigned(address))) <= datain;

            -- Write to the text file
            write(text_line, slv_to_string(datain));  -- Convert datain to string
            writeline(text_file, text_line);  -- Write the line to the file
        end if;

        -- Read from RAM
        read_address <= address;
        dataout <= ram(to_integer(unsigned(read_address)));  -- Output the read data
    end if;
end process;


end architecture;

