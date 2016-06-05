


---------------------------------------------------------------------
-- TITLE: Multiplication and Division Unit
-- AUTHORS: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 1/31/01
-- FILENAME: mult.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the multiplication and division unit in 32 clocks.
--
-- MULTIPLICATION
-- long64 answer = 0;
-- for(i = 0; i < 32; ++i)
-- {
--    answer = (answer >> 1) + (((b&1)?a:0) << 31);
--    b = b >> 1;
-- }
--
-- DIVISION
-- long upper=a, lower=0;
-- a = b << 31;
-- for(i = 0; i < 32; ++i)
-- {
--    lower = lower << 1;
--    if(upper >= a && a && b < 2)
--    {
--       upper = upper - a;
--       lower |= 1;
--    }
--    a = ((b&2) << 30) | (a >> 1);
--    b = b >> 1;
-- }
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.mlite_pack.all;

entity mult is
   generic(mult_type  : string := "DEFAULT");
   port(clk       : in std_logic;
        reset_in  : in std_logic;
        a, b      : in std_logic_vector(31 downto 0);
        mult_func : in mult_function_type;
        c_mult    : out std_logic_vector(31 downto 0);
        pause_out : out std_logic);
end; --entity mult

architecture logic of mult is

   constant MODE_MULT : std_logic := '1';
   constant MODE_DIV  : std_logic := '0';

   signal mode_reg    : std_logic;
   signal negate_reg  : std_logic;
   signal sign_reg    : std_logic;
   signal sign2_reg   : std_logic;
   signal count_reg   : std_logic_vector(4 downto 0);
   signal aa_reg      : std_logic_vector(33 downto 0);--(31 downto 0);
	signal a_reg2      : std_logic_vector(33 downto 0);
	signal a_reg3      : std_logic_vector(33 downto 0);
	signal a_neg2      : std_logic_vector(33 downto 0);
	signal a_neg3      : std_logic_vector(33 downto 0);
   signal bb_reg      : std_logic_vector(31 downto 0);
   signal upper_reg   : std_logic_vector(33 downto 0);
   signal lower_reg   : std_logic_vector(31 downto 0);

   signal a_neg       : std_logic_vector(33 downto 0);--(31 downto 0);
   signal b_neg       : std_logic_vector(31 downto 0);
   signal sum1         : std_logic_vector(34 downto 0);
   signal sum2         : std_logic_vector(34 downto 0);
   signal sum3         : std_logic_vector(34 downto 0);
	signal sum_a         : std_logic_vector(34 downto 0);
   signal sum_b1         : std_logic_vector(34 downto 0);
	signal sum_b2         : std_logic_vector(34 downto 0);
   signal sum_b3         : std_logic_vector(34 downto 0);
	signal b_reg2      : std_logic_vector(32 downto 0);
	signal b_reg3      : std_logic_vector(33 downto 0);
	signal b_neg2      : std_logic_vector(32 downto 0);
	signal b_neg3      : std_logic_vector(33 downto 0);
   
