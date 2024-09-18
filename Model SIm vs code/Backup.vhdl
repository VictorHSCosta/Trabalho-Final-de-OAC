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
  signal DADO_ESCRITA_REG, ro1, ro2, imediato, GerarImediato, DADOENTRADA, A, B, Z : std_logic_vector(31 downto 0);
  signal rs1, rs2, rd : std_logic_vector(4 downto 0);
  signal ENDERECO_MEMORIA : std_logic_vector(11 downto 0);
  signal Mem2Reg : std_logic_vector(1 downto 0);
  signal OrigAULA : std_logic_vector(1 downto 0);
  signal OrigBULA : std_logic_vector(1 downto 0);
  signal funct3 : std_logic_vector(2 downto 0);
  signal funct7 : std_logic_vector(6 downto 0);
  signal SaidaULA : std_logic_vector(31 downto 0);
  signal verificador : std_logic;
  signal CONTROLEULA : std_logic_vector(3 downto 0);
  signal opcode : std_logic_vector(6 downto 0);
  signal DADODAMEMORIA : std_logic_vector(31 downto 0);

  --signal de uma variavel temporaria para armazenar o endereco da memoria
  signal ENDERECO_TEMP : std_logic_vector(31 downto 0);


begin

  -- Conectando o sinal interno 'clk' ao sinal de entrada 'clock'
  clk <= clock;

  -- Port Maps
  XREGS1: XREGS port map (clk, EscreveReg, rs1, rs2, rd, DADO_ESCRITA_REG , ro1, ro2);
  gerador_imediatos1: gerador_imediatos port map (GerarImediato, imediato);
  mem_rv1: mem_rv port map (clk, EscreveMem, ENDERECO_MEMORIA, DADOENTRADA, dataout);
  ULA1: ULA port map (CONTROLEULA, A, B, Z, cond);

  -- Processos e FSM
  process (clk)
  begin
    if rising_edge(clk) then
      case estado is
        when "0000" => -- Fetch

          estado <= "0001"; -- Indo para o próximo estado

        when "0001" => -- Decodificação
             
          estado <= "0010";

        when "0010" => -- Execução

          case opcode is
            when "0000011" => -- lw
              louD <= '1';
              estado <= "0100";
            when "1100011" => -- bne ou beq
                Loud <= '0';
                estado <= "0000";
            when others => 
              estado <= "0011";
          end case;

        when "0011" => -- Escrita no banco de registradores

          case opcode is
            when "0000011" => -- lw
              Mem2Reg <= "10";
            when "1101111" => -- JAL
              OrigPC <= '1';
              Mem2Reg <= "01";
              ESCREVEPC <= '1';
            when "1100111" => -- JALR
              OrigPC <= '1';
              Mem2Reg <= "01";
              ESCREVEPC <= '1';
            when others => 
              Mem2Reg <= "00";
          end case;

          estado <= "0000";

        when "0100" => -- Ler da memória

          EscreveIR <= '0';

          if opcode = "0100011" then
            estado <= "0000";
          else 
            estado <= "0011";
          end if;    

        when others => 
          estado <= "0000";
      end case;            
    end if;

    -- CONTROLE DE SINAIS 
    case estado is 
      when "0000" => 
        -- Sinais de controle
        louD <= '0'; -- fecth
        OrigAULA <= "10";
        OrigBULA <= "01";
        OrigPC <= '0';
        EscrevePCB <= '1';
        EscreveMem <= '0';
        EscrevePC <= '1';
        LeMem <= '1';
        EscreveReg <= '0';
        CONTROLEULA <= "0000";
        EscrevePCCond <= '0';
      when "0001" =>  -- decoder
        LeMem <= '0';
        EscrevePCB <= '0';
        EscrevePC <= '0';
        EscreveIR <= '1';
        EscreveReg <= '0';

        if dataout(6 downto 0) = "1100011" then
          OrigAULA <= "00";
          OrigBULA <= "10";
          CONTROLEULA <= "0000";
        end if;
      when "0010" => -- execulte
        
          case dataout(6 downto 0) is   
            when "0000011" => -- LW
            OrigAULA <= "01";
            OrigBULA <= "10";
            CONTROLEULA <= "0000";
          when "0100011" => -- SW
            OrigAULA <= "01";
            OrigBULA <= "10";
            CONTROLEULA <= "0000";
            Loud <= '1';
          when "0110011" => -- Tipo R
            case dataout(14 downto 12) is 
              when "000" => -- ADD ou SUB
                case dataout(31 downto 25) is
                  when "0000000" => -- ADD
                    OrigAULA <= "01";
                    OrigBULA <= "00";
                    CONTROLEULA <= "0000";
                  when "0100000" => -- SUB
                    OrigAULA <= "01";
                    OrigBULA <= "00";
                    CONTROLEULA <= "0001";
                  when others =>
                    null;
                end case;
              when "010" => -- SLT
                OrigAULA <= "01";
                OrigBULA <= "00";
                CONTROLEULA <= "1000";
              when "110" => -- OR
                OrigAULA <= "01";
                OrigBULA <= "00";
                CONTROLEULA <= "0011"; 
              when "111" => -- AND
                OrigAULA <= "01";
                OrigBULA <= "00";
                CONTROLEULA <= "0010";
              when "100" => -- XOR
                OrigAULA <= "01";
                OrigBULA <= "00";
                CONTROLEULA <= "0100";
              when others =>
                null;
            end case;                     
          when "0010011" => -- Tipo I
            case dataout(14 downto 12) is
              when "000" => -- ADDI
                OrigAULA <= "01";
                OrigBULA <= "10";
                CONTROLEULA <= "0000";
              when "110" => -- ORI
                OrigAULA <= "01";
                OrigBULA <= "10";
                CONTROLEULA <= "0011";            
              when "111" => -- ANDI
                OrigAULA <= "01";
                OrigBULA <= "10";
                CONTROLEULA <= "0010"; 
              when "100" => -- XORI
                OrigAULA <= "01";
                OrigBULA <= "10";
                CONTROLEULA <= "0100"; 
              when others =>
                null;
            end case;
          when "1100011" => -- Branch (BEQ, BNE)
            case dataout(14 downto 12) is
              when "000" => -- BEQ
                OrigAULA <= "01";
                OrigBULA <= "00";
                CONTROLEULA <= "1100";
                EscrevePCCond <= '1';
                OrigPC <= '1';
              when "001" => -- BNE
                OrigAULA <= "01";
                OrigBULA <= "00";
                CONTROLEULA <= "1101";
                EscrevePCCond <= '1';
                OrigPC <= '1';
              when others =>
                null;
            end case;
          when "1100111" => -- JALR
            OrigAULA <= "01";
            OrigBULA <= "10";
            CONTROLEULA <= "0000";   
          when "1101111" => -- JAL
            OrigAULA <= "00";
            OrigBULA <= "10"; 
            CONTROLEULA <= "0000";
          when "0110111" => -- LUI
            OrigAULA <= "11";
            OrigBULA <= "10";
            CONTROLEULA <= "0000";
          when "0010111" => -- AUIPC
            OrigAULA <= "00";
            OrigBULA <= "10";
            CONTROLEULA <= "0000";
          when others =>
            null;
        end case;

        EscreveIR <= '0';
      when "0011" => -- Write Back
        LeMem <= '0';
            
        EscrevePC <= '0';
        EscrevePCCond <= '0';
        EscrevePC <= '0';
        EscreveReg <= '1';
      when "0100" =>  -- Leitura da memória

        EscreveIR <= '0';

        if opcode = "0100011" then
          LeMem <= '0';
          EscreveMem <= '1';
          DADOENTRADA <= ro2;
        else 
          LeMem <= '1';
        end if;   
      when others => 
        EscreveIR <= '0';
        EscrevePCB <= '0';
        EscrevePC <= '0';
        EscreveReg <= '0';
        LeMem <= '0';
        EscreveMem <= '0';
        louD <= '0';
        OrigPC <= '0';
        cond <= '0';
    end case;
  end process;
 
  -- Processamento do PC
  process(EscrevePCCond, EscrevePC, clk , OrigPC, cond)
  begin
    verificador <= EscrevePCCond and cond;

    if rising_edge(clk) then
      if (verificador or EscrevePC) = '1' then
        case OrigPC is
          when '0' => 
            CONTADOR_DE_PROGRAMA <= Z(11 downto 0);
          when '1' => 
            CONTADOR_DE_PROGRAMA <= SaidaULA(11 downto 0);
          when others =>
            null;
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
          ENDERECO_MEMORIA <= ENDERECO_TEMP(11 downto 0);
        when others =>
          ENDERECO_MEMORIA <= std_logic_vector(unsigned(CONTADOR_DE_PROGRAMA) / 4);
      end case;
    else 
      if EscreveMem = '1' then
        ENDERECO_MEMORIA <= std_logic_vector(unsigned(CONTADOR_DE_PROGRAMA) / 4);
      end if;
    end if;
  end process;

  -- Operação da ULA
  process(ro1, ro2, CONTROLEULA, pc_back, imediato, EscrevePC ,clk)
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

    --opcode_ULA <= CONTROLEULA;
  end process;

  -- Registrador de instruções
  process(dataout)
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

  -- Registrador de dados
  process(dataout, clk)
  begin
      DADODAMEMORIA <= dataout;
  end process;
 
  -- WB (Write Back)
  process(SaidaULA, EscreveReg, Mem2Reg, EscreveMem , dataout)
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
  process(estado)
  begin
    SaidaULA <= Z;
  end process;

  -- registrador de endereços secundarios 
  process(Z)
  begin
    ENDERECO_TEMP <= std_logic_vector(unsigned(Z) / 4);
  end process;
 

end architecture;