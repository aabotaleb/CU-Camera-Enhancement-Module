LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY AFSystem IS 
		PORT(	
		Clk,Reset						  : IN STD_LOGIC;
		 -- From and to CPU
		Start_FromCPU					  : IN STD_LOGIC  ;
		FocusAdress_FromCPU				  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		DONE_ToCPU 						  : OUT STD_LOGIC;
		-- From and to Mechanical Part 
		MOV_LEN_ToMechPart,DIR_ToMechPart : OUT STD_LOGIC  
		 );
		
END ENTITY AFSystem;

ARCHITECTURE AFSystem_Arch OF AFSystem IS 


COMPONENT NVMRAM IS
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		-- NVM is of 4096 locations each location of 16 pixels [128 bit]
		-- we need 12 bits only for addresses
		--		address : IN  std_logic_vector(11 DOWNTO 0);

		address : IN  std_logic_vector(11 DOWNTO 0);
		datain  : IN  std_logic_vector(127 DOWNTO 0);
		dataout : OUT std_logic_vector(127 DOWNTO 0));
END COMPONENT NVMRAM;

COMPONENT DMAmodule IS
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
END COMPONENT DMAmodule;

COMPONENT CacheRAM IS
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(7 DOWNTO 0);
		datain  : IN  std_logic_vector(7 DOWNTO 0);
		dataout : OUT std_logic_vector(7 DOWNTO 0));
END COMPONENT CacheRAM;

COMPONENT FF IS
	PORT( Clk,Rst  : IN std_logic;
		  d : IN  std_logic  ;
		  q : OUT std_logic  
		  );
END COMPONENT FF;


COMPONENT   AFModule IS
	PORT(
	Clk,Reset						  : IN STD_LOGIC;
	
	-- From and to CPU
	Start_FromCPU					  : IN STD_LOGIC  ;
	FocusAdress_FromCPU				  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	DONE_ToCPU 						  : OUT STD_LOGIC;

	-- From and to DMA 
	DMA_ACK_FromDMA                   : IN STD_LOGIC;
	DMA_EN_ToDMA                    : OUT STD_LOGIC;
	 
	FocusAdress_ToDMA				  : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);

	-- From and to Cache 
	Cache_Data_FromCache			  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
 	Cache_Address_FromAF			  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	Cache_RD_EN_ToCache				  : OUT STD_LOGIC;
	
	-- From and to Mechanical Part 
	MOV_LEN_ToMechPart,DIR_ToMechPart : OUT STD_LOGIC

	);
END COMPONENT;

	--SIGNAL  DMA_Ack_D_SIG,DMA_Ack_Q_SIG : STD_LOGIC;
	--SIGNAL  DMA_EN_D_SIG,DMA_EN_Q_SIG : STD_LOGIC;
	 
	
	SIGNAL  FocusAdress_ToDMA_SIG                : STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	SIGNAL 	Cache_Data_FromCache_SIG,Cache_Data_ToCache_SIG,Cache_Address_ToCache_SIG : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL  Cache_RD_EN_ToCache_SIG,Cache_WT_EN_ToCache_SIG :STD_LOGIC;
	
	SIGNAL    NVM_Data_FromNVM_SIG,NVM_Data_ToNVM_SIG : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL    NVM_Address_ToNVM_SIG: STD_LOGIC_VECTOR(11  DOWNTO 0);
	SIGNAL    NVM_RD_EN_ToNVM_SIG,NVM_WT_EN_ToCache_SIG  : STD_LOGIC;
	SIGNAL    Cache_Address_FromAF_SIG,Cache_Address_FromDMA_SIG : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL    DMA_Ack_ToAF_SIG,DMA_EN_ToDMA_SIG : STD_LOGIC;
	
BEGIN 

--Make the required hardware connections of the different modules
    
	
NVMRAM1    : NVMRAM    PORT MAP (clk,
								 NVM_WT_EN_ToCache_SIG,--no need for it pre-assumed that NVM is written
								 NVM_Address_ToNVM_SIG,
								 NVM_Data_ToNVM_SIG,--no need for it pre-assumed that NVM is written
								 NVM_Data_FromNVM_SIG);

	 
DMAmodule1 : DMAmodule PORT MAP ( clk,Reset,
								  DMA_EN_ToDMA_SIG,
								   
								  FocusAdress_ToDMA_SIG,
								  DMA_Ack_ToAF_SIG,
								  NVM_Data_FromNVM_SIG,
								  NVM_Address_ToNVM_SIG,
								  NVM_RD_EN_ToNVM_SIG,--No need for read enable 
								  Cache_Data_ToCache_SIG,
								  Cache_Address_FromDMA_SIG,
								  Cache_WT_EN_ToCache_SIG
								  );
								  
Cache_Address_ToCache_SIG <= Cache_Address_FromDMA_SIG WHEN Cache_WT_EN_ToCache_SIG = '1'
						ELSE Cache_Address_FromAF_SIG ;

CacheRAM1  : CacheRAM  PORT MAP (Clk,
								 Cache_WT_EN_ToCache_SIG,
								 Cache_Address_ToCache_SIG,
								 Cache_Data_ToCache_SIG,
								 Cache_Data_FromCache_SIG);
 								 
AFModule1  : AFModule  PORT MAP (clk,Reset,
								 Start_FromCPU,FocusAdress_FromCPU,DONE_ToCPU,
								 DMA_Ack_ToAF_SIG,DMA_EN_ToDMA_SIG, FocusAdress_ToDMA_SIG,
								 Cache_Data_FromCache_SIG,Cache_Address_FromAF_SIG,
								 Cache_RD_EN_ToCache_SIG,
								 MOV_LEN_ToMechPart,DIR_ToMechPart);

END ARCHITECTURE AFSystem_Arch;
