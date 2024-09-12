library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_mem_rv is
end entity tb_mem_rv;

architecture behavior of tb_mem_rv is

    component mem_rv
        port (
            clock   : in std_logic;
            we      : in std_logic;  -- Write Enable
            address : in std_logic_vector;
            datain  : in std_logic_vector;
            dataout : out std_logic_vector
        );
    end component;

    -- Sinais para a entidade
    signal clock   : std_logic := '0';
    signal we      : std_logic := '0';  -- Write Enable
    signal address : std_logic_vector(11 downto 0) := "000000000000"; -- 12 bits de endereço (4096 locais)
    signal datain  : std_logic_vector(31 downto 0) := x"00000000"; -- 32 bits de entrada de dados
    signal dataout : std_logic_vector(31 downto 0) := x"00000000"; -- 32 bits de saída de dados

    -- Constante para o período do clock
    constant clk_period : time := 4 ns;

    -- Função para converter std_logic_vector para string (caso necessário)
    impure function slv_to_string(slv: std_logic_vector) return string is
        variable l : line;
        variable result : string(1 to 8);  -- Ajuste o comprimento da string conforme necessário
        variable value : integer;
    begin
        value := to_integer(unsigned(slv));  -- Converte std_logic_vector para integer
        write(l, value, RIGHT, 8);           -- Escreve o inteiro na variável line
        result := l.all;                     -- Converte a line para string
        return result;
    end function;

begin
    -- Instância da entidade mem_rv (RAM)
    uut: entity work.mem_rv
        port map (
            clock => clock,
            we => we,
            address => address,
            datain => datain,
            dataout => dataout
        );

    -- Processo para gerar o clock
    clock_process : process
    begin
        while true loop
            clock <= '0';
            wait for clk_period / 2;
            clock <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Processo de teste para verificar escrita e leitura
    stimulus_process : process
        variable line_text: line;  -- Mova a variável line_text para dentro do processo
    begin
        -- Escrever dados na parte de código (endereços 0 a 2047)
        for i in 0 to 2047 loop
            we <= '1'; -- Habilita escrita
            address <= std_logic_vector(to_unsigned(i, 12));  -- Define o endereço para instruções
            datain <= std_logic_vector(to_unsigned(i, 30)) & "00"; -- Dado a ser escrito
            wait for 4 ns;
        end loop;

        -- Escrever dados na parte de dados (endereços 2048 a 4095)
        for i in 2048 to 4095 loop
            we <= '1'; -- Habilita escrita
            address <= std_logic_vector(to_unsigned(i, 12));  -- Define o endereço para dados
            datain <= std_logic_vector(to_unsigned(i - 2048, 30)) & "11"; -- Dado a ser escrito
            wait for 4 ns;
        end loop;

        -- Desabilitar escrita para iniciar a leitura
        we <= '0';
        wait for 10 ns;

        -- Ler dados da RAM e verificar (endereços 0 a 4095)
        for i in 0 to 4095 loop
            address <= std_logic_vector(to_unsigned(i, 12));  -- Define o endereço para leitura
            wait for 1 ns; -- Espera para leitura
            report "Lendo endereço " & integer'image(i) & " dado: " & slv_to_string(dataout);  -- Corrigido
        end loop;

        -- Fim do teste
        wait;
    end process;

end architecture behavior;

