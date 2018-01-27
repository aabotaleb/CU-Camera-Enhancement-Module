LIBRARY IEEE;
USE     IEEE.std_logic_1164.ALL;
USE     IEEE.STD_LOGIC_signed.ALL;


ENTITY AFControlUnit IS 
	PORT(
	TimeAF               : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --AF_SC Output
	Start,Reset,DMA_Ack,Clk    : IN STD_LOGIC;                    --Whether it is reset or started
	FSM1_FIN,FSM2_FIN,FSM3_FIN : IN STD_LOGIC;
	FSM2_CHDIR                 : IN STD_LOGIC;
 		
 	DMA_EN,MOV_LEN,DIR,DONE                 : OUT STD_LOGIC;
	AFSC_INC,AFSC_CLR                       : OUT STD_LOGIC;
	AFAR_INC,AFAR_CLR,AFAR_LD,AFAR_OE       : OUT STD_LOGIC; -- Needed for DMA 
	CacheAR_INC,CacheAR_CLR                 : OUT STD_LOGIC; -- Needed for cache as address  
	FSM1_EN,FSM2_EN,FSM3_EN                 : OUT STD_LOGIC );
END AFControlUnit;

ARCHITECTURE AFControlUnit_Arch OF AFControlUnit IS
SIGNAL       DMA_Ack1 : STD_LOGIC;
BEGIN
	PROCESS(TimeAF,Start,Reset,DMA_Ack,FSM1_FIN,FSM2_FIN,FSM3_FIN)--,clk)
	BEGIN 
	       
		IF Reset = '1' THEN -- If reset 
			 
			
			AFAR_CLR <= '1';
			AFSC_CLR <= '1';
			CacheAR_CLR <='1';
			--FIRST_CLR     <= '1' ;
			--------Remaining output signals are zero 
			DMA_EN <='0';
			--FIRST_INC     <= '0';
			MOV_LEN <='0';
			DIR<='0';
			DONE<='0';
			AFSC_INC<='0';
		    AFAR_INC<='0';
			AFAR_LD<='0';
			AFAR_OE<='0';
			CacheAR_INC <= '0';
			FSM1_EN<='0';
			FSM2_EN<='0';
			FSM3_EN<='0';
			-------------------------------------------
		elsif Start ='0' THEN   -- If not reset but not started 
			 
			AFAR_CLR <= '1';
			AFSC_CLR <= '1';
			CacheAR_CLR <='1';
			--FIRST_CLR     <= '1' ;
			--------Remaining output signals are zero 
			DMA_EN <='0';
			--FIRST_INC <='0';
			MOV_LEN <='0';
			DIR<='0';
			DONE<='0';
			AFSC_INC<='0';
		    AFAR_INC<='0';
			AFAR_LD<='0';
			AFAR_OE<='0';
			CacheAR_INC <= '0';
			FSM1_EN<='0';
			FSM2_EN<='0';
			FSM3_EN<='0';
			-------------------------------------------		
		ELSE                -- If not rest and started 
			IF TimeAF="0000" THEN 
				 --FIRST_INC<='1';
				AFAR_LD <= '1';
				AFSC_INC<= '1';
				--------Remaining output signals are zero 
				DMA_EN <='0';
				 --FIRST_CLR<='0';
				MOV_LEN <='0';
				DIR<='0';
				DONE<='0';
				AFSC_CLR<='0';
				AFAR_INC<='0';
				AFAR_CLR<='0';
				AFAR_OE<='0';
				CacheAR_CLR <='0';
				CacheAR_INC <='0';
				FSM1_EN<='0';
				FSM2_EN<='0';
				FSM3_EN<='0';
				-------------------------------------------
			elsif TimeAF ="0001" then --AND FIRST ="0001" then --AND DMA_Ack='0' THEN 
			      
			    
				IF DMA_Ack = '0'   THEN 
					AFAR_OE <= '1';
					--if clk ='0' then
					DMA_EN  <= '1';
					--end if;
					--FIRST_CLR <='0';
					--FIRST_INC <='0';
					AFSC_INC<= '0';
					--------Remaining output signals are zero 
					MOV_LEN <='0';
					DIR<='0';
					DONE<='0';
					AFSC_CLR<='0';
					AFAR_INC<='0';
				    AFAR_CLR<='0';
				    AFAR_LD<='0';
				    CacheAR_CLR <='0';
				    CacheAR_INC <='0';
				    FSM1_EN<='0';
				    FSM2_EN<='0';
				    FSM3_EN<='0';
				Elsif DMA_Ack = '1'   THEN 
			
				--ELSE -- 			ELSIF TimeAF ="0001" AND DMA_Ack='1' THEN
				   
					--if clk ='0' then
				    DMA_EN <= '1';--WAIT CYCLE
				    --end if ;
					--FIRST_CLR <='0';
					--FIRST_INC <='0';					
				    AFAR_OE<= '1';
				    --Start FSM 1
				    FSM1_EN <= '0'; -- WAIT CYCLE
				    AFSC_INC <= '1';
				    CacheAR_CLR <='1';
				    --------Remaining output signals are zero 
				    MOV_LEN <='0';
				    DIR<='0';
				    DONE<='0';
				    AFSC_CLR<='0';
				    AFAR_INC<='0';
				    AFAR_CLR<='0';
				    AFAR_LD<='0';
				    CacheAR_INC <='0';
				    FSM2_EN<='0';
				    FSM3_EN<='0';
				
				END IF;
			---- 				
			ELSIF TimeAF ="0010"  THEN --DISABLE DMA 
				    DMA_EN <= '0'; 
				    --end if ;
					--FIRST_CLR <='0';
					--FIRST_INC <='0';					
				    AFAR_OE<= '1';
				    --Start FSM 1
				    FSM1_EN <= '0'; -- Start FSM 
				    AFSC_INC <= '1';
				    CacheAR_CLR <='1';
				    --------Remaining output signals are zero 
				    MOV_LEN <='0';
				    DIR<='0';
				    DONE<='0';
				    AFSC_CLR<='0';
				    AFAR_INC<='0';
				    AFAR_CLR<='0';
				    AFAR_LD<='0';
				    CacheAR_INC <='0';
				    FSM2_EN<='0';
				    FSM3_EN<='0';
					ELSIF TimeAF ="0011"  THEN --DISABLE DMA 
				    DMA_EN <= '0'; 
				    --end if ;
					--FIRST_CLR <='0';
					--FIRST_INC <='0';					
				    AFAR_OE<= '1';
				    --Start FSM 1
				    FSM1_EN <= '0'; -- Start FSM 
				    AFSC_INC <= '1';
				    CacheAR_CLR <='1';
				    --------Remaining output signals are zero 
				    MOV_LEN <='0';
				    DIR<='0';
				    DONE<='0';
				    AFSC_CLR<='0';
				    AFAR_INC<='0';
				    AFAR_CLR<='0';
				    AFAR_LD<='0';
				    CacheAR_INC <='0';
				    FSM2_EN<='0';
				    FSM3_EN<='0';
			ELSIF TimeAF ="0100"  THEN --DISABLE DMA 
			if FSM1_FIN='0' THEN
				    DMA_EN <= '0'; 
				    --end if ;
					--FIRST_CLR <='0';
					--FIRST_INC <='0';					
				    AFAR_OE<= '1';
				    --Start FSM 1
				    FSM1_EN <= '1'; -- Start FSM 
				    AFSC_INC <= '1';
				    CacheAR_CLR <='1';
				    --------Remaining output signals are zero 
				    MOV_LEN <='0';
				    DIR<='0';
				    DONE<='0';
				    AFSC_CLR<='0';
				    AFAR_INC<='0';
				    AFAR_CLR<='0';
				    AFAR_LD<='0';
				    CacheAR_INC <='0';
				    FSM2_EN<='0';
				    FSM3_EN<='0';
			 			 
				------------------------------------------- 				
			  else   
 				DMA_EN <= '0';				  
				AFAR_OE<= '0';
				--Start FSM 1
				FSM1_EN <= '1';
				AFSC_INC <= '0';
				CacheAR_CLR <='0';
				--------Remaining output signals are zero 
				MOV_LEN <='0';
				DIR<='0';
				DONE<='0';
				AFSC_CLR<='0';
				AFAR_INC<='0';
				AFAR_CLR<='0';
				AFAR_LD<='0';
				CacheAR_INC <='0';
				FSM2_EN<='0';
				FSM3_EN<='0';
				end if;
				-------------------------------------------
			ELSIF TimeAF ="0010" AND FSM1_FIN='1' THEN --Now the total original scene contrast is calculated in register R4
				  DIR <= '1';
				  MOV_LEN <= '1';
				  DMA_EN <='1';
				   	 
				  AFSC_INC <='1';
				  --------Remaining output signals are zero 
  				  DONE<='0';
				  AFSC_CLR<='0';
				  AFAR_INC<='0';
				  AFAR_CLR<='0';
				  AFAR_LD<='0';
				  AFAR_OE<='0';	
				  CacheAR_CLR <='0';
				  CacheAR_INC <='0';
				  FSM1_EN<='0';				  
				  FSM2_EN<='0';
				  FSM3_EN<='0';
			ELSIF TimeAF ="0011" AND DMA_Ack='0' THEN --Now the total original scene contrast is calculated in register R4
				  DIR <= '0';
				  MOV_LEN <= '0';
				  DMA_EN <='1';
				  AFSC_INC <='0';
				  --------Remaining output signals are zero 
  				  DONE<='0';
				  AFSC_CLR<='0';
				  AFAR_INC<='0';
				  AFAR_INC<='0';
				  AFAR_CLR<='0';
				  AFAR_LD<='0';
				  AFAR_OE<='0';	
				  CacheAR_CLR <='0';
				  CacheAR_INC <='0';
				  FSM1_EN<='0';				  
				  FSM2_EN<='0';
				  FSM3_EN<='0';

				  -------------------------------------------
			ELSIF TimeAF ="0011" AND DMA_Ack='1' THEN
				   AFAR_OE<='1';	
				   FSM2_EN <= '1';
				   AFSC_INC <= '1';
				   CacheAR_CLR <='1';
				
				   -- DIR is still 1 
				   --------Remaining output signals are zero 
				   DMA_EN<='0';
				    
				   MOV_LEN <= '0';  				  
				   DONE<='0';
				   AFSC_CLR<='0';
				   AFAR_INC<='0';
				   AFAR_CLR<='0';
				   AFAR_LD<='0';
				   CacheAR_INC <='0';
				   FSM1_EN<='0';				  
				   FSM3_EN<='0';
			ELSIF TimeAF ="0100" AND FSM2_FIN ='0' THEN
				   AFAR_OE<='1';	
				   FSM2_EN <= '1';
				   AFSC_INC <= '0';
				   CacheAR_CLR <='0';
				
				   -- DIR is still 1 
				   --------Remaining output signals are zero 
				   DMA_EN<='0';
				    
				   MOV_LEN <= '0';  				  
				   DONE<='0';
				   AFSC_CLR<='0';
				   AFAR_INC<='0';
				   AFAR_CLR<='0';
				   AFAR_LD<='0';
				   CacheAR_INC <='0';
				   FSM1_EN<='0';				  
				   FSM3_EN<='0';
				   
				   -------------------------------------------
			ELSIF TimeAF ="0100" AND FSM2_FIN ='1'  THEN
				IF FSM2_CHDIR = '1' THEN
					DIR <='0';
				END IF;
				AFSC_INC <='1';
				   --------Remaining output signals are zero 
				   DMA_EN<='0';
				    
				   MOV_LEN <= '0';  				  
				   DONE<='0';
				   AFSC_CLR<='0';
				   AFAR_INC<='0';
				   AFAR_CLR<='0';
				   AFAR_LD<='0';
				   AFAR_OE<='0';	
				   CacheAR_CLR <='0';
				   CacheAR_INC <='0';
				   FSM1_EN<='0';				  
				   FSM2_EN<='0';				  
				   FSM3_EN<='0';
				   -------------------------------------------
				
			ELSIF TimeAF ="0101" AND DMA_Ack ='0'  THEN
				MOV_LEN <= '1';
				DMA_EN  <= '1';
				 
			    AFAR_OE<='1';
				AFSC_INC <='0';
				   --------Remaining output signals are zero 
 				   DONE<='0';
				   AFSC_CLR<='0';
				   AFAR_INC<='0';
				   AFAR_CLR<='0';
				   AFAR_LD<='0';	
				   CacheAR_CLR <='0';
				   CacheAR_INC <='0';
				   FSM1_EN<='0';				  
				   FSM2_EN<='0';				  
				   FSM3_EN<='0';
				   -------------------------------------------

			ELSIF TimeAF ="0101" AND DMA_Ack ='1'  THEN
				 FSM3_EN <= '1';
				 DMA_EN  <= '0';
				  
 			     AFAR_OE<='1';
				 AFSC_INC <= '1';
  			     CacheAR_CLR <='1';
				   --------Remaining output signals are zero 
 				   DONE<='0';
				   MOV_LEN<='0';
				   AFSC_CLR<='0';
				   AFAR_INC<='0';
				   AFAR_CLR<='0';
				   AFAR_LD<='0';	
				   CacheAR_INC <='0';
				   FSM1_EN<='0';				  
				   FSM2_EN<='0';				  
				   -------------------------------------------
			ELSIF TimeAF ="0110" AND FSM3_FIN ='0'   THEN
				  DONE <= '0';
				  AFAR_CLR<='0';
				  FSM3_EN<='1';
				   
				   --------Remaining output signals are zero 
				   MOV_LEN <='0';
				   DMA_EN  <='0';
				    
				   AFSC_CLR<='0';
				   AFSC_INC<='0';
				   AFAR_INC<='0';
				   AFAR_LD<='0';	
	   			   AFAR_OE<='0';
				   CacheAR_CLR <='0';
				   CacheAR_INC <='0';
				   FSM1_EN<='0';				  
				   FSM2_EN<='0';				  
				   
			ELSIF TimeAF ="0110" AND FSM3_FIN ='1'   THEN
				  DONE <= '1';
				  AFAR_CLR<='1';
				   --------Remaining output signals are zero 
				   MOV_LEN <='0';
				   DMA_EN  <='0';
				    
				   AFSC_CLR<='0';
				   AFSC_INC<='0';
				   AFAR_INC<='0';
				   AFAR_LD<='0';	
	   			   AFAR_OE<='0';
				   CacheAR_CLR <='0';
				   CacheAR_INC <='0';
				   FSM1_EN<='0';				  
				   FSM2_EN<='0';				  
				   FSM3_EN<='0';
				   -------------------------------------------  
			END IF;
		 end if ; 	
      
	 
	END PROCESS;
	
 
	 
 
END AFControlUnit_Arch;