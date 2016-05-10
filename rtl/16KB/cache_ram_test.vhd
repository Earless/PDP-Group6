--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:30:09 05/08/2016
-- Design Name:   
-- Module Name:   C:/Users/pdp/Desktop/plasma_PDP/plasma_ISE/cache_ram_test.vhd
-- Project Name:  plasma_ISE
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cache_ram
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cache_ram_test IS
END cache_ram_test;
 
ARCHITECTURE behavior OF cache_ram_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cache_ram
    PORT(
         clk : IN  std_logic;
         enable : IN  std_logic;
         write_byte_enable : IN  std_logic_vector(3 downto 0);
         address : IN  std_logic_vector(31 downto 2);
         data_write : IN  std_logic_vector(31 downto 0);
         data_read : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal enable : std_logic := '0';
   signal write_byte_enable : std_logic_vector(3 downto 0) := (others => '0');
   signal address : std_logic_vector(31 downto 2) := (others => '0');
   signal data_write : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal data_read : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cache_ram PORT MAP (
          clk => clk,
          enable => enable,
          write_byte_enable => write_byte_enable,
          address => address,
          data_write => data_write,
          data_read => data_read
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		enable <= '1';
		write_byte_enable <= "1111";
		address <=  "00" & X"4000000";
		data_write <= X"00000001";
		wait for clk_period*2;
		address <=  "00" & X"4000001";
		data_write <= X"00000002";
		wait for clk_period*2;
		address <=  "00" & X"40007FF";
		data_write <= X"00000003";
		wait for clk_period*2;
		address <=  "00" & X"4000800";
		data_write <= X"00000004";
		wait for clk_period*2;
		address <=  "00" & X"4000801";
		data_write <= X"00000005";
		wait for clk_period*2;
		write_byte_enable <= "0000";
		address <=  "00" & X"4000000";
		data_write <= X"00000001";
		wait for clk_period*2;
		address <=  "00" & X"4000001";
		data_write <= X"00000002";
		wait for clk_period*2;
		address <=  "00" & X"40007FF";
		data_write <= X"00000003";
		wait for clk_period*2;
		address <=  "00" & X"4000800";
		data_write <= X"00000004";
		wait for clk_period*2;
		address <=  "00" & X"4000801";
		data_write <= X"00000005";
		
      -- insert stimulus here 

      wait;
   end process;

END;
