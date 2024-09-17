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

  -- esse é o sinal de controle
  signal estado : std_logic_vector(3 downto 0) := "0000";

  -- esse é o sinal sera nosso pc 
  signal CONTADOR_DE_PROGRAMA: std_logic_vector(11 downto 0) := "000000000000"; 

  --pc back guarda o valor do pc para ser usado em um branch
  signal pc_back : std_logic_vector(11 downto 0);

  -- saida de dados da memeria de instrucoes 
  signal dataout : std_logic_vector(31 downto 0);

  -- Todos os sinais unitarios de controle 
  signal EscreveReg  , LeMem , EscreveMem , louD , EscreveIR , EscrevePC , EscrevePCCond , EscrevePCB ,OrigPC ,cond: std_logic;

  -- sinais de saida e entrada dos registradoes e das instrucioes 
  signal clk : std_logic;
  signal DADO_ESCRITA_REG, ro1, ro2, imediato, GerarImediato , datain , A, B, Z : std_logic_vector(31 downto 0);
  signal rs1 ,rs2  ,rd : std_logic_vector(4 downto 0); -- os registradores que vamos usar
  signal ENDERECO_MEMORIA : std_logic_vector(11 downto 0); -- é o signal que pertence a memoria de instrucoes
  signal opcode_ULA : std_logic_vector(3 downto 0); -- define a operacao da ula
  signal Mem2Reg: std_logic_vector(1 downto 0);
  signal OrigBULA , OrigAULA , ALUOp: std_logic_vector(1 downto 0);

  signal funct3 : std_logic_vector(2 downto 0) ;
  signal  funct7 : std_logic_vector(6 downto 0) ;

  -- guarda o valor da saida da ula 
  signal SaidaULA : std_logic_vector(31 downto 0);
  -- sinal usado no pc para verificar se ele vai ser escrito ou nao
  signal verificador : std_logic;

  -- sinal de controle para a ula
  signal CONTROLEULA : std_logic_vector(3 downto 0);

  --signal de opcode
  signal opcode : std_logic_vector(6 downto 0);

  -- sinal de valor da memoria
  signal DADODAMEMORIA : std_logic_vector(31 downto 0);

  -- controles internos do controlador
  signal CONTROLEINTERNO: std_logic_vector(3 downto 0) := "0000";
  

  
  
begin

