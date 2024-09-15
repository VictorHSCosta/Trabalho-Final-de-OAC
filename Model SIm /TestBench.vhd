library ieee;
use ieee.std_logic_1164.all;

entity ent_tb is
end ent_tb;

architecture behavior of ent_tb is

    -- Componente do módulo que estamos testando
    component ent
        port (
            clock : in std_logic
        );
    end component;

    -- Sinal de clock que conectaremos ao módulo
    signal clock : std_logic := '1';

begin

    -- Instanciação do módulo sob teste (UUT - Unit Under Test)
    uut: ent port map (
        clock => clock
    );

    -- Processo para gerar o clock
    clock_process : process
    begin
        -- Loop infinito para alternar o clock a cada 5 ns
        loop
            clock <= not(clock);
            wait for 10 ns;
        end loop;
    end process clock_process;

end behavior;
