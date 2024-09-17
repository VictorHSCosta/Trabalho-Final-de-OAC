library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity ent_tb is
end ent_tb;

architecture behavior of ent_tb is

    -- Componente do módulo que estamos testando
    component MULTICICLO
        port (
            clock : in std_logic
        );
    end component;

    -- Sinal de clock que conectaremos ao módulo
    signal clock : std_logic;

begin

    -- Instanciação do módulo sob teste (UUT - Unit Under Test)
    uut: MULTICICLO port map (
        clock => clock
    );

    -- Processo para gerar o clock
    clock_process : process
    begin
        -- Loop infinito para alternar o clock a cada 5 ns
        loop
	    clock <= '0';
            wait for 1 ms;
	    clock <= '1';
            wait for 1 ms;
        end loop;
    end process clock_process;

end behavior;
