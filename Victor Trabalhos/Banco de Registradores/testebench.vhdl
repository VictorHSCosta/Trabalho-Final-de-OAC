library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ent_bench is
end ent_bench;

architecture TestBench of ent_bench is

  component XREGS
    generic (WSIZE : natural := 32);
    port (
      clk, wren : in std_logic;
      rs1, rs2, rd : in std_logic_vector(4 downto 0);
      data : in std_logic_vector(WSIZE-1 downto 0);
      ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
    );
  end component;

  signal clk, wren : std_logic := '0';
  signal rs1, rs2, rd : std_logic_vector(4 downto 0) := (others => '0');
  signal data : std_logic_vector(31 downto 0) := (others => '0');
  signal ro1, ro2 : std_logic_vector(31 downto 0);

begin

  UUT : XREGS
    generic map (WSIZE => 32)
    port map (
      clk => clk,
      wren => wren,
      rs1 => rs1,
      rs2 => rs2,
      rd => rd,
      data => data,
      ro1 => ro1,
      ro2 => ro2
    );

  -- Geração do clock
  clk <= not clk after 1 ns;

  -- Teste de todos os registradores
  process
  begin
    wren <= '0';
    rd <= (others => '0');
    data <= (others => '0');
    rs1 <= (others => '0');
    rs2 <= (others => '0');

    for i in 0 to 31 loop
      -- Escreve no registrador `i`
      wren <= '1';
      rd <= std_logic_vector(to_unsigned(i, rd'length));
      data <= std_logic_vector(to_unsigned(i, data'length));
      wait for 2 ns;
      
      -- Desabilita escrita
      wren <= '0';
      wait for 1 ns;
      rs1 <= std_logic_vector(to_unsigned(i, rs1'length));
      rs2 <= std_logic_vector(to_unsigned((i+1) mod 32, rs2'length));  -- Próximo registrador para rs2
      wait for 2 ns;

      -- Verificação usando ASSERT
      assert ro1 = std_logic_vector(to_unsigned(i, ro1'length))
        report "Erro na leitura do registrador rs1: esperado " & integer'image(i) & ", obtido " & integer'image(to_integer(unsigned(ro1)))
        severity error;

      assert ro2 = std_logic_vector(to_unsigned((i+1) mod 32, ro2'length))
        report "Erro na leitura do registrador rs2: esperado " & integer'image((i+1) mod 32) & ", obtido " & integer'image(to_integer(unsigned(ro2)))
        severity error;
      
    end loop;

    wait;
  end process;

end architecture;

