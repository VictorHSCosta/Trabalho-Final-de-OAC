library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity ent is
  port (
  	clock : in std_logic
  ) ;
end ent ; 

architecture arch of ent is
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

  component PC is
    port (
      clock : in std_logic;
      we : in std_logic;
      datain : in std_logic_vector(11 downto 0);
      dataout : out std_logic_vector(11 downto 0)
    ) ;
  end component;

  component ALUControl is
    Port (
        ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
        funct3 : in STD_LOGIC_VECTOR(2 downto 0);
        funct7 : in STD_LOGIC_VECTOR(6 downto 0);
        ALUControlOut : out STD_LOGIC_VECTOR(3 downto 0)
    );
  end component;

  -- esse é o sinal de controle
  signal estado : std_logic_vector(3 downto 0) := "0000";
  
  -- essa vai ser a memoria que vamos manipular 
  signal memoria: std_logic_vector(31 downto 0) := (others => '0');

  -- esse é o sinal sera nosso pc 
  signal CONTADOR_DE_PROGRAMA: std_logic_vector(11 downto 0) := "000000000000"; 

  -- esse é o sinal da saida do pc 
  signal dataoutPC : std_logic_vector(11 downto 0) := "000000000000";

  --pc back guarda o valor do pc para ser usado em um branch
  signal pc_back : std_logic_vector(11 downto 0) := "000000000000";

  -- saida de dados da memeria de instrucoes 
  signal dataout : std_logic_vector(31 downto 0) := x"00000000";

  -- Todos os sinais unitarios de controle 
  signal clk, EscreveReg  , LeMem , EscreveMem , louD , EscreveIR , EscrevePC , EscrevePCCond , EscrevePCB ,OrigPC ,cond , EscritaNoPcAuxiliar: std_logic := '0';

  -- sinais de saida e entrada dos registradoes e das instrucioes 
  signal data, ro1, ro2, imediato, instrucao, datain , A, B, Z : std_logic_vector(31 downto 0) := x"00000000";
  signal rs1 ,rs2  ,rd : std_logic_vector(4 downto 0) := "00000";
  signal address : std_logic_vector(11 downto 0) := "000000000000";
  signal opcode_ULA : std_logic_vector(3 downto 0) := "0000"; 
  signal OpALU , Mem2Reg: std_logic_vector(1 downto 0) := "00";
  signal OrigBULA , OrigAULA , ALUOp: std_logic_vector(1 downto 0) := "00";
  signal ALUOp_CONTROLE : std_logic_vector(1 downto 0) := "00";
  signal funct3 : std_logic_vector(2 downto 0) := "000";
  signal  funct7 : std_logic_vector(6 downto 0) := "0000000";
  signal ALUControlOut : std_logic_vector(3 downto 0) := "0000";

  -- guarda o valor da saida da ula 
  signal SAIDA_ULA : std_logic_vector(31 downto 0) := x"00000000";

begin

