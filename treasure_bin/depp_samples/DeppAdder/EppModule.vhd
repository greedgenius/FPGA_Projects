----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:05:49 09/11/2012 
-- Design Name: 
-- Module Name:    EppModule - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity EppModule is
    Port ( Astb : in  STD_LOGIC;
           Dstb : in  STD_LOGIC;
           Wr : in  STD_LOGIC;
           Wt : out  STD_LOGIC;
           DataBus : inout  STD_LOGIC_VECTOR (7 downto 0);
			  Op1 : out std_logic_vector (7 downto 0);
			  Op2 : out std_logic_vector (7 downto 0);
			  Result : in std_logic_vector (7 downto 0));
end EppModule;

architecture Behavioral of EppModule is

	signal addressReg : std_logic_vector (7 downto 0);

begin

-- Epp signals
   -- Port signals
   Wt <= '1' when Astb = '0' or Dstb = '0' else '0';

   DataBus <= "10101111" when (Wr = '1') else "ZZZZZZZZ";

  -- EPP Address register
  process (Astb)
    begin
      if rising_edge(Astb) then  -- Astb end edge
        if Wr = '0' then -- Epp Addr write cycle
  		    addressReg <= DataBus;          -- Update the address register
        end if;
      end if;
    end process;

  -- EPP Write registers register
  process (Dstb)
    begin
      if rising_edge(Dstb) then  -- Astb end edge
        if Wr = '0' then -- Epp Data write cycle
  		      if addressReg = "00000000" then
					Op1 <= DataBus;
				elsif addressReg = "00000001" then
					Op2 <= DataBus;
				end if;
        end if;
      end if;
    end process;
	 
end Behavioral;

