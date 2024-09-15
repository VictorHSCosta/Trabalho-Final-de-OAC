library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_mem_rv is
end entity tb_mem_rv;

architecture testbench of tb_mem_rv is
  signal clock : std_logic := '0';
  signal we : std_logic := '0';
  signal address : std_logic_vector(11 downto 0);
  signal datain : std_logic_vector(31 downto 0);
  signal dataout : std_logic_vector(31 downto 0);

begin
  
  uut: entity work.mem_rv
    port map (
      clock => clock,
      we => we,
      address => address,
      datain => datain,
      dataout => dataout
    );

  process
  begin
    while true loop
      clock <= '0';
      wait for 5 ns;
      clock <= '1';
      wait for 5 ns;
    end loop;
  end process;

  process
  begin
    for i in 2048 to 4095 loop
    	we <= '1';
      	address <= std_logic_vector(to_unsigned(i, 12));
        datain <= std_logic_vector(to_unsigned(i, 32));
      	wait for 20 ns;
    end loop;
    we <= '0';

    for i in 0 to 4095 loop
      address <= std_logic_vector(to_unsigned(i, 12));
      wait for 10 ns;
    end loop;
    
    wait;
  end process;
  
end architecture;
