library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity mem_rv_tb is
end entity mem_rv_tb;

architecture testbench of mem_rv_tb is

  -- Component declaration of mem_rv
  component mem_rv is
    port (
      clock   : in std_logic;
      we      : in std_logic;
      address : in std_logic_vector(11 downto 0);
      datain  : in std_logic_vector(31 downto 0);
      dataout : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Signals to connect to the mem_rv module
  signal clock   : std_logic := '0';
  signal we      : std_logic := '0';
  signal address : std_logic_vector(11 downto 0) := (others => '0');
  signal datain  : std_logic_vector(31 downto 0) := (others => '0');
  signal dataout : std_logic_vector(31 downto 0);

  -- Clock period definition
  constant clock_period : time := 10 ns;

begin

  -- Instantiate the mem_rv module
  uut: mem_rv
    port map (
      clock   => clock,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout
    );

  -- Clock generation process
  clock_process : process
  begin
    while true loop
      clock <= '0';
      wait for 1ms;
      clock <= '1';
      wait for 1ms;
    end loop;
  end process;

  -- Stimulus process
  stimulus_process : process
    variable read_value : std_logic_vector(31 downto 0);
  begin
    -- Wait for the global reset to finish
    wait for 20 ns;

    -- Test 1: Read from address 0
    address <= "000000000000";
    we <= '0';
    wait for 2ms;
    read_value := dataout;
    report "Test 1 - Read data at address 0: " & integer'image(to_integer(unsigned(read_value)));

    
	-- Test 1: Read from address 0
    address <= "000000000100";
    we <= '0';
    wait for 2ms;
    read_value := dataout;
    report "Test 1 - Read data at address 0: " & integer'image(to_integer(unsigned(read_value)));


	-- Test 1: Read from address 0
    address <= "000000001000";
    we <= '0';
    wait for 2ms;
    read_value := dataout;
    report "Test 1 - Read data at address 0: " & integer'image(to_integer(unsigned(read_value)));


    -- End of simulation
    report "Simulation completed successfully.";
    wait;
  end process;

end architecture;

