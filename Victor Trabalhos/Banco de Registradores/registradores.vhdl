library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity XREGS is
  generic (WSIZE : natural := 32);
    port (
    clk, wren : in std_logic;
    rs1, rs2, rd : in std_logic_vector(4 downto 0);
    data : in std_logic_vector(WSIZE-1 downto 0);
    ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0));
end XREGS; 

architecture arch of XREGS is
  type reg_array is array (0 to 31) of std_logic_vector(WSIZE-1 downto 0);

  signal regs : reg_array := (others => (others => '0'));

  signal  rdS : std_logic_vector(4 downto 0);

begin

  process(clk)

  begin

    rdS <= rd;

    if rising_edge(clk) then

     	if wren = '1' then
            if rdS /= "00000" then
                regs(to_integer(unsigned(rd))) <= data;
            end if;
        end if;

        ro1 <= regs(to_integer(unsigned(rs1)));
        ro2 <= regs(to_integer(unsigned(rs2)));
      

    end if;
    
    end process;

end architecture ;