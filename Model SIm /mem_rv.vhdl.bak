library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity mem_rv is
  port (
    clock   : in std_logic;
    we      : in std_logic;
    address : in std_logic_vector(11 downto 0);
    datain  : in std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0)
  );
end entity mem_rv;

architecture RTL of mem_rv is
  type ram_type is array (0 to 4095) of std_logic_vector(31 downto 0);

  impure function init_ram return ram_type is
    file text_file: text open read_mode is "arquivo.txt";
    variable text_line: line;
    variable ram_content: ram_type;

  begin
    for i in 0 to 2048 loop  
      if endfile(text_file) then
        exit;
      end if;
      readline(text_file, text_line);
      hread(text_line, ram_content(i));
      
    end loop;
    return ram_content;
  end function;
  
  signal mem : ram_type := init_ram;

begin

  process (clock, datain, dataout)
  begin
    if rising_edge(clock) then
      dataout <= mem(to_integer(unsigned(address)));
      
      if we = '1' then
        if to_integer(unsigned(address)) >= 2048 then
          mem(to_integer(unsigned(address))) <= datain;
        end if;
      end if;
      
    end if;
  end process;
end architecture;