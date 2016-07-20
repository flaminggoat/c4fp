-------------------------------
-- alu.vhd
-- Theo Hussey 2016
--
-- flags
--
-- xxx1 | carry      valid only for addsub operations
-- xx1x | overflow   valid only for addsub operations
-- x1xx | zero
-- 1xxx | negative
-------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Generic (data_size : integer := 16);
    Port ( a, b   : in std_logic_vector (data_size - 1 downto 0);
           op     : in std_logic_vector (3 downto 0);
           cin    : in std_logic;
           output : out std_logic_vector (data_size - 1 downto 0);
           status : out std_logic_vector (3 downto 0));
end alu;

architecture Behavioral of alu is

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

    signal int_b, int_a, int_out, addsub, bas : signed(data_size-1 downto 0);
	 signal c_enable, sub_enable, b_one, cout, add_cout, int_c, c: std_logic;

begin

	 adder: entity work.cla
	 generic map(data_size => data_size)
	 port map(a => a, b => std_logic_vector(bas), cin => c, signed(sum) => addsub, cout => add_cout);

	 c_enable <= op(2);
	 sub_enable <= op(1);
	 b_one <= op(3);
	 
	 int_a <= signed(a);
	 output <= std_logic_vector(int_out);
	 
	 -- int_b should be 1 for add and sub operations that dont require b
	 int_b <= signed(b) when b_one = '0' else to_signed(1, int_b'length);
	 -- bas should be inverted for sub operations
	 bas <= int_b when sub_enable = '0' else (not int_b);
	 
	 -- int_c should be cin for addc and subc otherwise 0
	 int_c <= cin when c_enable = '1' else '0';
	 -- c should be inverted when subtracting 
	 c <= int_c when sub_enable = '0' else (not int_c);
	 -- cout should be inverted when subtracting
	 cout <= add_cout when sub_enable = '0' else (not add_cout);

    -- arithmetic Logic based on op codes
    with op select
        int_out <= int_b                                  when op_b   ,
                   int_a and int_b                        when op_and ,
                   int_a or int_b                         when op_or  ,
                   int_a xor int_b                        when op_xor ,
                   int_a                                  when op_a   ,
                   not int_a                              when op_not ,
                   signed(shift_left(unsigned(int_a),1))  when op_sll ,
                   signed(shift_right(unsigned(int_a),1)) when op_srl ,
                   shift_right(signed(int_a),1)           when op_sra ,
                   signed(shift_left(unsigned(int_a),4))  when op_slf ,
						 addsub                                 when others;

	 -- flag outputs
    status(0) <= cout;
    status(1) <= '1' when cout /= int_out(data_size-1) else '0';
    status(2) <= '1' when int_out = 0 else '0';
    status(3) <= '0' when int_out >= 0 else '1';

end Behavioral;
