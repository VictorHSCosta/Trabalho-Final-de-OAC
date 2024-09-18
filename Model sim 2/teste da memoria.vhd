
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_mem_rv is
end tb_mem_rv;

architecture sim of tb_mem_rv is

  -- Signals for testbench
  signal clock   : std_logic := '0';
  signal we      : std_logic;
  signal address : std_logic_vector(11 downto 0);
  signal datain  : std_logic_vector(31 downto 0);
  signal dataout : std_logic_vector(31 downto 0);

  -- Clock generation (100ns period)
  constant clk_period : time := 100 ns;

  -- Instantiate the unit under test (UUT)
  component mem_rv is
    port (
      clock   : in std_logic;
      we      : in std_logic;
      address : in std_logic_vector(11 downto 0);
      datain  : in std_logic_vector(31 downto 0);
      dataout : out std_logic_vector(31 downto 0)
    );
  end component;

begin

  -- Clock process to generate clock signal
  clock_process : process
  begin
    clock <= '0';
    wait for clk_period / 2;
    clock <= '1';
    wait for clk_period / 2;
  end process;

  -- Instantiate the UUT
  uut: mem_rv
    port map (
      clock   => clock,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout
    );

  -- Test process
  process
  begin
    -- Initialize signals
    we <= '0';
    datain <= (others => '0');
    
    -- Test Case 1: Reading from address 2048
    address <= std_logic_vector(to_unsigned(2048, 12));
    wait for clk_period;

    -- Test Case 2: Reading from address 2049
    address <= std_logic_vector(to_unsigned(2049, 12));
    wait for clk_period;

    -- Test Case 3: Writing to address 2050
    address <= std_logic_vector(to_unsigned(2050, 12));
    wait for clk_period;
    
    -- Test Case 4: Reading from address 2050 to check the write
    address <= std_logic_vector(to_unsigned(2050, 12));
    wait for clk_period;

    -- Test Case 5: Writing to address 2051
    address <= std_logic_vector(to_unsigned(2051, 12));
    datain <= x"87654321";  -- Example data
    
    
    -- Test Case 6: Reading from address 2051 to check the write
    address <= std_logic_vector(to_unsigned(2051, 12));
    wait for clk_period;

    -- Test Case 7: Reading from address 2052
    address <= std_logic_vector(to_unsigned(2052, 12));
    wait for clk_period;

    -- End simulation
    wait;
  end process;

end architecture;
