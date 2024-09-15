library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ULA is
end tb_ULA;

architecture main of tb_ULA is
    signal tb_opcode : std_logic_vector(3 downto 0);
    signal tb_A : std_logic_vector(31 downto 0);
    signal tb_B : std_logic_vector(31 downto 0);
	signal tb_Z : std_logic_vector(31 downto 0);
	signal tb_cond : std_logic;
   	

    component ULA
        Port ( 
        	opcode : in std_logic_vector(3 downto 0);
			A, B : in std_logic_vector(31 downto 0);
			Z : out std_logic_vector(31 downto 0);
			cond : out std_logic);
    end ULA;

begin
    DUT: ULA
        Port map (
            opcode => tb_opcode,
            A => tb_A,
            B => tb_B,
            cond => tb_cond,
            Z => tb_z
        );

    Teste: process
    begin
    	tb_a <= std_logic_vector(to_signed(5, 32));
        tb_b <= std_logic_vector(to_signed(-5, 32));
        
        tb_opcode <= "0000";
        wait for 10ns;
       	
        tb_opcode <= "0001";
        wait for 10ns;
        
        tb_opcode <= "0010";
        wait for 10ns;
        
        tb_opcode <= "0011";
        wait for 10ns;
        
        tb_opcode <= "0100";
        wait for 10ns;
        
        tb_opcode <= "0101";
        wait for 10ns;
        
        tb_opcode <= "0110";
        wait for 10ns;
        
        tb_opcode <= "0111";
        wait for 10ns;
        
        tb_opcode <= "1000";
        wait for 10ns;
        
        tb_opcode <= "1001";
        wait for 10ns;
        
        tb_opcode <= "1010";
        wait for 10ns;
        
        tb_opcode <= "1011";
        wait for 10ns;
        
        tb_opcode <= "1100";
        wait for 10ns;
        
        tb_opcode <= "1101";
        wait for 10ns;
        
       
    end process;
end main;