-- Conectando o sinal interno 'clk' ao sinal de entrada 'clock'
  clk <= clock;

  -- todos os port maps
  XREGS1: XREGS port map (clk, EscreveReg, rs1, rs2, rd, DADO_ESCRITA_REG , ro1, ro2);

  gerador_imediatos1: gerador_imediatos port map (GerarImediato, imediato);

  mem_rv1: mem_rv port map (clk, EscreveMem, ENDERECO_MEMORIA , datain, dataout);

  ULA1: ULA port map (opcode_ULA, A, B, Z, cond);

  -- fim dos port maps

  process (clk)
  begin
    if rising_edge(clk) then
      case estado is
        when "0000" => --Fetch 
          --Sinais de controle
          LOUD <= '0';
          
          OrigAULA <= "10";
          OrigBULA <= "01";
	  CONTROLEULA <= "0000";
          OrigPC <= '0';
          EscrevePCCond <= '0';
          EscrevePCB <= '1';
          EscreveMem <= '0';
          EscrevePC <= '1';
          LeMem <= '1';
          EscreveReg <= '0';
          
          estado <= "0001"; -- indo para o proximo estado

        when "0001" => -- decodificação

          LeMem <= '0'; -- é importante para que possa ler a memoria corretamente
          EscrevePCB <= '0'; -- deliga pc_back 
          EscrevePC <= '0'; -- é importante para que nao haja escrita na hora errada
          EscreveIR <= '1'; -- é importante para que possa escrever a instrucao
          EscreveReg <= '0';
          OrigAULA <= "01";
          OrigBULA <= "10";

          estado <= "0010";
        when "0010" => -- execução
          EscreveIR <= '0';
          EscrevePCCond <= '0';
          EscrevePC <= '0'; 
          
          -- precisamos ver qual é a operacao que vamos fazer
          case opcode is
            when "0000011" => -- lw onde ele vai pegar da memoria e escrever no banco de registradores
                estado <= "0100";
            when others => 
              estado <= "0011";
          end case;

        when "0011" => -- escrita no banco de registradores -- estado pronto

          EscrevePCCond <= '0';
          EscrevePC <= '0';
          EscreveReg <= '1';
          Mem2Reg <= "00";
          estado <= "0000";

        when "0100" => -- ler da memoria
            louD <= '1';
            EscreveMem <= '0';
            LeMem <= '1';
            EscreveIR <= '0';
            estado <= "0011" ;        
        when others => -- estado de inicio , estado de building
          estado <= "0000";
      end case;            
    end if;
  end process;
 
  -- Modulo pc 
  process(ESCREVEPCCOND, ESCREVEPC, clk)
  begin
    verificador <= ESCREVEPCCOND and cond ;

    if  falling_edge(clk) then
      if (verificador or ESCREVEPC) = '1' then
        case OrigPC is
          when '0' => 
            CONTADOR_DE_PROGRAMA <=  Z(11 downto 0);
          when '1' => 
            CONTADOR_DE_PROGRAMA <= SaidaULA(11 downto 0);
          when others =>
            CONTADOR_DE_PROGRAMA <= pc_back;
        end case;
      end if;
    end if;
  end process;

  --pc back
  process(ESCREVEPCB)
  begin
    if ESCREVEPCB = '1' then
      pc_back <= CONTADOR_DE_PROGRAMA;
    end if;
  end process;

  -- Memoria dados e instrucoes
  process(LOUD , LeMem)
  begin
    if LeMem = '1' then
      case LOUD is
        when '1' =>
	   --ENDERECO_MEMORIA <= (SaidaULA(11 downto 0) / 4);
	   ENDERECO_MEMORIA <= std_logic_vector(unsigned(SaidaULA(11 downto 0)) / 4);
        when others =>
          --ENDERECO_MEMORIA <= (CONTADOR_DE_PROGRAMA / 4);
	  ENDERECO_MEMORIA <= std_logic_vector(unsigned(CONTADOR_DE_PROGRAMA) / 4);
      end case;
    end if;
  end process;

  -- funcionamento da ula
  process (ro1 , ro2 , CONTROLEULA , pc_back , imediato ,ESCREVEPC)
  begin
    -- Entra A ULA
    case OrigAULA is
      when "00" =>
        A <= std_logic_vector(resize(unsigned(pc_back),32));--resize
      when "01" =>
        A <= ro1;
      when "10" =>
        A <= std_logic_vector(resize(unsigned(CONTADOR_DE_PROGRAMA) ,32));
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

  end process ;
  --funcionamento banco de registradores
  
  -- process registrdor de instrucoes
  process(ESCREVEIR , dataout)
  begin
    if ESCREVEIR = '1' then
      funct3 <= dataout(14 downto 12);
      funct7 <= dataout(31 downto 25);
      rs1 <= dataout(19 downto 15);
      rs2 <= dataout(24 downto 20);
      rd <= dataout(11 downto 7);
      opcode <= dataout(6 downto 0);
      GerarImediato <= dataout;
    end if;
  end process;

  -- banco de registradores
  process (EscreveReg)
  begin
    if EscreveReg = '1' then
      case Mem2Reg is
        when "00" =>
          DADO_ESCRITA_REG <= SaidaULA;
        when "01" =>
          DADO_ESCRITA_REG <= std_logic_vector(resize(unsigned(CONTADOR_DE_PROGRAMA),32));
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

  -- controle da ula
  process(clk)
  begin
    case ALUOp is
      when "00" => -- tipo i
        case funct3 is 
          when "010" => -- lw e sw
            CONTROLEULA <= "0000";
          when "000" =>
            CONTROLEULA <= "0000"; --addi
          when "110" =>
            CONTROLEULA <= "0011"; --ori
          when "111" =>
            CONTROLEULA <= "0010"; --andi
          when "100" =>
            CONTROLEULA <= "0100"; --xori 
          when others => --jal jalr auipc
            CONTROLEULA <= "0000";
        end case;
      when "01" => -- branch
        case funct3 is
          when "000" =>
            CONTROLEULA <= "0001"; -- beq
            EscrevePCCond <= '1';
          when "001" =>
            CONTROLEULA <= "0001"; --bne
            EscrevePCCond <= '1';
          when others =>
            null;
        end case;
      when "10" => -- r
        case funct7 is
          when "0000000" =>
            case funct3 is 
              when "000" =>
                CONTROLEULA <= "0000"; --add
              when "010" =>
                CONTROLEULA <= "1000"; --slt
              when "100" =>
                CONTROLEULA <= "0100"; --xor
              when "110" => 
                CONTROLEULA <= "0011"; --or  
              when "111" =>
                CONTROLEULA <= "0010"; --and              
              when others =>
                null;
            end case;
          when "0100000" =>
            CONTROLEULA <= "0001"; --sub
          when others =>
            null;
        end case;
      when others =>
        null;
    end case;
  end process;

  -- wb
  process(SaidaULA,EscreveReg , Mem2Reg ,EscreveMem)
  begin
    if EscreveReg = '1' then
      case Mem2Reg is
        when "00" =>
          DADO_ESCRITA_REG <= SaidaULA; 
        when "01" =>
          DADO_ESCRITA_REG <= std_logic_vector(resize(unsigned(CONTADOR_DE_PROGRAMA),32));
        when "10" =>
          DADO_ESCRITA_REG <= DADODAMEMORIA;
        when others =>
          null;
      end case;
    end if;
  end process;

  --registrador saida da ula
  process(Z)
  begin
    SaidaULA <= Z;
  end process;


end architecture ;