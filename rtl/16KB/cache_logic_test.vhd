--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:15:07 05/08/2016
-- Design Name:   
-- Module Name:   C:/Users/pdp/Desktop/plasma_PDP/plasma_ISE/cache_logic_test.vhd
-- Project Name:  plasma_ISE
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cache
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
 
ENTITY cache_logic_test IS
END cache_logic_test;
 
ARCHITECTURE behavior OF cache_logic_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cache
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         address_next : IN  std_logic_vector(31 downto 2);
         byte_we_next : IN  std_logic_vector(3 downto 0);
         cpu_address : IN  std_logic_vector(31 downto 2);
         mem_busy : IN  std_logic;
         cache_ram_enable : IN  std_logic;
         cache_ram_byte_we : IN  std_logic_vector(3 downto 0);
         cache_ram_address : IN  std_logic_vector(31 downto 2);
         cache_ram_data_w : IN  std_logic_vector(31 downto 0);
         cache_ram_data_r : OUT  std_logic_vector(31 downto 0);
         cache_access : OUT  std_logic;
         cache_checking : OUT  std_logic;
         cache_miss : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal address_next : std_logic_vector(31 downto 2) := (others => '0');
   signal byte_we_next : std_logic_vector(3 downto 0) := (others => '0');
   signal cpu_address : std_logic_vector(31 downto 2) := (others => '0');
   signal mem_busy : std_logic := '0';
   signal cache_ram_enable : std_logic := '0';
   signal cache_ram_byte_we : std_logic_vector(3 downto 0) := (others => '0');
   signal cache_ram_address : std_logic_vector(31 downto 2) := (others => '0');
   signal cache_ram_data_w : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal cache_ram_data_r : std_logic_vector(31 downto 0);
   signal cache_access : std_logic;
   signal cache_checking : std_logic;
   signal cache_miss : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cache PORT MAP (
          clk => clk,
          reset => reset,
          address_next => address_next,
          byte_we_next => byte_we_next,
          cpu_address => cpu_address,
          mem_busy => mem_busy,
          cache_ram_enable => cache_ram_enable,
          cache_ram_byte_we => cache_ram_byte_we,
          cache_ram_address => cache_ram_address,
          cache_ram_data_w => cache_ram_data_w,
          cache_ram_data_r => cache_ram_data_r,
          cache_access => cache_access,
          cache_checking => cache_checking,
          cache_miss => cache_miss
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
		reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset <= '0';
      wait for clk_period*10;
		
		address_next <= "00" & X"4000000";
		cache_ram_byte_we <= "1111";
		byte_we_next <= "1111";
		cpu_address <= "00" & X"4000000";
		mem_busy <= '0';
		cache_ram_enable <= '1';
		cache_ram_address <= "00" & X"4000000";
		cache_ram_data_w <= X"00000001";
      wait for clk_period*2;
		address_next <= "00" & X"4000001";
		cache_ram_address <= "00" & X"4000001";
		cache_ram_data_w <= X"00000002";
      wait for clk_period*2;	
		address_next <= "00" & X"4000800";
		cache_ram_address <= "00" & X"4000800";
		cpu_address <= "00" & X"4000800";
		cache_ram_data_w <= X"00000003";
      wait for clk_period*2;
		address_next <= "00" & X"4000801";
		cache_ram_address <= "00" & X"4000801";
		cpu_address <= "00" & X"4000801";
		cache_ram_data_w <= X"00000004";
      wait for clk_period*2;
		address_next <= "00" & X"40007FF";
		cache_ram_address <= "00" & X"40007FF";
		cache_ram_data_w <= X"00000006";
		wait for clk_period*2;
		cache_ram_byte_we <= "0000";
		byte_we_next <= "0000";
		address_next <= "00" & X"4000000";
		cache_ram_address <= "00" & X"4000000";
      wait for clk_period*2;
		address_next <= "00" & X"4000001";
		cache_ram_address <= "00" & X"4000001";
      wait for clk_period*2;
		address_next <= "00" & X"4000800";
		cache_ram_address <= "00" & X"4000800";
      wait for clk_period*2;
		address_next <= "00" & X"4000801";
		cache_ram_address <= "00" & X"4000801";
      wait for clk_period*2;
		-- insert stimulus here 

      wait;
   end process;

END;
