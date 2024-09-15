library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity ent is
  port (
    clock : in std_logic;
    we : in std_logic;
    datain : in std_logic_vector(31 downto 0);
    dataout : out std_logic_vector(31 downto 0);
  ) ;
end ent ; 

architecture arch of ent is

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