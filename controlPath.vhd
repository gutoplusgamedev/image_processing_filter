


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std;
use ieee.std_logic_unsigned.all;


entity controlPath is
  Port ( 
        clk : in std_logic;
        rst_n : in std_logic;
        mode_i: in std_logic;
        start_i: in std_logic;
        wr_flag : out STD_LOGIC;
        pixel_sel: out std_LOGIC;
        neighbour_index: out integer range 0 to 8
  );
end controlPath;

architecture Behavioral of controlPath is

signal count_pixel : std_logic_vector(2 downto 0); 
type state_type is (S0, S1, S2); --state s1 e s2 do modo pixelate
signal state, next_state : state_type; 
begin

process(clk, rst_n)
begin
    if(rst_n = '0') then        
        state <= s0;
        neighbour_index <= 0;
    elsif (rising_edge(clk)) then
        state <= next_state;   
    end if;
end process;

NEXT_STATE_DECODE: process(state, start_i)
    begin
        case (state) is
            when s0 =>
                count_pixel <= (others => '0');
                if(start_i = '1') then
                    next_state <= s1;
                else
                    next_state <= s0;
                end if;
            when s1 =>
                count_pixel <= count_pixel + 1;
                next_state <= s2;

            when s2 =>
                count_pixel <= count_pixel + 1;
                next_state <= s1;
                neighbour_index <= neighbour_index + 1 when mode = '1' else '0';
            when others =>
                next_state <= s3;
        end case;
    end process;
        
pixel_sel <= '1' when state = s1 else
             '0' ;

wr_flag <= '1' when (count_pixel (2 downto 1) = "00" and (state = s1 or state = s2)) else
           '0';

end Behavioral;