begin
 
   -- Result
   c_mult <= lower_reg when mult_func = MULT_READ_LO and negate_reg = '0' else 
             --bv_negate(lower_reg)
				 not(lower_reg) + 1 when mult_func = MULT_READ_LO 
                and negate_reg = '1' else
             upper_reg(31 downto 0) when mult_func = MULT_READ_HI and negate_reg = '0' else 
             --bv_negate(upper_reg)
				 not(upper_reg(31 downto 0)) + 1 when mult_func = MULT_READ_HI 
                and negate_reg = '1' else
             ZERO;
   pause_out <= '1' when (count_reg /= "00000") and 
             (mult_func = MULT_READ_LO or mult_func = MULT_READ_HI) else '0';

   -- ABS and remainder signals
   a_neg(31 downto 0) <= not(a) + 1;--a_neg <= bv_negate(a);
	a_neg(33 downto 32) <= a_neg(31) & a_neg(31);
	a_neg2(32 downto 0) <= not(a & '0') + 1;
	a_neg2(33) <= a_neg2(32);
	a_neg3 <= not((a(31) & a(31) & a) + (a(31) & a & '0')) + 1;
   b_neg <= not(b) + 1;--b_neg <= bv_negate(b);
	b_neg2 <= not(b & '0') + 1;
	b_neg3 <= not((b(31) & b(31) & b) + (b(31) & b & '0')) + 1;
   --sum <= bv_adder(upper_reg, aa_reg, mode_reg);
   sum_a <= '0' & upper_reg;
	sum_b1 <= '0' & aa_reg;
	sum_b2 <= '0' & a_reg2;
	sum_b3 <= '0' & a_reg3;
	with mode_reg select sum1 <= sum_a + sum_b1 when '1',
										 sum_a - sum_b1 when others;
	with mode_reg select sum2 <= sum_a + sum_b2 when '1',
											sum_a - sum_b2 when others;
	with mode_reg select sum3 <= sum_a + sum_b3 when '1',
											sum_a - sum_b3 when others;
	
   --multiplication/division unit
   mult_proc: process(clk, reset_in, a, b, mult_func,
      a_neg, b_neg, sum1, sign_reg, mode_reg, negate_reg, 
      count_reg, aa_reg, bb_reg, upper_reg, lower_reg, a_neg2, a_neg3, a_reg2, a_reg3, sum2, sum3)
      variable count : std_logic_vector(2 downto 0);
   begin
      count := "001";
      if reset_in = '1' then
         mode_reg <= '0';
         negate_reg <= '0';
         sign_reg <= '0';
         sign2_reg <= '0';
         count_reg <= "00000";
         aa_reg <= "00" & ZERO;
			a_reg2 <= "00" & ZERO;
			a_reg3 <= "00" & ZERO;
         bb_reg <= ZERO;
         upper_reg <= "00" & ZERO;
         lower_reg <= ZERO;
      elsif rising_edge(clk) then
         case mult_func is
            when MULT_WRITE_LO =>
               lower_reg <= a;
               negate_reg <= '0';
            when MULT_WRITE_HI =>
               upper_reg(31 downto 0) <= a;
               negate_reg <= '0';
            when MULT_MULT =>
               mode_reg <= MODE_MULT;
               aa_reg <= "00" & a;
					a_reg2 <= '0' & a & '0';
					a_reg3 <= ("00" & a) + ('0' & a & '0');
               bb_reg <= b;
               upper_reg <= "00" & ZERO;
               count_reg <= "10000";--"100000";
               negate_reg <= '0';
               sign_reg <= '0';
               sign2_reg <= '0';
            when MULT_SIGNED_MULT =>
               mode_reg <= MODE_MULT;
               if b(31) = '0' then
                  aa_reg <= a(31) & a(31) & a;
						a_reg2 <= a(31) & a & '0';
						a_reg3 <= (a(31) & a(31) & a) + (a(31) & a & '0');
                  bb_reg <= b;
               else
                  aa_reg <= a_neg;
						a_reg2 <= a_neg2;
						a_reg3 <= a_neg3;
                  bb_reg <= b_neg;
               end if;
               if a /= ZERO then
                  sign_reg <= a(31) xor b(31);
               else
                  sign_reg <= '0';
               end if;
               sign2_reg <= '0';
               upper_reg <= "00" & ZERO;
               count_reg <= "10000";--"100000";
               negate_reg <= '0';
            when MULT_DIVIDE =>
               mode_reg <= MODE_DIV;
               aa_reg <= "00" & b(1 downto 0) & ZERO(29 downto 0);--aa_reg(31 downto 0) <= b(0) & ZERO(30 downto 0);
               a_reg2 <= '0' & b(1 downto 0) & '0' & ZERO(29 downto 0);
					a_reg3 <= (("00" & b(1 downto 0)) + ('0' & b(1 downto 0) & '0')) & ZERO(29 downto 0);
					bb_reg <= b;
					b_reg2 <= b & '0';
					b_reg3 <= ('0' & b & '0') + ("00" + b);
               upper_reg(31 downto 0) <= a;
               count_reg <= "10000";
               negate_reg <= '0';
            when MULT_SIGNED_DIVIDE =>
               mode_reg <= MODE_DIV;
               if b(31) = '0' then
                  aa_reg(33 downto 30) <= "00" & b(1 downto 0);
						a_reg2(33 downto 30) <= '0' & b(1 downto 0) & '0';
						a_reg3(33 downto 30) <= (("00" & b(1 downto 0)) + ('0' & b(1 downto 0) & '0'));
                  bb_reg <= b;
						b_reg2 <= b & '0';
						b_reg3 <= ('0' & b & '0') + ("00" + b);
               else
                  aa_reg(33 downto 30) <= "00" & b_neg(1 downto 0);
						a_reg2(33 downto 30) <= '0' & b_neg2(2 downto 0);
						a_reg3(33 downto 30) <= b_neg3(3 downto 0);
                  bb_reg <= b_neg;
						b_reg2 <= b_neg2;
						b_reg3 <= b_neg3;
               end if;
               if a(31) = '0' then
                  upper_reg(31 downto 0) <= a;
               else
                  upper_reg(31 downto 0) <= a_neg(31 downto 0);
               end if;
               aa_reg(29 downto 0) <= ZERO(29 downto 0);
               a_reg2(29 downto 0) <= ZERO(29 downto 0);
               a_reg3(29 downto 0) <= ZERO(29 downto 0);
               count_reg <= "10000";
               negate_reg <= a(31) xor b(31);
            when others =>

               if count_reg /= "00000" then
                  if mode_reg = MODE_MULT then
                     -- Multiplication
                     if bb_reg(1 downto 0) = "11" then
                        upper_reg <= (sign_reg xor sum3(34)) & (sign_reg xor sum3(34)) & sum3(33 downto 2);
                        lower_reg <= sum3(1 downto 0) & lower_reg(31 downto 2);
                        sign2_reg <= sign2_reg or sign_reg;
                        sign_reg <= '0';
                        bb_reg <= "00" & bb_reg(31 downto 2);
							elsif bb_reg(1 downto 0) = "10" then
                        upper_reg <= (sign_reg xor sum2(34)) & (sign_reg xor sum2(34)) & sum2(33 downto 2);
                        lower_reg <= sum2(1 downto 0) & lower_reg(31 downto 2);
                        sign2_reg <= sign2_reg or sign_reg;
                        sign_reg <= '0';
                        bb_reg <= "00" & bb_reg(31 downto 2);
							elsif bb_reg(1 downto 0) = "01" then
                        upper_reg <= (sign_reg xor sum1(34)) & (sign_reg xor sum1(34)) & sum1(33 downto 2);
                        lower_reg <= sum1(1 downto 0) & lower_reg(31 downto 2);
                        sign2_reg <= sign2_reg or sign_reg;
                        sign_reg <= '0';
                        bb_reg <= "00" & bb_reg(31 downto 2);
