LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY DMAControlUnit IS 
		PORT(	
		RowCntrDMA,ColCntrDMA,FIRST   : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --Row and Column Counters Output
		Clk 						  : IN STD_LOGIC;
		Reset,DMA_En               : IN STD_LOGIC;                    --Whether it is reset or started
		NVMAR_OF				   : IN STD_LOGIC;
		 
							  
		DMA_Ack                    : OUT STD_LOGIC;
		RowCntrDMA_INC,RowCntrDMA_CLR                       : OUT STD_LOGIC;
		ColCntrDMA_INC,ColCntrDMA_CLR                       : OUT STD_LOGIC;
		FIRST_INC ,FIRST_CLR                                : OUT STD_LOGIC;
		
		NVMAR_ADD16,NVMAR_CLR,NVMAR_LD,NVMAR_OE       : OUT STD_LOGIC; -- Needed for DMA 
		CacheAR_INC,CacheAR_CLR                 : OUT STD_LOGIC; -- Needed for cache as address  
		
		NVM_RD,Cache_WT : OUT STD_LOGIC);
		
END ENTITY DMAControlUnit;


ARCHITECTURE DMAControlUnit_Arch OF DMAControlUnit IS
 signal a,b : STD_LOGIC;
 
BEGIN
	PROCESS(Reset,DMA_En,RowCntrDMA,ColCntrDMA,FIRST)--,clk )
	BEGIN 
	
		IF (Reset ='1') THEN 
			RowCntrDMA_CLR<= '1';
			ColCntrDMA_CLR<= '1';
			NVMAR_CLR     <= '1';
			CacheAR_CLR   <= '1';
			FIRST_CLR     <= '1' ;
			
			--Reset signals are zero 
			FIRST_INC     <= '0';
			
			DMA_Ack        <= '0';
			RowCntrDMA_INC <= '0';
			ColCntrDMA_INC <= '0';
			NVMAR_ADD16    <= '0';
			NVMAR_LD       <= '0';
			NVMAR_OE       <= '0';
			CacheAR_INC    <= '0';
			NVM_RD         <= '0';
			Cache_WT       <= '0';
			
		ELSIF Reset ='0' THEN 
		
		--IF rising_edge(Clk) THEN 
		
 			IF (DMA_EN ='0')  THEN
				RowCntrDMA_CLR<= '1';
				ColCntrDMA_CLR<= '1';
				NVMAR_CLR     <= '1';
				CacheAR_CLR   <= '1';
				
				--Reset signals are zero
				IF RowCntrDMA="1111" and FIRST ="0000" THEN 
				A <= '1';
				B <= '1';
				
				DMA_Ack        <= '1';
				FIRST_INC <= '1';
				FIRST_CLR     <= '0';
				ELSe--if Clk ='0' then 
				 
				
				DMA_Ack        <= '0';-- Let it zero after delay 
				FIRST_CLR     <= '1';
				FIRST_INC <= '0';
				END IF ;
				
				RowCntrDMA_INC <= '0';
				ColCntrDMA_INC <= '0';
				NVMAR_ADD16    <= '0';
				NVMAR_LD       <= '0';
				NVMAR_OE       <= '0';
				CacheAR_INC    <= '0';	
				NVM_RD         <= '0';
				Cache_WT       <= '0';
			
			ELSE 
			
				IF RowCntrDMA = "0000" AND FIRST = "0000" THEN --We need to load the focus matrix address 
				
					NVMAR_LD <= '1';
					NVM_RD <= '1';
					Cache_WT       <= '1';
					FIRST_INC      <= '1';
					--Reset signals are zero 
					FIRST_CLR      <= '0';
					RowCntrDMA_CLR<= '0';
					ColCntrDMA_CLR<= '0';
					NVMAR_CLR      <= '0';
					CacheAR_CLR    <= '0';			
					DMA_Ack        <= '0';
					RowCntrDMA_INC <= '0';
					NVMAR_ADD16    <= '0';
					NVMAR_OE       <= '0';
					CacheAR_INC    <= '0';
				
				ELSIF ColCntrDMA = "0000" THEN -- We need to read the NVM 128 bit [16 pixel] 
			
					NVM_RD <= '1';
					Cache_WT       <= '1';		
					ColCntrDMA_INC <= '1';
					--Reset signals are zero
					FIRST_CLR <='0';
					FIRST_INC <= '0';
					RowCntrDMA_CLR<= '0';
					ColCntrDMA_CLR<= '0';
					NVMAR_CLR      <= '0';
					CacheAR_CLR    <= '0';			
					DMA_Ack        <= '0';
					RowCntrDMA_INC <= '0';
					NVMAR_ADD16    <= '0';
					NVMAR_LD       <= '0';
					NVMAR_OE       <= '0';
					CacheAR_INC    <= '1';
				ELSIF ColCntrDMA = "1111"   THEN
				
					NVMAR_ADD16 <= '1';
					ColCntrDMA_CLR <= '1';
					RowCntrDMA_INC <= '1';
					NVM_RD <= '1';
					Cache_WT       <= '1';	
					FIRST_CLR<='1';
				
				   -- if clk ='1' then 
					IF NVMAR_OF='1' THEN
						DMA_Ack        <= '1';
					ELSIF RowCntrDMA = "1111" THEN 
						DMA_Ack        <= '1';
					ELSE
					     
						DMA_Ack			<= '0';
					END IF;
				    --end if ;
				
				
					--Reset signals are zero
					FIRST_INC <='0';
					ColCntrDMA_INC<= '0';
					RowCntrDMA_CLR<= '0';
					NVMAR_CLR      <= '0';
					CacheAR_CLR    <= '0';
					NVMAR_LD       <= '0';
					NVMAR_OE       <= '0';
					CacheAR_INC    <= '1';
				ELSE 
					NVM_RD <= '1';
					Cache_WT       <= '1';		
					ColCntrDMA_INC <= '1';
					--Reset signals are zero 
					FIRST_INC <= '0';
					FIRST_CLR <= '0';
					RowCntrDMA_CLR<= '0';
					ColCntrDMA_CLR<= '0';
					NVMAR_CLR      <= '0';
					CacheAR_CLR    <= '0';			
					DMA_Ack        <= '0';
					RowCntrDMA_INC <= '0';
					NVMAR_ADD16    <= '0';
					NVMAR_LD       <= '0';
					NVMAR_OE       <= '0';
					CacheAR_INC    <= '1';
				END IF;	
	
			END IF;
		--END IF; -- RISING EDGE 
		
	  END IF;
	
	END PROCESS;






END ARCHITECTURE DMAControlUnit_Arch;

