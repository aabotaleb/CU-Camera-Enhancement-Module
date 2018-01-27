library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_signed.ALL;
use IEEE.NUMERIC_STD.ALL;


ENTITY GenDataPath is
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
END GenDataPath;


ARCHITECTURE GenDataPathArch of GenDataPath is

COMPONENT MUX_4_1 is 
PORT ( a,b,c,d : in std_logic_vector(15 DOWNTO 0);
		s : in  std_logic_vector (1 downto 0 );
		x : out std_logic_vector(15 DOWNTO 0));
END COMPONENT;
 
 component Regfile is
    Port ( WA : in  STD_LOGIC_VECTOR (2 downto 0);
           RA1 : in  STD_LOGIC_VECTOR (2 downto 0);
           RA2 : in  STD_LOGIC_VECTOR (2 downto 0);
           RI : in  STD_LOGIC_VECTOR (15 downto 0);
           R1 : in  STD_LOGIC;
           R2 : in  STD_LOGIC;
           W : in  STD_LOGIC;
           RUN_OUT : in  STD_LOGIC;
           RD1O : out  STD_LOGIC_VECTOR (15 downto 0);
           RD2O : out  STD_LOGIC_VECTOR (15 downto 0);
           CLK : in  STD_LOGIC;
		   
		   Y0   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   Y1   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   Y2   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   Y3   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   Y4   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   Y5   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   Y6   : INOUT STD_LOGIC_VECTOR (15 downto 0);
		   Y7   : INOUT STD_LOGIC_VECTOR (15 downto 0));
		   
end component;

COMPONENT ALU is
    Port ( ALU_IN_A : in  Signed (15 downto 0);
           ALU_IN_B : in  Signed (15 downto 0);
           ALU_SEL : in  STD_LOGIC_VECTOR (2 downto 0);
           ALU_OUT : out  Signed (15 downto 0)
			  );
END COMPONENT;

COMPONENT triStateBuf is
---GENERIC ( n : integer := 16);
PORT    ( En   : IN  STD_LOGIC; 
           Inp  : IN  STD_LOGIC_VECTOR (15 downto 0);
           Outp  : OUT STD_LOGIC_VECTOR  (15 downto 0));
END COMPONENT;

SIGNAL   ALU_OUT_FB,ALU_IN_1,ALU_IN_1_d,ALU_IN_2,ALU_IN_2_d,MUX_OUT : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL   ALU_OUT_SIGN : SIGNED (15 DOWNTO 0);
BEGIN

MUX1     : MUX_4_1 PORT MAP ( ALU_OUT_FB,Cache_Data,"0000000000000000",Cache_Data,IE,MUX_OUT);
REGFILE1 : Regfile PORT MAP ( WA,RAA,RBA,MUX_OUT,RAE,RBE,WE,RESET,ALU_IN_1_d,ALU_IN_2_D,DPCLK,X0,X1,X2,X3,X4,X5,X6,X7);

ALU_IN_1 <= X0 when RAA="000"
ELSE X1 WHEN RAA="001"
ELSE X2 WHEN RAA="010"
ELSE X3 WHEN RAA="011"
ELSE X4 WHEN RAA="100"
ELSE X5 WHEN RAA="101"
ELSE X6 WHEN RAA="110"
ELSE X7 WHEN RAA="111";



ALU_IN_2 <= X0 when RBA="000"
ELSE X1 WHEN RBA="001"
ELSE X2 WHEN RBA="010"
ELSE X3 WHEN RBA="011"
ELSE X4 WHEN RBA="100"
ELSE X5 WHEN RBA="101"
ELSE X6 WHEN RBA="110"
ELSE X7 WHEN RBA="111";



ALU1     : ALU     PORT MAP (Signed(ALU_IN_1),Signed(ALU_IN_2),ALU_OP,ALU_OUT_SIGN);
ALU_OUT_FB <= STD_LOGIC_VECTOR (ALU_OUT_SIGN);
TRI1     : triStateBuf PORT MAP(OE,ALU_OUT_FB,DP_OUT);


END  GenDataPathArch;