--                     elsif bb_reg(3 downto 0) = "0000" and sign2_reg = '0' and 
--                           count_reg(5 downto 2) /= "0000" then
--                        upper_reg(31 downto 0) <= "0000" & upper_reg(31 downto 4);
--                        lower_reg <=  upper_reg(3 downto 0) & lower_reg(31 downto 4);
--                        count := "100";
--                        bb_reg <= "0000" & bb_reg(31 downto 4);
							else
                        upper_reg <= sign2_reg & sign2_reg & sign2_reg & sign2_reg & upper_reg(31 downto 2);
                        lower_reg <= upper_reg(1 downto 0) & lower_reg(31 downto 2);
                        bb_reg <= "00" & bb_reg(31 downto 2);
                     end if;
                  else   
                     -- Division
							if sum3(34) = '0' and a_reg3 /= ZERO and 
                           bb_reg(31 downto 2) = ZERO(31 downto 2) then
                        upper_reg <= sum3(33 downto 0);
                        lower_reg(1 downto 0) <= "11";
							elsif sum2(34) = '0' and a_reg2 /= ZERO and 
                           bb_reg(31 downto 2) = ZERO(31 downto 2) then
                        upper_reg <= sum2(33 downto 0);
                        lower_reg(1 downto 0) <= "10";
							elsif sum1(34) = '0' and aa_reg /= ZERO and 
                           bb_reg(31 downto 2) = ZERO(31 downto 2) then
                        upper_reg <= sum1(33 downto 0);
                        lower_reg(1 downto 0) <= "01";
                     else
                        lower_reg(1 downto 0) <= "00";
                     end if;
                     aa_reg <= "00" & bb_reg(3 downto 2) & aa_reg(31 downto 2);
							a_reg2 <= '0' & b_reg2(4 downto 2) & a_reg2(31 downto 2);
							a_reg3 <= b_reg3(5 downto 2) & a_reg3(31 downto 2);
                     lower_reg(31 downto 2) <= lower_reg(29 downto 0);
                     bb_reg <= "00" & bb_reg(31 downto 2);
							b_reg2 <= "00" & b_reg2(32 downto 2);
							b_reg3 <= "00" & b_reg3(33 downto 2);
--                     if sum1(32) = '0' and aa_reg /= ZERO and 
--                           bb_reg(31 downto 1) = ZERO(31 downto 1) then
--                        upper_reg(31 downto 0) <= sum1(31 downto 0);
--                        lower_reg(0) <= '1';
--                     else
--                        lower_reg(0) <= '0';
--                     end if;
--                     aa_reg(31 downto 0) <= bb_reg(1) & aa_reg(31 downto 1);
--                     lower_reg(31 downto 1) <= lower_reg(30 downto 0);
--                     bb_reg <= '0' & bb_reg(31 downto 1);
                  end if;
                  count_reg <= count_reg - count;
               end if; --count

         end case;
         
      end if;

   end process;
    
end; --architecture logic

