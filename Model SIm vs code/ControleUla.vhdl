library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUControl is
    Port (
        ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
        funct3 : in STD_LOGIC_VECTOR(2 downto 0);
        funct7 : in STD_LOGIC_VECTOR(6 downto 0);
        ALUControlOut : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ALUControl;

architecture Behavioral of ALUControl is
begin
    process(ALUOp, funct3, funct7)
    begin
        case ALUOp is
            when "00" => -- Tipo I (por exemplo, instruções imediatas)
                case funct3 is
                    when "000" => ALUControlOut <= "0000"; -- ADDI
                    when "111" => ALUControlOut <= "0010"; -- ANDI
                    when "110" => ALUControlOut <= "0011"; -- ORI
                    when "100" => ALUControlOut <= "0100"; -- XORI
                    when others => ALUControlOut <= "1111"; -- Padrão
                end case;
            when "01" => -- Instruções de branch
                case funct3 is
                    when "000" => ALUControlOut <= "1100"; -- BEQ
                    when "001" => ALUControlOut <= "1101"; -- BNE
                    when "100" => ALUControlOut <= "1000"; -- BLT
                    when "101" => ALUControlOut <= "1010"; -- BGE
                    when others => ALUControlOut <= "1111"; -- Padrão
                end case;
            when "10" => -- Instruções R-type
                case funct7 & funct3 is
                    when "0000000" & "000" => ALUControlOut <= "0000"; -- ADD
                    when "0100000" & "000" => ALUControlOut <= "0001"; -- SUB
                    when "0000000" & "111" => ALUControlOut <= "0010"; -- AND
                    when "0000000" & "110" => ALUControlOut <= "0011"; -- OR
                    when "0000000" & "100" => ALUControlOut <= "0100"; -- XOR
                    when "0000000" & "001" => ALUControlOut <= "0101"; -- SLL
                    when "0000000" & "101" => ALUControlOut <= "0110"; -- SRL
                    when "0100000" & "101" => ALUControlOut <= "0111"; -- SRA
                    when "0000000" & "010" => ALUControlOut <= "1000"; -- SLT
                    when "0000000" & "011" => ALUControlOut <= "1001"; -- SLTU
                    when others => ALUControlOut <= "1111"; -- Padrão
                end case;
            when others =>
                ALUControlOut <= "1111"; -- Padrão
        end case;
    end process;
end Behavioral;
