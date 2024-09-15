library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity PC is
  port (
    clock : in std_logic;
    we : in std_logic;
    datain : in std_logic_vector(11 downto 0);
    dataout : out std_logic_vector(11 downto 0)
  ) ;
end PC ; 

architecture arch of PC is

begin

  process(clock)
  begin
    if rising_edge(clock) then
      if we = '1' then
        dataout <= datain;
      end if;
    end if;
  end process;

end architecture ;