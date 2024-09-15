library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_gerador_imediatos is
end tb_gerador_imediatos;

architecture main of tb_gerador_imediatos is
    signal tb_instrucao : std_logic_vector(31 downto 0);
    signal tb_imediato : std_logic_vector(31 downto 0);

    component gerador_imediatos
        Port ( instrucao : in std_logic_vector(31 downto 0);
               imediato : out std_logic_vector(31 downto 0));
    end gerador_imediatos;

begin
    DUT: gerador_imediatos
        Port map (
            instrucao => tb_instrucao,
            imediato => tb_imediato
        );

    Teste: process
    begin
        tb_instrucao <= x"000002B3"; -- R-type
        wait for 10 ns;
        
        tb_instrucao <= x"01002283"; -- I-type
        wait for 10 ns;
       
        tb_instrucao <= x"f9c00313"; -- I-type
        wait for 10 ns;
        
        tb_instrucao <= x"fff2c293"; -- I-type
        wait for 10 ns;

        tb_instrucao <= x"16200313"; -- I-type
        wait for 10 ns;
       
        tb_instrucao <= x"01800067"; -- I-type
        wait for 10 ns;
        
        tb_instrucao <= x"40a3d313"; -- I-type*
        wait for 10 ns;
        
        tb_instrucao <= x"00002437"; -- U-type
        wait for 10 ns;

        tb_instrucao <= x"02542e23"; -- S-type
        wait for 10 ns;
        
        tb_instrucao <= x"fe5290e3"; -- SB-type
        wait for 10 ns;
        
        tb_instrucao <= x"00c000ef"; -- UJ-type
        wait for 10 ns;
       
    end process;
end main;
