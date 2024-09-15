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
begin
    
    process(A, B, Z, cond, opcode)
    begin
    	cond <= '0';
       
        case opcode is
            when "0000" => Z <= std_logic_vector(signed(a)+signed(b));
            when "0001" => Z <= std_logic_vector(signed(a)-signed(b));
            when "0010" => Z <= a and b;
            when "0011" => Z <= a or b;
            when "0100" => Z <= a xor b;
            when "0101" => Z <= std_logic_vector(shift_left(unsigned(A), to_integer(signed(B))));
            when "0110" => Z <= std_logic_vector(shift_right(unsigned(A), to_integer(signed(B))));
            when "0111" => Z <= std_logic_vector(shift_right(signed(A), to_integer(signed(B))));
            when "1000" =>
            	cond <= '1';
            	if signed(A) < signed(B) then
                    Z <= x"00000001";
                else
                	Z <= x"00000000";
				end if;
                
            when "1001" =>
            	cond <= '1';
            	if unsigned(A) < unsigned(B) then
                    Z <= x"00000001";
                else
                	Z <= x"00000000";
				end if;
                
            when "1010" =>
            	cond <= '1';
            	if signed(A) >= signed(B) then
                    Z <= x"00000001";
                else
                	Z <= x"00000000";
				end if;
                
            when "1011" =>
            	cond <= '1';
            	if unsigned(A) >= unsigned(B) then
                    Z <= x"00000001";
                else
                	Z <= x"00000000";
				end if;
                
            when "1100" =>
            	cond <= '1';
            	if A = B then
                    Z <= x"00000001";
                else
                	Z <= x"00000000";
				end if;
                
            when "1101" =>
            	cond <= '1';
            	if A /= B then
                    Z <= x"00000001";
                else
                	Z <= x"00000000";
				end if;
                
            when others => Z <= (others => '0');
            
        end case;
      
    end process;
end main;
