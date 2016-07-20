-------------------------------
-- cla.vhd
-- Theo Hussey 2016
--
-- Generic carry look ahead adder
-------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity cla is
	 generic(data_size : integer := 16);
    port(
		 a,b : in std_logic_vector(data_size - 1 downto 0);
		 cin : in std_logic;
		 sum : out std_logic_vector(data_size - 1 downto 0);
		 cout : out std_logic
    );
end cla;

architecture behavioral of cla is

signal g,p : std_logic_vector(data_size - 1 downto 0);
signal ctemp : std_logic_vector(data_size downto 0);

begin

    g <= a and b;
    p <= a xor b;
    ctemp(0) <= cin;
   
    GP: for k in 0 to (data_size - 1) generate
        ctemp(k+1) <= g(k) or (p(k) and ctemp(k));
        sum(k) <= ctemp(k) xor p(k);
    end generate;
   
    cout <= g(data_size - 1) or (p(data_size - 1) and ctemp(data_size - 1));

end behavioral;