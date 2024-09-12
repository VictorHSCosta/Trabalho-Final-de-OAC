ENTITY ula_tb IS
END ula_tb;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ARCHITECTURE tb_arch OF ula_tb IS

    COMPONENT ULA
        port (
            A, B : in std_logic_vector(31 downto 0);
            opcode : in std_logic_vector(3 downto 0);
            Z : out std_logic_vector(31 downto 0);
            cond : out std_logic
        );
    END COMPONENT;

    SIGNAL opcodeTb : std_logic_vector(3 DOWNTO 0) ;--:= "0000";
    SIGNAL A_tb, B_tb : std_logic_vector(31 DOWNTO 0); --:= x"00000000";
    SIGNAL Z_tb : std_logic_vector(31 DOWNTO 0);
    SIGNAL cond_tb : std_logic;

begin

ULA_tb: ULA
port map(
    opcode => opcodeTb, 
    A => A_tb, 
    B => B_tb, 
    Z => Z_tb,  
    cond => cond_tb 
);

process
begin
-- Soma a + b
opcodeTb <= "0000";
A_tb <= X"00000011";
B_tb <= X"00000011";
wait for 10 ns;
--subtracao de negativos 

opcodeTb <= "0001";
A_tb <= X"10000001";
B_tb <= X"11000001";
wait for 10 ns;

--subtracao de positivos

opcodeTb <= "0001";
A_tb <= X"00000001";
B_tb <= X"01000001";
wait for 10 ns;

-- and 

opcodeTb <= "0010";
A_tb <= X"10100101";
B_tb <= X"10001101";
wait for 10 ns;

-- or

opcodeTb <= "0011";
A_tb <= X"11111101";
B_tb <= X"00000001";
wait for 10 ns;

-- xor
opcodeTb <= "0100";
A_tb <= X"01111101";
B_tb <= X"00000001";
wait for 10 ns;

-- deslocamento logico a esquerda

opcodeTb <= "0101";
A_tb <= X"00000001";
B_tb <= X"00000011";
wait for 10 ns;

-- deslocamento logico a direita

opcodeTb <= "0110";
A_tb <= X"0000FFFF";
B_tb <= X"0000000F";
wait for 10 ns;

-- deslocamento a direita com sinal

opcodeTb <= "0111";
A_tb <= X"FF000001";
B_tb <= X"0000000F";
wait for 10 ns;

-- SLT A, B (a32 = 1 se A < B, com sinal)
--a > b

opcodeTb <= "1000";
A_tb <= X"000000FF";
B_tb <= X"00000001";
wait for 10 ns;

--a < b

opcodeTb <= "1000";
A_tb <= X"00000001";
B_tb <= X"000000FF";
wait for 10 ns;

-- SLTU A, B (a32 = 1 se A < B, sem sinal)
--a > b

opcodeTb <= "1001";
A_tb <= X"000000FF";
B_tb <= X"00000001";
wait for 10 ns;

--a < b

opcodeTb <= "1001";
A_tb <= X"00000001";
B_tb <= X"000000FF";
wait for 10 ns;

-- SGE A, B (a32 = 1 se A >= B, com sinal)
--a > b

opcodeTb <= "1010";
A_tb <= X"000000FF";
B_tb <= X"00000001";
wait for 10 ns;

--a < b

opcodeTb <= "1010";
A_tb <= X"00000001";
B_tb <= X"000000FF";
wait for 10 ns;

-- SGEU A, B (a32 = 1 se A >= B, sem sinal)
--a > b

opcodeTb <= "1011";
A_tb <= X"000000FF";
B_tb <= X"00000001";
wait for 10 ns;

--a < b

opcodeTb <= "1011";
A_tb <= X"00000001";
B_tb <= X"000000FF";
wait for 10 ns;

-- a = b

opcodeTb <= "1011";
A_tb <= X"00000001";
B_tb <= X"00000001";
wait for 10 ns;

-- SEQ A, B (a32 = 1 se A == B)
-- a = b

opcodeTb <= "1100";
A_tb <= X"00000f01";
B_tb <= X"00000f01";
wait for 10 ns;

-- a != b

opcodeTb <= "1100";
A_tb <= X"00000001";
B_tb <= X"10001001";

-- SNE A, B (a32 = 1 se A != B)

-- a != b

opcodeTb <= "1101";
A_tb <= X"00000001";
B_tb <= X"10010001";
wait for 10 ns;

-- a = b

opcodeTb <= "1101";
A_tb <= X"00000001";
B_tb <= X"00000001";
wait for 10 ns;

wait;

end process;

end tb_arch;
