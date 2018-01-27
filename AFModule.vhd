library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_signed.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY   AFModule IS
	PORT(
	Clk,Reset						  : IN STD_LOGIC;
	
	-- From and to CPU
	Start_FromCPU					  : IN STD_LOGIC  ;
	FocusAdress_FromCPU				  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	DONE_ToCPU 						  : OUT STD_LOGIC;

	-- From and to DMA 
	DMA_ACK_FromDMA                   : IN STD_LOGIC;
	DMA_EN_ToDMA                      : OUT STD_LOGIC;
	 
	FocusAdress_ToDMA				  : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);

	-- From and to Cache 
	Cache_Data_FromCache			  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
 	Cache_Address_FromAF			  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	Cache_RD_EN_ToCache				  : OUT STD_LOGIC;
	 
	-- From and to Mechanical Part 
	MOV_LEN_ToMechPart,DIR_ToMechPart : OUT STD_LOGIC

	);
END AFModule;

ARCHITECTURE AFModule_Arch OF AFModule IS 

	COMPONENT GenDataPath is
		Port (   Cache_Data   : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			RAE,RBE,WE,OE   : IN STD_LOGIC;
			IE              : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			RAA ,RBA ,WA : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			ALU_OP       : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			DP_Out       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			DPCLK,RESET          : IN STD_LOGIC;
					   X0   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   X1   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   X2   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   X3   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   X4   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   X5   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   X6   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   X7   : INOUT STD_LOGIC_VECTOR (15 downto 0));
	END COMPONENT;
 
	COMPONENT REG_MOD IS
	PORT( Clk,Rst,Load : IN std_logic;
	ADD16,DEC  : IN STD_LOGIC;
		  d : IN  std_logic_vector(11 DOWNTO 0);
		  Cin : IN STD_LOGIC ;
		  q : OUT std_logic_vector(11 DOWNTO 0);
		  CF_Out,ZF_Out : OUT STD_LOGIC);
	END COMPONENT REG_MOD;
	
	COMPONENT REG8 IS
		PORT( Clk,Rst,Load : IN std_logic;
		  INC,DEC  : IN STD_LOGIC;
		  d : IN  std_logic_vector(7 DOWNTO 0);
		  Cin : IN STD_LOGIC ;
		  q : OUT std_logic_vector(7 DOWNTO 0);
		  CF_Out,ZF_Out : OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT REG4 IS
		PORT( Clk,Rst,Load : IN std_logic;
		  INC,DEC  : IN STD_LOGIC;
		  d : IN  std_logic_vector(3 DOWNTO 0);
		  Cin : IN STD_LOGIC ;
		  q : OUT std_logic_vector(3 DOWNTO 0);
		  CF_Out,ZF_Out : OUT STD_LOGIC);
	END COMPONENT;

 
	COMPONENT AFControlUnit IS 
		PORT(	
		TimeAF                : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --AF_SC Output
		Start,Reset ,DMA_Ack,Clk   : IN STD_LOGIC;                    --Whether it is reset or started
		FSM1_FIN,FSM2_FIN,FSM3_FIN : IN STD_LOGIC;
		FSM2_CHDIR                 : IN STD_LOGIC;
	
		DMA_EN ,MOV_LEN,DIR,DONE                 : OUT STD_LOGIC;
		AFSC_INC,AFSC_CLR                       : OUT STD_LOGIC;
		AFAR_INC,AFAR_CLR,AFAR_LD,AFAR_OE       : OUT STD_LOGIC; -- Needed for DMA 
		CacheAR_INC,CacheAR_CLR                 : OUT STD_LOGIC; -- Needed for cache as address  
		FSM1_EN,FSM2_EN,FSM3_EN                 : OUT STD_LOGIC );
	END COMPONENT;

	COMPONENT FSM1 IS 
		PORT(
			FSM1_EN                     : IN STD_LOGIC;
			RESET,CLK                   : IN STD_LOGIC;
			X,Y                         : IN STD_LOGIC;
		 
			Cache_RD,CacheAR_INC        : OUT STD_LOGIC;
		 
			RAE,RBE,WE,OE   : OUT STD_LOGIC;
			IE              : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			RAA ,RBA ,WA    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			ALU_OP          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			FSM1_FIN        : OUT STD_LOGIC
		 
			);	
	END  COMPONENT;
	
	COMPONENT FSM2 IS 
		PORT(
			FSM2_EN                     : IN STD_LOGIC;
			RESET,CLK                   : IN STD_LOGIC;
			X,Y,CF                    : IN STD_LOGIC;
		 
			Cache_RD,CacheAR_INC        : OUT STD_LOGIC;
		 
			RAE,RBE,WE,OE   : OUT STD_LOGIC;
			IE              : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			RAA ,RBA ,WA    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			ALU_OP          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			FSM2_FIN,FSM2_CHDIR        : OUT STD_LOGIC
		 
		);	
	END  COMPONENT;
	
	COMPONENT FSM3 IS 
		PORT(
			FSM3_EN                     : IN STD_LOGIC;
			RESET,CLK                   : IN STD_LOGIC;
			X,Y,CF                    : IN STD_LOGIC;
		 
			Cache_RD,CacheAR_INC        : OUT STD_LOGIC;
		 
			RAE,RBE,WE,OE   : OUT STD_LOGIC;
			IE              : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			RAA ,RBA ,WA    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			ALU_OP          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			FSM3_FIN        : OUT STD_LOGIC;
			MOV_LEN         : OUT STD_LOGIC
		);	
	END  COMPONENT;

	SIGNAL CF1,ZF1    : STD_LOGIC;
	SIGNAL AFCU_Time  : STD_LOGIC_VECTOR(3 DOWNTO 0);
 	SIGNAL FSM1_EN_SIG,FSM2_EN_SIG,FSM3_EN_SIG 					 : 	STD_LOGIC;
	SIGNAL FSM1_EN_SIGO,FSM2_EN_SIGO,FSM3_EN_SIGO : STD_LOGIC;
	
	SIGNAL FSM1_FIN_SIG,FSM2_FIN_SIG,FSM3_FIN_SIG,FSM2_CHDIR_SIG : 	STD_LOGIC;
	--Control Signals for all registers 
	SIGNAL 	AFSC_INC_SIG,AFSC_CLR_SIG,
		 	AFAR_INC_SIG,AFAR_CLR_SIG,AFAR_LD_SIG,AFAR_OE_SIG,
		 	CacheAR_INC_SIG,CacheAR_CLR_SIG,CacheAR_CLR_SIGo : STD_LOGIC;
		SIGNAL	CacheAR_INC_SIGo,CacheAR_INC_SIG1,CacheAR_INC_SIG2,CacheAR_INC_SIG3: STD_LOGIC;
	--Control Signals for the generalized datapath
	SIGNAL  RAE_SIG1,RBE_SIG1,WE_SIG1,OE_SIG1:STD_LOGIC;
	SIGNAL  RAE_SIG2,RBE_SIG2,WE_SIG2,OE_SIG2:STD_LOGIC;
	SIGNAL  RAE_SIG3,RBE_SIG3,WE_SIG3,OE_SIG3:STD_LOGIC;
	SIGNAL  RAE_SIG4,RBE_SIG4,WE_SIG4,OE_SIG4:STD_LOGIC;
	
	SIGNAL  IE_SIG1  :STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  IE_SIG2  :STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  IE_SIG3  :STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  IE_SIG4  :STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	
	
	SIGNAL  RAA_SIG1,RBA_SIG1,WA_SIG1,ALU_OP_SIG1 :STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL  RAA_SIG2,RBA_SIG2,WA_SIG2,ALU_OP_SIG2 :STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL  RAA_SIG3,RBA_SIG3,WA_SIG3,ALU_OP_SIG3 :STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL  RAA_SIG4,RBA_SIG4,WA_SIG4,ALU_OP_SIG4 :STD_LOGIC_VECTOR(2 DOWNTO 0);
	
	
	
	
	SIGNAL  DP_OUT_SIG : STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL   X_SIG,Y_SIG,CF_SIG : STD_LOGIC; --Are being Set via process in the architecture 
	SIGNAL  DMA_EN_SET   : STD_LOGIC ;
	SIGNAL   Cache_Data_Extended : STD_LOGIC_VECTOR(15 DOWNTO 0);
 		SIGNAL   R0   :   STD_LOGIC_VECTOR (15 downto 0);
		SIGNAL   R1   :   STD_LOGIC_VECTOR (15 downto 0);
		SIGNAL   R2   :   STD_LOGIC_VECTOR (15 downto 0);
		SIGNAL   R3   :   STD_LOGIC_VECTOR (15 downto 0);
		SIGNAL   R4   :   STD_LOGIC_VECTOR (15 downto 0);
		SIGNAL   R5   :   STD_LOGIC_VECTOR (15 downto 0);
		SIGNAL   R6   :   STD_LOGIC_VECTOR (15 downto 0);
		SIGNAL   R7   :   STD_LOGIC_VECTOR (15 downto 0);
    SIGNAL   TEMP : STD_LOGIC;
	
BEGIN 

--///////////////////////////////////////////////////////////////
-- (1) Hardware port map of all registers 
--AF Address Register store address of focus matrix from CPU to be sent to DMA
AFAR         : REG_MOD  PORT MAP(Clk,Reset,AFAR_LD_SIG,AFAR_INC_SIG,'0',FocusAdress_FromCPU,'0',FocusAdress_ToDMA,CF1,ZF1 ); -- 16 bit register [Huge address space of NVM]
AFSC         : REG4 PORT MAP(Clk,Reset,AFSC_CLR_SIG,AFSC_INC_SIG,'0',"0000",'0',AFCU_Time,CF1,ZF1); -- 4  bit register counter for control unit of AF 
--Cache Address Register keep track of addresses being sent to Cache starting from location zero to 255
CacheAR      : REG8 PORT MAP(Clk,Reset,CacheAR_CLR_SIG,CacheAR_INC_SIG,'0',"00000000",'0', Cache_Address_FromAF,CF1,ZF1 ); -- 8 bit register  [256 address space of Cache]
 CacheAR_CLR_SIG <= '0' WHEN   FSM1_EN_SIGO='1'
 ELSE   '0' WHEN FSM2_EN_SIGO='1'
				 ELSE  '0' WHEN FSM3_EN_SIGO='1'
				 else CacheAR_CLR_SIG;
				 
 CacheAR_INC_SIG <= CacheAR_INC_SIG1 WHEN   FSM1_EN_SIGO='1'
                 ELSE  CacheAR_INC_SIG2 WHEN FSM2_EN_SIGO='1'
				 ELSE  CacheAR_INC_SIG3 WHEN FSM3_EN_SIGO='1'
				 else CacheAR_INC_SIGo;
 -- In CacheAR and AFSC if Clear is activated it will load zeros
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


--///////////////////////////////////////////////////////////////
-- (2) Hardware port map of generalized datapath 		  
Cache_Data_Extended <= "00000000"&Cache_Data_FromCache;

RAE_SIG4 <= RAE_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  RAE_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  RAE_SIG3 WHEN FSM3_EN_SIGO = '1';
 
RBE_SIG4 <= RBE_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  RBE_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  RBE_SIG3 WHEN FSM3_EN_SIGO = '1';

 WE_SIG4 <= WE_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  WE_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  WE_SIG3 WHEN FSM3_EN_SIGO = '1';

 OE_SIG4 <= OE_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  OE_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  OE_SIG3 WHEN FSM3_EN_SIGO = '1';

 IE_SIG4 <= IE_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  IE_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  IE_SIG3 WHEN FSM3_EN_SIGO = '1';

  RAA_SIG4 <= RAA_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  RAA_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  RAA_SIG3 WHEN FSM3_EN_SIGO = '1';

  RBA_SIG4 <= RBA_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  RBA_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  RBA_SIG3 WHEN FSM3_EN_SIGO = '1';

  WA_SIG4 <= WA_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  WA_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  WA_SIG3 WHEN FSM3_EN_SIGO = '1';

  ALU_OP_SIG4 <= ALU_OP_SIG1 WHEN FSM1_EN_SIGO = '1' 
 ELSE  ALU_OP_SIG2 WHEN FSM2_EN_SIGO = '1' 
 ELSE  ALU_OP_SIG3 WHEN FSM3_EN_SIGO = '1';

 
GenDataPath1 : GenDataPath PORT MAP ( Cache_Data_Extended,
				      RAE_SIG4,RBE_SIG4,WE_SIG4,OE_SIG4,
	       			      IE_SIG4,
				      RAA_SIG4,RBA_SIG4,WA_SIG4,
				      ALU_OP_SIG4,
				      DP_OUT_SIG,
				      Clk,Reset,
				      R0,R1,R2,R3,R4,R5,R6,R7);					 
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


--///////////////////////////////////////////////////////////////
-- (3) Hardware port map of Auto Focus module ControlUnit 		  
AFControlUnit1 : AFControlUnit PORT MAP (AFCU_Time,Start_FromCPU,Reset ,DMA_ACK_FromDMA,Clk,
									 FSM1_EN_SIG,FSM2_FIN_SIG,FSM3_FIN_SIG,
									 FSM2_CHDIR_SIG,
 									 DMA_EN_ToDMA,MOV_LEN_ToMechPart,DIR_ToMechPart,DONE_ToCPU,
									 AFSC_INC_SIG,AFSC_CLR_SIG,
									 AFAR_INC_SIG,AFAR_CLR_SIG,AFAR_LD_SIG,AFAR_OE_SIG,
									 CacheAR_INC_SIGo,CacheAR_CLR_SIGO,
									 FSM1_EN_SIGO,FSM2_EN_SIGO,FSM3_EN_SIGO);

	 
--///////////////////////////////////////////////////////////////
-- (3) Hardware port map of Auto Focus module ControlUnit supporting units FSM1,FSM2,FSM3			  
FSM1Unit : FSM1 PORT MAP ( FSM1_EN_SIG,
						   Reset,Clk,
						   X_SIG,Y_SIG,
						   Cache_RD_EN_ToCache,CacheAR_INC_SIG1,
						   RAE_SIG1,RBE_SIG1,WE_SIG1,OE_SIG1,
						   IE_SIG1,
						   RAA_SIG1,RBA_SIG1,WA_SIG1,
						   ALU_OP_SIG1,
						   FSM1_FIN_SIG);

FSM2Unit : FSM2 PORT MAP (
						  FSM2_EN_SIG,
						  Reset,Clk,
						  X_SIG,Y_SIG,CF_SIG,
						  Cache_RD_EN_ToCache,CacheAR_INC_SIG2,
						   RAE_SIG2,RBE_SIG2,WE_SIG2,OE_SIG2,
						   IE_SIG2,
						   RAA_SIG2,RBA_SIG2,WA_SIG2,
						   ALU_OP_SIG2,
						   FSM2_FIN_SIG,FSM2_CHDIR_SIG);

FSM3Unit : FSM3 PORT MAP (
						  FSM3_EN_SIG,
						  Reset,Clk,
						  X_SIG,Y_SIG,CF_SIG,
						  Cache_RD_EN_ToCache,CacheAR_INC_SIG3,
						   RAE_SIG3,RBE_SIG3,WE_SIG3,OE_SIG3,
						   IE_SIG3,
						   RAA_SIG3,RBA_SIG3,WA_SIG3,
						   ALU_OP_SIG3,
						   FSM3_FIN_SIG);
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	--PROCESS(Reset,Registers)
	--BEGIN 
		-- IF(RESET = '1') THEN	
		-- CF1 <= '0';
		-- ZF1 <= '0';
	    -- AFCU_Time <= "0000";
		 FSM1_EN_SIG  <= '0' when reset='1'
		 else FSM1_EN_SIGO;
		 FSM2_EN_SIG  <= '0' when reset='1'
		 else FSM2_EN_SIGO;
		 FSM3_EN_SIG  <= '0' when reset='1'
		 else FSM3_EN_SIGO;
	    -- FSM1_FIN_SIG <= '0';
		-- FSM2_FIN_SIG <= '0';
		-- FSM3_FIN_SIG <= '0';
		-- FSM2_CHDIR_SIG <='0';

		-- AFSC_INC_SIG <='0';
		-- AFSC_CLR_SIG <='0';
		-- AFAR_INC_SIG <='0';
		-- AFAR_CLR_SIG <='0';
		-- AFAR_LD_SIG  <= '0';
		-- AFAR_OE_SIG  <= '0';
		
		-- CacheAR_INC_SIG <='0';
		 CacheAR_CLR_SIG <='1' when reset='1'
		 else CacheAR_CLR_SIGO;

	     
--		 ALU_OP_SIG <= "000" when reset='1';
		
	 --       DP_OUT_SIG <= "0000000000000000" when reset='1';
	         X_SIG<='0' when reset='1'
			 ELSE '1' WHEN R6= "0000000000001111"
			 ELSE
			 '0';
			 
		     Y_SIG<='0' when reset='1'
			 ELSE  '1' WHEN R7 = "0000000000001111"
			 ELSE
			 '0';
		     CF_SIG<='0' when reset='1'
			 ELSE '1' WHEN R5 < R4
			ELSE
			 '0';
	     
		
 


	 

END AFModule_Arch;
	
	
	

	
	
