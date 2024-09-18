library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gerador_imediatos is
    Port(
		instrucao	:	in	 	std_logic_vector(31 downto 0);
        imediato 	: 	out 	std_logic_vector(31 downto 0));
end gerador_imediatos;

architecture main of gerador_imediatos is
	signal opcode : std_logic_vector(6 downto 0);
    
begin
    
    opcode <= instrucao(6 downto 0);
    	
    imediato <=	std_logic_vector(resize(signed("000000000000000000000000000" & instrucao(24 downto 20)), 32)) when opcode = "0010011" and instrucao(14 downto 12) = "101" and instrucao(30) = '1' else
    			std_logic_vector(resize(signed(instrucao(31 downto 20)), 32))	when opcode = "0000011" or opcode = "0010011" or opcode = "1100111" else     				-- I-type
        		std_logic_vector(resize(signed(instrucao(31 downto 25) & instrucao(11 downto 7)), 32)) when opcode = "0100011" else											-- S-type
                std_logic_vector(resize(signed(instrucao(31) & instrucao(7) & instrucao(30 downto 25) & instrucao(11 downto 8) & "0"), 32)) when opcode = "1100011" else 	-- SB-type
                std_logic_vector(resize(signed(instrucao(31) & instrucao(19 downto 12) & instrucao(20) & instrucao(30 downto 21) & "0"), 32)) when opcode = "1101111" else	-- UJ-type
                std_logic_vector(resize(signed(instrucao(31 downto 12) & "000000000000"), 32)) when opcode = "0110111" else 												-- U-type
                std_logic_vector(resize(signed(instrucao(31 downto 12) & "000000000000"), 32)) when opcode = "0010111" else 												-- U-type
				(others => '0');
    
end main;

