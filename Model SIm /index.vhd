
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity MULTICICLO is
  port (
  	clock : in std_logic
  ) ;
end MULTICICLO ; 

architecture arch of MULTICICLO is
  component XREGS is
    Port(
    	clk, wren		: in std_logic;
		rs1, rs2, rd 	: in std_logic_vector(4 downto 0);
		data		 	: in std_logic_vector(31 downto 0);
		ro1, ro2		: out std_logic_vector(31 downto 0)
        ); 
  end component;

  component gerador_imediatos is
    Port(
		instrucao	:	in	 	std_logic_vector(31 downto 0);
        imediato 	: 	out 	std_logic_vector(31 downto 0)
  );
  end component;

  component mem_rv is
    port (
      clock   : in std_logic;
      we      : in std_logic;
      address : in std_logic_vector(11 downto 0);
      datain  : in std_logic_vector(31 downto 0);
      dataout : out std_logic_vector(31 downto 0)
    );
  end component;

  component ULA is
    Port(
        opcode : in std_logic_vector(3 downto 0);
        A, B : in std_logic_vector(31 downto 0);
        Z : out std_logic_vector(31 downto 0);
        cond : out std_logic
    );
  end component;

  signal estado : std_logic_vector(3 downto 0) := "0000";
  signal CONTADOR_DE_PROGRAMA: std_logic_vector(11 downto 0) := (others => '0');
  signal pc_back : std_logic_vector(11 downto 0);
  signal dataout : std_logic_vector(31 downto 0);
  signal EscreveReg, LeMem, EscreveMem, louD, EscreveIR, EscrevePC, EscrevePCB, OrigPC, cond: std_logic;
  signal EscrevePCCond : std_logic := '0';
  signal clk : std_logic;
  signal DADO_ESCRITA_REG, ro1, ro2, imediato, GerarImediato, datain, A, B, Z : std_logic_vector(31 downto 0);
  signal rs1, rs2, rd : std_logic_vector(4 downto 0);
  signal ENDERECO_MEMORIA : std_logic_vector(11 downto 0);
  signal opcode_ULA : std_logic_vector(3 downto 0);
  signal Mem2Reg : std_logic_vector(1 downto 0);
  signal OrigBULA, OrigAULA, ALUOp: std_logic_vector(1 downto 0) := "00";
  signal funct3 : std_logic_vector(2 downto 0);
  signal funct7 : std_logic_vector(6 downto 0);
  signal SaidaULA : std_logic_vector(31 downto 0);
  signal verificador : std_logic;
  signal CONTROLEULA : std_logic_vector(3 downto 0);
  signal opcode : std_logic_vector(6 downto 0);
  signal DADODAMEMORIA : std_logic_vector(31 downto 0);

