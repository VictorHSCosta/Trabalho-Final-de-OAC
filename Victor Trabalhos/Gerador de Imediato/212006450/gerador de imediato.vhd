library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity genImm32 is
    port (
        instr : in std_logic_vector(31 downto 0);
        imm32 : out signed(31 downto 0)
    );
end genImm32;

architecture arch of genImm32 is

    signal funct7 : std_logic_vector(6 downto 0);
    signal rs1 : std_logic_vector(4 downto 0);
    signal rs2 : std_logic_vector(4 downto 0);
    signal rd : std_logic_vector(4 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal opcode : std_logic_vector(6 downto 0);

begin

    opcode <= instr(6 downto 0);
    rd <= instr(11 downto 7);
    funct3 <= instr(14 downto 12);
    rs1 <= instr(19 downto 15);
    rs2 <= instr(24 downto 20);
    funct7 <= instr(31 downto 25);

    process(opcode, funct3, funct7, rs1, rs2, rd, instr)
    begin
        case opcode is
            when "0000011" => 
                imm32 <= signed(resize(signed(instr(31 downto 20)), 32));  -- I-type
            when "0010011" => -- I-type*
                case funct3 is
                    when "101" =>
                        imm32 <= signed("0" & instr(30) & "0000000000000000000000000" & instr(24 downto 20)); 
                    when others =>
                        imm32 <= signed(resize(signed(instr(24 downto 20)), 32));  
                end case;
            when "1100111" => -- I-type
                imm32 <= signed(resize(signed(instr(31 downto 20)), 32));
            when "1100011" => -- SB-type
                imm32 <= signed(resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'), 32));
            when "0100011" => -- S-type
                imm32 <= signed(resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32));
            when "0110111" => -- U-type
                imm32 <= signed(resize(signed(instr(31 downto 12) & "000000000000"), 32));
            when "1101111" => -- UJ-type
		imm32 <= resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32);
            when others =>
                imm32 <= (others => '0');
        end case;
    end process;

end arch;

