library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity declaration
entity testbench is
end entity testbench;

-- Architecture definition
architecture tb_arch of testbench is
    -- Component declaration
    component genImm32 is
        port (
            instr : in std_logic_vector(31 downto 0);
            imm32 : out signed(31 downto 0)
        );
    end component;

    -- Signal declaration
    signal instrSignal : std_logic_vector(31 downto 0);
    signal immSignal : signed(31 downto 0);  -- Add this if you need to observe imm32

begin

    -- Component instantiation
    sim : genImm32
        port map (
            instr => instrSignal,
            imm32 => immSignal  -- Connect imm32 to a signal to observe it
        );

process
begin 
    instrSignal <= x"000002b3"; -- add t0, zero, zero
    wait for 10 ns;

    instrSignal <= x"01002283"; -- lw t0, 16(zero)
    wait for 10 ns;

    instrSignal <= x"f9c00313"; -- addi t1, zero, -100
    wait for 10 ns;

    instrSignal <= x"fff2c293"; -- xori t0, t0, -1
    wait for 10 ns;

    instrSignal <= x"16200313"; -- addi t1, zero, 354
    wait for 10 ns;

    instrSignal <= x"01800067"; -- jalr zero, zero, 0x18
    wait for 10 ns;

    instrSignal <= x"40a3d313"; -- srai t1, t2, 10
    wait for 10 ns;

    instrSignal <= x"00002437"; -- lui s0, 2
    wait for 10 ns;

    instrSignal <= x"02542e23"; -- sw t0, 60(s0)
    wait for 10 ns;

    instrSignal <= x"fe5290e3"; -- bne t0, t0, main
    wait for 10 ns;

    instrSignal <= x"00c000ef"; -- jal rot
    wait for 10 ns;
end process;

end architecture tb_arch;
