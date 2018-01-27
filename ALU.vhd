library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_signed.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( ALU_IN_A : in  Signed (15 downto 0);
           ALU_IN_B : in  Signed (15 downto 0);
           ALU_SEL : in  STD_LOGIC_VECTOR (2 downto 0);
           ALU_OUT : out  Signed (15 downto 0)
			  );
end ALU;

architecture Behavioral of ALU is

begin
Process( ALU_IN_A , ALU_IN_B , ALU_SEL )
BEGIN
case ALU_SEL IS 
when "000" =>
ALU_OUT <= ALU_IN_A + ALU_IN_B ; --ADD
when "001" =>
ALU_OUT <= ALU_IN_A - ALU_IN_B ; --SUB
when "010" =>
 IF ALU_IN_A > ALU_IN_B THEN 
   ALU_OUT <= ALU_IN_A - ALU_IN_B ;
 ELSE
     ALU_OUT <= ALU_IN_B - ALU_IN_A ;
  END IF;
ALU_OUT <= ALU_IN_A and ALU_IN_B ; --Absolute SUB
when "011" =>
ALU_OUT <= "0000000000000000" ; --OR
when "100" =>
ALU_OUT <= ALU_IN_A  ; -- transfer A
when "101" =>
ALU_OUT <= ALU_IN_A + 1; --INC
when "110" =>
ALU_OUT <= ALU_IN_A + ALU_IN_A ; --SL
when "111" =>
ALU_OUT <= '0' & ALU_IN_A(15 downto 1) ; --SR
when others =>

end case;
end Process;
end Behavioral;

