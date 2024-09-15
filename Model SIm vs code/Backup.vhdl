library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ULA is
    Port(
        opcode : in std_logic_vector(3 downto 0);
        A, B : in std_logic_vector(31 downto 0);
        Z : out std_logic_vector(31 downto 0);
        cond : out std_logic
    );
end ULA;

architecture main of ULA is
    signal Z_internal : std_logic_vector(31 downto 0);
    signal cond_internal : std_logic;
begin
    
    process(A, B, opcode)
    begin
        cond_internal <= '0';
       
        case opcode is
            when "0000" => Z_internal <= std_logic_vector(signed(A) + signed(B));
            when "0001" => Z_internal <= std_logic_vector(signed(A) - signed(B));
            when "0010" => Z_internal <= A and B;
            when "0011" => Z_internal <= A or B;
            when "0100" => Z_internal <= A xor B;
            when "0101" => Z_internal <= std_logic_vector(shift_left(unsigned(A), to_integer(signed(B))));
            when "0110" => Z_internal <= std_logic_vector(shift_right(unsigned(A), to_integer(signed(B))));
            when "0111" => Z_internal <= std_logic_vector(shift_right(signed(A), to_integer(signed(B))));
            when "1000" =>
                cond_internal <= '1';
                if signed(A) < signed(B) then
                    Z_internal <= x"00000001";
                else
                    Z_internal <= x"00000000";
                end if;
                
            when "1001" =>
                cond_internal <= '1';
                if unsigned(A) < unsigned(B) then
                    Z_internal <= x"00000001";
                else
                    Z_internal <= x"00000000";
                end if;
                
            when "1010" =>
                cond_internal <= '1';
                if signed(A) >= signed(B) then
                    Z_internal <= x"00000001";
                else
                    Z_internal <= x"00000000";
                end if;
                
            when "1011" =>
                cond_internal <= '1';
                if unsigned(A) >= unsigned(B) then
                    Z_internal <= x"00000001";
                else
                    Z_internal <= x"00000000";
                end if;
                
            when "1100" =>
                cond_internal <= '1';
                if A = B then
                    Z_internal <= x"00000001";
                else
                    Z_internal <= x"00000000";
                end if;
                
            when "1101" =>
                cond_internal <= '1';
                if A /= B then
                    Z_internal <= x"00000001";
                else
                    Z_internal <= x"00000000";
                end if;
                
            when others => Z_internal <= (others => '0');
            
        end case;
    end process;

    -- Atribuindo os sinais internos às saídas
    Z <= Z_internal;
    cond <= cond_internal;

end main;
