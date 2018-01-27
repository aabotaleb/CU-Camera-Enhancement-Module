LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY DMAmodule IS
	PORT(
		Clk,Reset						  : IN STD_LOGIC;
	
		-- From and to AF
		DMA_EN_FromAF					  : IN STD_LOGIC  ;
		 
		FocusAdress_FromAF				  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		DMA_Ack_ToAF					  : OUT STD_LOGIC;
		
		-- From and to NVM 
		NVM_Data_FromNVM			      : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
		NVM_Address_ToNVM			      : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		NVM_RD_EN_ToNVM				  : OUT STD_LOGIC;
	
		-- From and to Cache 
		Cache_Data_ToCache			      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		Cache_Address_FromDMA			  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		Cache_WT_EN_ToCache				  : OUT STD_LOGIC
	
 
		);
END ENTITY DMAmodule;

ARCHITECTURE DMAmodule_Arch OF DMAmodule IS

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
END COMPONENT REG8;

COMPONENT REG4 IS
		PORT( Clk,Rst,Load : IN std_logic;
		  INC,DEC  : IN STD_LOGIC;
		  d : IN  std_logic_vector(3 DOWNTO 0);
		  Cin : IN STD_LOGIC ;
		  q : OUT std_logic_vector(3 DOWNTO 0);
		  CF_Out,ZF_Out : OUT STD_LOGIC);
END COMPONENT;


COMPONENT DMAControlUnit IS 
		PORT(	
		RowCntrDMA,ColCntrDMA,FIRST      : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --Row and Column Counters Output
		Clk						   : IN STD_LOGIC;
		Reset,DMA_En               : IN STD_LOGIC;                    --Whether it is reset or started
		NVMAR_OF				   : IN STD_LOGIC;
		
		
		DMA_Ack                    : OUT STD_LOGIC;
		RowCntrDMA_INC,RowCntrDMA_CLR                       : OUT STD_LOGIC;
		ColCntrDMA_INC,ColCntrDMA_CLR                       : OUT STD_LOGIC;
		FIRST_INC ,FIRST_CLR                                : OUT STD_LOGIC;
	
		NVMAR_ADD16,NVMAR_CLR,NVMAR_LD,NVMAR_OE       : OUT STD_LOGIC; -- Needed for DMA 
		CacheAR_INC,CacheAR_CLR                 : OUT STD_LOGIC; -- Needed for cache as address  
	
		NVM_RD,Cache_WT : OUT STD_LOGIC);
		
END COMPONENT DMAControlUnit;
	
	
	SIGNAL NVMAR_LD_SIG,NVMAR_ADD16_SIG,NVMAR_OF_SIG,ZF1 : STD_LOGIC;
	SIGNAL 	NVMAR_OE_SIG,NVMAR_CLR_SIG : STD_LOGIC; -- Not used could be deleted 

	SIGNAL CacheAR_CLR_SIG,CacheAR_INC_SIG,CF1 : STD_LOGIC;

	SIGNAL 	RowCntrDMA_CLR_SIG,RowCntrDMA_INC_SIG :STD_LOGIC;
	SIGNAL 	ColCntrDMA_CLR_SIG,ColCntrDMA_INC_SIG :STD_LOGIC;	
	SIGNAL  RowCntrDMA_SIG,ColCntrDMA_SIG : STD_LOGIC_VECTOR(3 DOWNTO 0);

	SIGNAL   FIRST_CLR_SIG,FIRST_INC_SIG : STD_LOGIC;
	SIGNAL   FIRST_SIG : STD_LOGIC_VECTOR(3 DOWNTO 0);

	
