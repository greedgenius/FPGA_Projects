----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:02:52 09/11/2012 
-- Design Name: 
-- Module Name:    DeppAdder - structural 
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DeppAdder is
port(
--EPP Signals
	EppAstb : in std_logic;
	EppDstb : in std_logic;
	EppWr : in std_logic;
	EppWait : out std_logic;
	EppDB : inout std_logic_vector (7 downto 0)
);


end DeppAdder;

architecture structural of DeppAdder is

	component EppModule is
		 Port ( Astb : in  STD_LOGIC;
				  Dstb : in  STD_LOGIC;
				  Wr : in  STD_LOGIC;
				  Wt : out  STD_LOGIC;
				  DataBus : inout  STD_LOGIC_VECTOR (7 downto 0);
				  Op1 : out std_logic_vector (7 downto 0);
				  Op2 : out std_logic_vector (7 downto 0);
				  Result : in std_logic_vector (7 downto 0));
	end component;
	
	COMPONENT Adder8Bit
		PORT (a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				s : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;

	signal Op1, Op2, Result : std_logic_vector (7 downto 0);

begin

	EppModule1 : EppModule port map (
		Astb => EppAstb,
		Dstb => EppDstb,
		Wr => EppWr,
		Wt => EppWait,
		DataBus => EppDB,
		Op1 => Op1,
		Op2 => Op2,
		Result => Result
	);

	Adder8Bit1 : Adder8Bit port map (
		a => Op1,
		b => Op2,
		s => Result
	);
	
end structural;

