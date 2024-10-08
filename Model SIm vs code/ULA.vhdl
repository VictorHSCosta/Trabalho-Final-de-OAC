library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    Port(
        ATIVA_ULA : in std_logic;
        opcode : in std_logic_vector(3 downto 0);
        A, B : in std_logic_vector(31 downto 0);
        Z : out std_logic_vector(31 downto 0);
        cond : out std_logic
    );
end ULA;

architecture Behavioral of ULA is
    signal a32 : std_logic_vector(31 downto 0);
begin
    Z <= a32;

    proc_ula: process(opcode, A, B) 
    begin
        -- Verifica se o resultado é zero
        if a32 = X"00000000" then 
            cond <= '1'; 
        else 
            cond <= '0';
        end if;

        -- Seleção de operação com base no opcode
        case opcode is
            when "0000" =>  -- Soma
                a32 <= std_logic_vector(unsigned(A) + unsigned(B));
            when "0001" =>  -- Subtração
                a32 <= std_logic_vector(unsigned(A) - unsigned(B));
            when "0010" =>  -- AND
                a32 <= A and B;
            when "0011" =>  -- OR
                a32 <= A or B;
            when "0100" =>  -- XOR
                a32 <= A xor B;
            when "0101" =>  -- Deslocamento lógico à esquerda
                a32 <= std_logic_vector(unsigned(A) sll to_integer(unsigned(B)));
            when "0110" =>  -- Deslocamento lógico à direita
                a32 <= std_logic_vector(unsigned(A) srl to_integer(unsigned(B)));
            when "0111" =>  -- Deslocamento à direita com sinal (SRA)
            a32 <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B))));

            when "1000" =>  -- SLT A, B (Z = 1 se A < B, com sinal)
                if signed(A) < signed(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1001" =>  -- SLTU A, B (Z = 1 se A < B, sem sinal)
                if unsigned(A) < unsigned(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1010" =>  -- SGE A, B (Z = 1 se A ? B, com sinal)
                if signed(A) >= signed(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1011" =>  -- SGEU A, B (Z = 1 se A ? B, sem sinal)
                if unsigned(A) >= unsigned(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1100" =>  -- SEQ A, B (Z = 1 se A == B)
                if A = B then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1101" =>  -- SNE A, B (Z = 1 se A != B)
                if A /= B then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when others =>  -- Padrão para qualquer outro opcode
                a32 <= (others => '0');
        end case;
    
    end process proc_ula;
end architecture Behavioral;