BEGIN

	 --Read 128 bits at once  [16 adjacent pixels in the first row]
	 -- it is one location in NVM-RAM and will ne distributes over 16 locations in cache RAM
	 -- Then Read another one location (prev one + 16 to skip into the next row)


      	 
	-----(1) The Registers used  
	 
	NVMAR1          : REG_MOD 			PORT MAP (Clk,Reset,NVMAR_LD_SIG,
										NVMAR_ADD16_SIG,'0',
										FocusAdress_FromAF,
										'0',
										NVM_Address_ToNVM,
										NVMAR_OF_SIG,ZF1);	
	
	
	CacheAR1        : REG8    			PORT MAP (Clk,Reset,CacheAR_CLR_SIG,
												 CacheAR_INC_SIG,'0',
												 "00000000",
												 '0',
												 Cache_Address_FromDMA,
												 CF1,ZF1);
												 
	FIRST1          : REG4              PORT MAP (Clk,Reset,FIRST_CLR_SIG,
												  FIRST_INC_SIG,'0',
												  "0000",
												  '0',
												  FIRST_SIG,
												  CF1,ZF1);
												  
	
	RowCntrDMA1     : REG4    			PORT MAP (Clk,Reset,RowCntrDMA_CLR_SIG,
												 RowCntrDMA_INC_SIG,'0',
												 "0000",
												 '0',
												 RowCntrDMA_SIG,
												 CF1,ZF1);
	
	ColCntrDMA1     : REG4    			PORT MAP (Clk,Reset,ColCntrDMA_CLR_SIG,
												  ColCntrDMA_INC_SIG,'0',
												  "0000",
												  '0',
												  ColCntrDMA_SIG,
												  CF1,ZF1);

	
	
	---- (2) The Control Unit 

	DMAControlUnit1 : DMAControlUnit	PORT MAP (RowCntrDMA_SIG,ColCntrDMA_SIG,FIRST_SIG,Clk,
												  Reset,DMA_EN_FromAF,
												  NVMAR_OF_SIG,
 
												  DMA_Ack_ToAF,
												  RowCntrDMA_INC_SIG,RowCntrDMA_CLR_SIG,
												  ColCntrDMA_INC_SIG,ColCntrDMA_CLR_SIG,
												  FIRST_INC_SIG,FIRST_CLR_SIG,
												  NVMAR_ADD16_SIG,NVMAR_CLR_SIG,NVMAR_LD_SIG,NVMAR_OE_SIG,
												  CacheAR_INC_SIG,CacheAR_CLR_SIG,
												  NVM_RD_EN_ToNVM,Cache_WT_EN_ToCache);
	 
	--- (3) Transfer Data Simply by assignment (Harware : Mux and Comaprator (for equality)) 
	-- no need for making a complicated datapath --
	
	Cache_Data_ToCache <= NVM_Data_FromNVM(7   DOWNTO   0) WHEN ColCntrDMA_SIG ="0000"
                     ELSE NVM_Data_FromNVM(15  DOWNTO   8) WHEN ColCntrDMA_SIG ="0001"
					 ELSE NVM_Data_FromNVM(23  DOWNTO  16) WHEN ColCntrDMA_SIG ="0010"
					 ELSE NVM_Data_FromNVM(31  DOWNTO  24) WHEN ColCntrDMA_SIG ="0011"
					 ELSE NVM_Data_FromNVM(39  DOWNTO  32) WHEN ColCntrDMA_SIG ="0100"
					 ELSE NVM_Data_FromNVM(47  DOWNTO  40) WHEN ColCntrDMA_SIG ="0101"
					 ELSE NVM_Data_FromNVM(55  DOWNTO  48) WHEN ColCntrDMA_SIG ="0110"
					 ELSE NVM_Data_FromNVM(63  DOWNTO  56) WHEN ColCntrDMA_SIG ="0111"
					 ELSE NVM_Data_FromNVM(71  DOWNTO  64) WHEN ColCntrDMA_SIG ="1000"
					 ELSE NVM_Data_FromNVM(79  DOWNTO  72) WHEN ColCntrDMA_SIG ="1001"
					 ELSE NVM_Data_FromNVM(87  DOWNTO  80) WHEN ColCntrDMA_SIG ="1010"
					 ELSE NVM_Data_FromNVM(95  DOWNTO  88) WHEN ColCntrDMA_SIG ="1011"
					 ELSE NVM_Data_FromNVM(103 DOWNTO  96) WHEN ColCntrDMA_SIG ="1100"
					 ELSE NVM_Data_FromNVM(111 DOWNTO 104) WHEN ColCntrDMA_SIG ="1101"
					 ELSE NVM_Data_FromNVM(119 DOWNTO 112) WHEN ColCntrDMA_SIG ="1110"
					 ELSE NVM_Data_FromNVM(127 DOWNTO 120) WHEN ColCntrDMA_SIG ="1111";
					 
					 

	
	
END DMAmodule_Arch;
