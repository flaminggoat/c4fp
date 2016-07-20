-------------------------------
-- cla.vhd
-- Theo Hussey 2016
--
-- Test bench for alu
-------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
end alu_tb;

architecture tb of alu_tb is
  constant size : integer := 16;

   component alu
	generic(data_size : integer := 16);
        port (a, b   : in std_logic_vector (data_size - 1 downto 0);
              op     : in std_logic_vector (3 downto 0);
              cin    : in std_logic;
              output : out std_logic_vector (data_size - 1 downto 0);
              status : out std_logic_vector (3 downto 0));
    end component;

    signal a      : std_logic_vector (size - 1 downto 0);
    signal b      : std_logic_vector (size - 1 downto 0);
    signal op     : std_logic_vector (3 downto 0);
    signal cin    : std_logic;
	 
    signal output : std_logic_vector (size - 1 downto 0);
    signal status : std_logic_vector (3 downto 0);
	 
	type test_vector is record
		a      : integer;
		b      : integer;
		op     : std_logic_vector(3 downto 0);
		cin    : std_logic;
		output : integer;
		status  : STD_LOGIC_VECTOR(3 downto 0);
	end record;
	
	type test_vector_array is array
	(natural range <>) of test_vector;
	
	-- op code definitions
    constant op_b   : std_logic_vector := "0000"; --     b
	 constant op_add : std_logic_vector := "0001"; --     add     
	 constant op_sub : std_logic_vector := "0010"; --   s sub
	 constant op_and : std_logic_vector := "0011"; --   s and
	 constant op_or  : std_logic_vector := "0100"; --  c  or
	 constant op_addc: std_logic_vector := "0101"; --  c  addc
	 constant op_subc: std_logic_vector := "0110"; --  cs subc
	 constant op_xor : std_logic_vector := "0111"; --  cs xor
	 constant op_a   : std_logic_vector := "1000"; -- b   a
	 constant op_inc : std_logic_vector := "1001"; -- b   a++
	 constant op_dec : std_logic_vector := "1010"; -- b s a--
	 constant op_srl : std_logic_vector := "1011"; -- b s a>>1
	 constant op_not : std_logic_vector := "1100"; -- bc  ~a
	 constant op_sra : std_logic_vector := "1101"; -- bc  a/2
	 constant op_sll : std_logic_vector := "1110"; -- bcs a<<1
	 constant op_slf : std_logic_vector := "1111"; -- bcs a<<4
	
	constant test_vectors : test_vector_array := (
	-- a, b, op, output, flags
	(0,		0, 		op_a  , '0', 0,		"0100"), --a
	(12, 		16, 		op_b  , '0', 16,		"0000"), --b
	(12, 		16, 		op_add, '0', 28,		"0000"), --a+b
	(45, 		16, 		op_sub, '0', 29,		"0000"), --a-b
	(16, 		45, 		op_sub, '0', -29,		"1001"), --a-b 	
	(663, 	221, 		op_and, '0', 149,		"0000"), --a and b
	(12, 		16,	   op_or , '0', 28,		"0000"), --a or b
	(-11297, 27298, 	op_xor, '0', -18051,	"1010"), --a xor b
	(-18051, 0, 		op_not, '0', 18050,	"0000"), --not a
	(32767, 	0, 		op_inc, '0', -32768,	"1010"), --a+1 should overflow
	(567, 	723, 		op_dec, '0', 566,	   "0000"), --a-1
	(567, 	723, 		op_srl, '0', 283,	   "0000"), --a>>1
	(567,   	723, 		op_sll, '0', 1134 ,	"0000"), --a<<1
	(-8,   	723, 		op_sra, '0', -4,	   "1010"), --a/2
	(-8,   	723, 		op_srl, '0', 32764,  "0000"), --a>>1
	(-8,   	723, 		op_slf, '0', -128,   "1010"), --a<<4
	(34464, 	37856, 	op_add, '0', 6784,	"0011"), --a+b   100000 + 300000 16 bit add
	(1, 	   4, 	  op_addc, '1', 6,	   "0000"), --a+b+c  ^^
	(100, 	34464, 	op_sub, '0', 31172,	"0011"), --a+b   100 -100000 unsigned 16 bit add
	(0, 	   1, 	  op_subc, '1', -2,	   "1001")  --a+b+c  ^^
	); 

begin

    dut : alu
	 generic map (
	     data_size => size
	 )
    port map (a      => a,
              b      => b,
              op     => op,
              cin    => cin,
              output => output,
              status => status);


    stimuli : process
    begin
			wait for 10 ns;
			for i in test_vectors'range loop
				a <= std_logic_vector(to_signed(test_vectors(i).a,a'length));
				b <= std_logic_vector(to_signed(test_vectors(i).b,b'length));
				op <= test_vectors(i).op;
				cin <= test_vectors(i).cin;
				wait for 10 ns;
				assert (output = std_logic_vector(to_signed(test_vectors(i).output, output'length)))
					and (status = test_vectors(i).status)
				report "Test vector " & integer'image(i) &
					" failed for input a = " & integer'image(test_vectors(i).a)
					& " and b = " & integer'image(test_vectors(i).b) 
					& " and op = " & integer'image(to_integer(unsigned(op))) & CR & "Expected output: " 
					& integer'image(test_vectors(i).output) & " recieved:" & integer'image(to_integer(signed(output)))
					& CR & "Expected status: " & integer'image(to_integer(unsigned(test_vectors(i).status))) & " recieved: "
					& integer'image(to_integer(unsigned(status)))
					severity error;
			end loop; 
			wait;
    end process;

end tb;