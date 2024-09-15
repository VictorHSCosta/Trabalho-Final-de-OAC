library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity XREGS is
    Port(
    	clk, wren		: in std_logic;
		rs1, rs2, rd 	: in std_logic_vector(4 downto 0);
		data		 	: in std_logic_vector(31 downto 0);
		ro1, ro2		: out std_logic_vector(31 downto 0)
        );
        
end XREGS;

architecture main of XREGS is
	type reg_array is array(31 downto 0) of std_logic_vector(31 downto 0); -- Inicializa o array de registradores
    signal registers : reg_array := (others => (others => '0'));
    
begin

    process(rs1, rs2, registers)
    begin
    
    	if rs1 = "00000" then
            ro1 <= (others => '0');
        else
            ro1 <= registers(to_integer(unsigned(rs1))); 			--Retorna o valor do endereço rs1
        end if;
    	
        if rs2 = "00000" then
            ro2 <= (others => '0');
        else
            ro2 <= registers(to_integer(unsigned(rs2)));			--Retorna o valor do endereço rs2
        end if;
        
    end process;
    
    process(clk)
    begin
    	if rising_edge(clk) then									--Analise na borda de subida do clk
            if wren = '1' then
                if rd /= "00000" then 								--Verifica quando o endereço do registrador de destino será referente ao registrador 'zero'
                    registers(to_integer(unsigned(rd))) <= data; 	-- Se não for o endereço verificado anteriormente, escreve o dado no registrador destino
                end if;
            end if;
        end if;
    
    end process;
        
end main;