begin

  -- Conectando o sinal interno 'clk' ao sinal de entrada 'clock'
  clk <= clock;

  -- Port Maps
  XREGS1: XREGS port map (clk, EscreveReg, rs1, rs2, rd, DADO_ESCRITA_REG , ro1, ro2);
  gerador_imediatos1: gerador_imediatos port map (GerarImediato, imediato);
  mem_rv1: mem_rv port map (clk, EscreveMem, ENDERECO_MEMORIA, datain, dataout);
  ULA1: ULA port map (opcode_ULA, A, B, Z, cond);

  -- Processos e FSM
  process (clk)
  begin
    if rising_edge(clk) then
      case estado is
        when "0000" => -- Fetch
          -- Sinais de controle
          louD <= '0';
          OrigPC <= '0';
          EscrevePCB <= '1';
          EscreveMem <= '0';
          EscrevePC <= '1';
          LeMem <= '1';
          EscreveReg <= '0';
          CONTROLEULA <= "0000";
          OrigAULA <= "10";
          OrigBULA <= "01";
          EscrevePCCond <= '0';
          
          estado <= "0001"; -- Indo para o próximo estado

        when "0001" => -- Decodificação
          LeMem <= '0';
          EscrevePCB <= '0';
          EscrevePC <= '0';
          EscreveIR <= '1';
          EscreveReg <= '0';
          OrigAULA <= "01";
          OrigBULA <= "10";

          estado <= "0010";

        when "0010" => -- Execução
          EscreveIR <= '0';
          EscrevePCCond <= '0';
          EscrevePC <= '0';
          
          case opcode is
            when "0000011" => -- lw
              estado <= "0100";
            when others => 
              estado <= "0011";
          end case;

        when "0011" => -- Escrita no banco de registradores
          EscrevePCCond <= '0';
          EscrevePC <= '0';
          EscreveReg <= '1';
          Mem2Reg <= "00";
          estado <= "0000";

        when "0100" => -- Ler da memória
          louD <= '1';
          EscreveMem <= '0';
          LeMem <= '1';
          EscreveIR <= '0';
          estado <= "0011";        

        when others => 
          estado <= "0000";
      end case;            
    end if;
  end process;
 
  -- Processamento do PC
  process(EscrevePCCond, EscrevePC, clk)
  begin
    verificador <= EscrevePCCond and cond;

    if falling_edge(clk) then
      if (verificador or EscrevePC) = '1' then
        case OrigPC is
          when '0' => 
            CONTADOR_DE_PROGRAMA <= Z(11 downto 0);
          when '1' => 
            CONTADOR_DE_PROGRAMA <= SaidaULA(11 downto 0);
          when others =>
            CONTADOR_DE_PROGRAMA <= pc_back;
        end case;
      end if;
    end if;
  end process;

  -- Backup do PC
  process(EscrevePCB)
  begin
    if EscrevePCB = '1' then
      pc_back <= CONTADOR_DE_PROGRAMA;
    end if;
  end process;

  -- Controle de leitura de memória
  process(louD, LeMem)
  begin
    if LeMem = '1' then
      case louD is
        when '1' =>
          ENDERECO_MEMORIA <= std_logic_vector(unsigned(SaidaULA(11 downto 0)) / 4);
        when others =>
          ENDERECO_MEMORIA <= std_logic_vector(unsigned(CONTADOR_DE_PROGRAMA) / 4);
      end case;
    end if;
  end process;

  -- Operação da ULA
  process(ro1, ro2, CONTROLEULA, pc_back, imediato, EscrevePC)
  begin
    case OrigAULA is
      when "00" =>
        A <= std_logic_vector(resize(unsigned(pc_back), 32));
      when "01" =>
        A <= ro1;
      when "10" =>
        A <= std_logic_vector(resize(unsigned(CONTADOR_DE_PROGRAMA), 32));
      when others =>
        A <= (others => '0');
    end case;

    case OrigBULA is
      when "00" =>
        B <= ro2;
      when "01" =>
        B <= x"00000004";
      when "10" =>
        B <= imediato;
      when others =>
        B <= (others => '0');
    end case;

    opcode_ULA <= CONTROLEULA;
  end process;

  -- Registrador de instruções
  process(EscreveIR, dataout)
  begin
    if EscreveIR = '1' then
      funct3 <= dataout(14 downto 12);
      funct7 <= dataout(31 downto 25);
      rs1 <= dataout(19 downto 15);
      rs2 <= dataout(24 downto 20);
      rd <= dataout(11 downto 7);
      opcode <= dataout(6 downto 0);
      GerarImediato <= dataout;
    end if;
  end process;

  -- Banco de registradores
  process (EscreveReg)
  begin
    if EscreveReg = '1' then
      case Mem2Reg is
        when "00" =>
          DADO_ESCRITA_REG <= SaidaULA;
        when "01" =>
          DADO_ESCRITA_REG <= std_logic_vector(resize(unsigned(CONTADOR_DE_PROGRAMA), 32));
        when "10" =>
          DADO_ESCRITA_REG <= DADODAMEMORIA;
        when others =>
          null;
      end case;
    end if;
  end process;

  -- Registrador de dados
  process(clk)
  begin
    if rising_edge(clk) then
      DADODAMEMORIA <= dataout;
    end if;
  end process;

  -- Controle da ULA
  process(clk)
  begin
    case ALUOp is
      when "00" => -- Tipo I
        case funct3 is 
          when "010" => -- LW e SW
            CONTROLEULA <= "0000";
          when "000" =>
            CONTROLEULA <= "0000"; -- ADDI
          when "110" =>
            CONTROLEULA <= "0011"; -- ORI
          when "111" =>
            CONTROLEULA <= "0010"; -- ANDI
          when "100" =>
            CONTROLEULA <= "0100"; -- XORI
          when others =>
            CONTROLEULA <= "0000"; -- JAL, JALR, AUIPC
        end case;
      when "01" => -- Branch
        case funct3 is
          when "000" =>
            CONTROLEULA <= "0001"; -- BEQ
            --EscrevePCCond <= '1';
          when "001" =>
            CONTROLEULA <= "0001"; -- BNE
            --EscrevePCCond <= '1';
          when others =>
            null;
        end case;
      when "10" => -- Tipo R
        case funct7 is
          when "0000000" =>
            case funct3 is 
              when "000" =>
                CONTROLEULA <= "0000"; -- ADD
              when "010" =>
                CONTROLEULA <= "1000"; -- SLT
              when "100" =>
                CONTROLEULA <= "0100"; -- XOR
              when "110" => 
                CONTROLEULA <= "0011"; -- OR  
              when "111" =>
                CONTROLEULA <= "0010"; -- AND              
              when others =>
                null;
            end case;
          when "0100000" =>
            CONTROLEULA <= "0001"; -- SUB
          when others =>
            null;
        end case;
      when others =>
        null;
    end case;
  end process;

  -- WB (Write Back)
  process(SaidaULA, EscreveReg, Mem2Reg, EscreveMem)
  begin
    if EscreveReg = '1' then
      case Mem2Reg is
        when "00" =>
          DADO_ESCRITA_REG <= SaidaULA; 
        when "01" =>
          DADO_ESCRITA_REG <= std_logic_vector(resize(unsigned(CONTADOR_DE_PROGRAMA), 32));
        when "10" =>
          DADO_ESCRITA_REG <= DADODAMEMORIA;
        when others =>
          null;
      end case;
    end if;
  end process;

  -- Registrador de saída da ULA
  process(Z)
  begin
    SaidaULA <= Z;
  end process;

  -- Controle de fluxo baseado no opcode
  process(opcode, funct3, funct7)
  begin
    case opcode is
      when "0000011" => -- LW
        OrigAULA <= "01";
        OrigBULA <= "10";
        ALUOp <= "00";
      when "0100011" => -- SW
        OrigAULA <= "01";
        OrigBULA <= "10";
        ALUOp <= "00";
      when "0110011" => -- Tipo R
        case funct3 is 
          when "000" => -- ADD ou SUB
            case funct7 is
              when "0000000" => -- ADD
                OrigAULA <= "01";
                OrigBULA <= "00";
                ALUOp <= "10";
              when "0100000" => -- SUB
                OrigAULA <= "01";
                OrigBULA <= "00";
                ALUOp <= "10";
              when others =>
                null;
            end case;
          when "010" => -- SLT
            OrigAULA <= "01";
            OrigBULA <= "00";
            ALUOp <= "01";
          when "110" => -- OR
            OrigAULA <= "01";
            OrigBULA <= "00";
            ALUOp <= "10";
          when "111" => -- AND
            OrigAULA <= "01";
            OrigBULA <= "00";
            ALUOp <= "10";
          when "100" => -- XOR
            OrigAULA <= "01";
            OrigBULA <= "00";
            ALUOp <= "10";
          when others =>
            null;
        end case;                     
      when "0010011" => -- Tipo I
        case funct3 is
          when "000" => -- ADDI
            OrigAULA <= "01";
            OrigBULA <= "10";
            ALUOp <= "00";
          when "110" => -- ORI
            OrigAULA <= "01";
            OrigBULA <= "10";
            ALUOp <= "00";            
          when "111" => -- ANDI
            OrigAULA <= "01";
            OrigBULA <= "10";
            ALUOp <= "00";
          when "100" => -- XORI
            OrigAULA <= "01";
            OrigBULA <= "10";
            ALUOp <= "00";
          when others =>
            null;
        end case;
      when "1100011" => -- Branch (BEQ, BNE)
        case funct3 is
          when "000" => -- BEQ
            OrigAULA <= "01";
            OrigBULA <= "00";
            ALUOp <= "01";
          when "001" => -- BNE
            OrigAULA <= "01";
            OrigBULA <= "00";
            ALUOp <= "01";
          when others =>
            null;
        end case;
      when "1100111" => -- JALR
        OrigAULA <= "00";
        OrigBULA <= "10";
        ALUOp <= "00";    
      when "1101111" => -- JAL
        OrigAULA <= "00";
        OrigBULA <= "10";
        ALUOp <= "00";
      when "0110111" => -- LUI
        null;
      when "0010111" => -- AUIPC
        OrigAULA <= "00";
        OrigBULA <= "10";
        ALUOp <= "00";
      when others =>
        null;
    end case;
  end process;

end architecture;