-- Conectando o sinal interno 'clk' ao sinal de entrada 'clock'
  clk <= clock;

  -- todos os port maps
  XREGS1: XREGS port map (clk, EscreveReg, rs1, rs2, rd, data, ro1, ro2);

  gerador_imediatos1: gerador_imediatos port map (instrucao, imediato);

  mem_rv1: mem_rv port map (clk, EscreveMem, address, datain, dataout);

  ULA1: ULA port map (opcode_ULA, A, B, Z, cond);

  ALUControl1: ALUControl port map (ALUOp_CONTROLE, funct3, funct7, ALUControlOut);
  -- fim dos port maps
  
  process (clk)
  begin
    if rising_edge(clk) then
      case estado is
        when "0000" => --Fetch 
          louD <= '0';
          LeMem <= '1';
          EscreveIR <= '1';
          OrigAULA <= "10";
          OrigBULA <= "01";
          ALUOp <= "00";
          OrigPC <= '0';
          EscrevePC <= '1';
          EscrevePCB <= '0';
          EscreveMem <= '0';
          -- começando a fazer as operaçoes

          EscritaNoPcAuxiliar <= (EscrevePC or EscrevePCB);
          EscreveIR <= EscritaNoPcAuxiliar;
          address <= CONTADOR_DE_PROGRAMA;

          -- agora que temos o novo valor do pc podemos escrever esse valor no pc
          pc_back <= CONTADOR_DE_PROGRAMA;
        
          -- aqui nos temos ja a memoria lida agora podemos fazer a soma do pc + 4
          -- para fazer a soma sem nenhuma erro podemos manualmente pelo controle 

          -- vamos definir o valor da entrada do controle da ula 

          funct3 <= "000";
          funct7 <= "0000000";
          ALUOp_CONTROLE <= ALUOp;

          -- com todos os parametros definidos podemos fazer a soma do pc + 4

          opcode_ULA <=  ALUControlOut;
          A <= ((31 downto 12 => '0') & CONTADOR_DE_PROGRAMA);  -- Extensão com zeros para 32 bits
          B <= x"00000004";  -- Representação hexadecimal de 4 em 32 bits
          -- aqui temos o valor do pc + 4

          if EscritaNoPcAuxiliar = '1' then
            CONTADOR_DE_PROGRAMA <= Z(11 downto 0); 
          end if;

          -- no hardware real nessa etapa os sinais eletricos ja estariam na entrada do banco de registradores e so iam ser carregadas no proximo clock
          rs1 <= dataout(19 downto 15);
          rs2 <= dataout(24 downto 20);
          rd <= dataout(11 downto 7);
          funct3 <= dataout(14 downto 12);
          funct7 <= dataout(31 downto 25);

          estado <= "0001"; -- agora vamos para o proximo estado
          
        when "0001" =>

          OrigAULA <= "00";
          OrigBULA <= "11";
          ALUOp <= "00";

          -- nessa primeira etapa vamos separar a instrucao em opcode e os registradores 


          -- agora vamos fazer a extensao de sinal do imediato

          instrucao <= dataout;

          -- nessa fase nos ja temos os valores dos registradores em ro1 e ro2 e tambem ja temos o imediato

          -- agora vamos descobrir para qual estado vamos ir

          case dataout(6 downto 0) is 
            when "0000011" => -- load
              estado <= "0010";
            when "0100011" => -- store
              estado <= "0010";
            when "1100011" => -- beq, bne, blt, bge, bltu, bgeu
              estado <= "1000";
            when "0110011" => -- r-type
              estado <= "0110";
            when "1101111" => -- jal
              estado <= "1000";
            when "0010011"=> -- addi 
              OrigBULA <= "11"; -- define para 3 para que a ula pegue o imediato
              estado <= "1010";
            when others =>
              estado <= "0000";
          end case;

        when "0010" =>
          OrigAULA <= "01";
          OrigBULA <= "10";
          ALUOp <= "00";
        when "0011" =>
          LouD <= '1';
          LeMem <= '0';
        when "0100" =>
          Mem2Reg <= "10";
          EscreveReg <= '1';
        when "0101" => 
          louD <= '1';
          EscreveMem <= '1';


        when "0110" =>
          OrigAULA <= "01";
          OrigBULA <= "00";
          ALUOp <= "01";
          OrigPC <= '1';
          EscrevePCCond <= '0'; 
        when "0111" => -- guarda o valor da ula no banco de registradores
          Mem2Reg <= "00"; 
          EscreveReg <= '1';

          rd <= dataout(11 downto 7);
          data <= SAIDA_ULA;

          -- agora que ja guardamos o valor da ula no banco de registradores podemos ir para o proximo estado
          -- totalizando 4 ciclos de clock

          EscreveReg <= '1';

          estado <= "0000";
        when "1000" => 
          OrigAULA <= "01";
          OrigBULA <= "00";
          ALUOp <= "01";
          OrigPC <= '1';
          EscrevePCCond <= '1';
        when "1001" =>
          null;
        when "1010" => -- addi 
          opcode_ULA <= "0000";
          A <= ro1;
          B <= imediato;

          SAIDA_ULA <= Z;

          -- agora precisamos guradar esse valor basta entao chamar  o estado 0101

          estado <= "0111";
        
        when others =>
          null;
      end case;            
    end if;
  end process;


end architecture ;