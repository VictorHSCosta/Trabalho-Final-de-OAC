library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port (
        A, B : in std_logic_vector(31 downto 0);
        opcode : in std_logic_vector(3 downto 0);
        Z : out std_logic_vector(31 downto 0);
        cond : out std_logic
    );
end entity ULA;

architecture Behavioral of ULA is
    signal a32 : std_logic_vector(31 downto 0) := (others => '0');
    signal zero : std_logic := '0';
begin

    Z <= a32;
    cond <= zero;

    proc_ula: process(opcode, A, B)
    begin

        case opcode is
            when "0000" => 
                a32 <= std_logic_vector(unsigned(A) + unsigned(B));
            when "0001" => 
                a32 <= std_logic_vector(unsigned(A) - unsigned(B));
            when "0010" =>  -- AND
                a32 <= A and B;
            when "0011" =>  -- OR
                a32 <= A or B;
            when "0100" =>  -- XOR
                a32 <= A xor B;
            when "0101" =>  -- Deslocamento l�gico � esquerda
                a32 <= std_logic_vector(unsigned(A) sll to_integer(unsigned(B)));
            when "0110" =>  -- Deslocamento l�gico � direita
                a32 <= std_logic_vector(unsigned(A) srl to_integer(unsigned(B)));
            when "0111" =>  -- Deslocamento � direita com sinal (SRA)
                a32 <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B))));
            when "1000" =>  -- SLT A, B (a32 = 1 se A < B, com sinal)
                if signed(A) < signed(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1001" =>  -- SLTU A, B (a32 = 1 se A < B, sem sinal)
                if unsigned(A) < unsigned(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1010" =>  -- SGE A, B (a32 = 1 se A >= B, com sinal)
                if signed(A) >= signed(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1011" =>  -- SGEU A, B (a32 = 1 se A >= B, sem sinal)
                if unsigned(A) >= unsigned(B) then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1100" =>  -- SEQ A, B (a32 = 1 se A == B)
                if A = B then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when "1101" =>  -- SNE A, B (a32 = 1 se A != B)
                if A /= B then
                    a32 <= (others => '1');
                else
                    a32 <= (others => '0');
                end if;
            when others =>  -- Padr�o para qualquer outro opcode
                a32 <= (others => '0');
        end case;

        if a32 = X"00000000" then 
            zero <= '1'; 
        else 
            zero <= '0';
        end if;

    end process proc_ula;
end architecture Behavioral;

