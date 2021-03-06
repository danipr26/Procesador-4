library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;

entity PSR_Modifier is --Registro que contiene informacion sobre el estado del procesador
    Port ( ALUOP : in  STD_LOGIC_VECTOR (5 downto 0);
           ALU_Result : in  STD_LOGIC_VECTOR (31 downto 0);
           Crs1 : in  STD_LOGIC_VECTOR (31 downto 0);
           MuxOut : in  STD_LOGIC_VECTOR (31 downto 0);
           nzvc : out  STD_LOGIC_VECTOR (3 downto 0);
			  reset: in STD_LOGIC
			  );
end PSR_Modifier;

architecture Behavioral of PSR_Modifier is

begin

	process(ALUOP, ALU_Result, Crs1, MuxOut,reset)
	begin
		if (reset = '1') then
			nzvc <= (others=>'0');
		else
			--           ANDcc or         ANDNcc or        ORcc     or       ORNcc   or         XORcc  or        XNORcc
			if (ALUOP="010001" OR ALUOP="010101" OR ALUOP="010010" OR ALUOP="010110" OR ALUOP="010011" OR ALUOP="010111") then
				nzvc(3) <= ALU_result(31);--el signo que traiga
				if (conv_integer(ALU_result)=0) then
					nzvc(2) <= '1';--porque el resultado da cero
				else
					nzvc(2) <= '0';
				end if;
				nzvc(1) <= '0';--los operadores logicos no generan overflow ni carry
				nzvc(0) <= '0';
			end if;
			
			--           ADDcc or        ADDxcc
			if (ALUOP="010000" or ALUOP="011000") then
				nzvc(3) <= ALU_result(31);
				if (conv_integer(ALU_result)=0) then
					nzvc(2) <= '1';
				else
					nzvc(2) <= '0';
				end if;
				nzvc(1) <= (Crs1(31) and MuxOut(31) and (not ALU_result(31))) or ((not Crs1(31)) and (not MuxOut(31)) and ALU_result(31));
				nzvc(0) <= (Crs1(31) and MuxOut(31)) or ((not ALU_result(31)) and (Crs1(31) or MuxOut(31)) );
			end if;
			
			--          SUBcc or          SUBxcc
			if (ALUOP="010100" or ALUOP="011100") then
				nzvc(3) <= ALU_result(31);
				if (conv_integer(ALU_result)=0) then
					nzvc(2) <= '1';
				else
					nzvc(2) <= '0';
				end if;
				nzvc(1) <= (Crs1(31) and (not MuxOut(31)) and (not ALU_result(31))) or ((not Crs1(31)) and MuxOut(31) and ALU_result(31));
				nzvc(0) <= ((not Crs1(31)) and MuxOut(31)) or (ALU_result(31) and ((not Crs1(31)) or MuxOut(31)));
			end if;
		end if;
		
	end process;
	
end Behavioral;

