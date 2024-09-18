
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_gerador_imediatos is
end tb_gerador_imediatos;

architecture sim of tb_gerador_imediatos is

    -- Component declaration of the unit under test (UUT)
    component gerador_imediatos is
        port (
            instrucao : in std_logic_vector(31 downto 0);
            imediato  : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Signals for testbench
    signal instrucao_tb : std_logic_vector(31 downto 0);
    signal imediato_tb  : std_logic_vector(31 downto 0);

begin
    -- Instantiate the unit under test (UUT)
    uut: gerador_imediatos
        port map (
            instrucao => instrucao_tb,
            imediato  => imediato_tb
        );

    -- Test process
    process
    begin
        -- Test case: instrucao = 00002297
        instrucao_tb <= x"00002297";  -- Hexadecimal for binary input 00000000000000000010001010010111
        
        wait for 10 ns;  -- Wait some time for the result

        -- Stop the simulation
        wait;
    end process;

end sim;
