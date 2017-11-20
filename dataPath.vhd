

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.std_logic_unsigned.all;

entity dataPath is
    Port (  
            clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR (15 downto 0);
            wr_flag : in STD_LOGIC;
            wr_blur: in std_logic;
            mode: in std_logic;
            pixel_sel: in std_LOGIC;
            data_out : out STD_LOGIC_VECTOR (15 downto 0);      
            neighbour_index: in integer range 0 to 8;
            ready: in std_logic
           );
end dataPath;

architecture Behavioral of dataPath is

signal r_out, g_out, b_out, a_out : STD_LOGIC_VECTOR(7 downto 0);
type neighborhood is array(8 downto 0) of std_logic_vector(31 downto 0);
signal pixel_neighbours: neighborhood;
signal blur_result_r, blur_result_g, blur_result_b, blur_result_a: std_logic_vector(7 downto 0);
--signal blur_test: std_logic_vector(11 downto 0);

begin

process(clk, rst_n, neighbour_index)
    variable blur_a_var, blur_g_var, blur_b_var, blur_r_var  : integer;
begin
    if(rst_n = '0') then
        r_out <= (others => '0');
        g_out <= (others => '0');
        b_out <= (others => '0');
        a_out <= (others => '0');
        blur_result_r <= (others => '0');
        blur_result_g <= (others => '0');
        blur_result_b <= (others => '0');
        blur_result_a <= (others => '0');
        blur_a_var := 0;
        blur_g_var := 0;
        blur_b_var := 0;
        blur_r_var := 0;
        for i in 0 to 8 loop
            pixel_neighbours(i) <= (others => '0');
        end loop;
    elsif(rising_edge(clk)) then
        if(wr_flag = '1' and mode = '0') then
            case pixel_sel is
                when '0' => 
                    r_out <= data_in(7 downto 0);
                    g_out <= data_in(15 downto 8);   
                when others => 
                    b_out <= data_in(7 downto 0);
                    a_out <= data_in(15 downto 8);
                    
            end case;        
        elsif (mode = '1') then
            case pixel_sel is
                    when '0' =>
                        pixel_neighbours(neighbour_index)(15 downto 0) <= data_in;
                    when others =>
                        pixel_neighbours(neighbour_index)(31 downto 16) <= data_in;
            end case;
        end if;
        
        if(wr_blur = '1') then
            --blur_result_r <= pixel_neighbours(neighbour_index)(7 downto 0);
            --blur_result_g <= pixel_neighbours(neighbour_index)(15 downto 8);
            --blur_result_b <= pixel_neighbours(neighbour_index)(23 downto 16);           
            blur_a_var := 0;
            blur_b_var := 0;
            blur_r_var := 0;
            blur_g_var := 0;
            for i in 0 to 8 loop
                --blur_result_r <= conv_std_logic_vector((conv_integer(unsigned(blur_result_r)) + conv_integer(unsigned(pixel_neighbours(i)(7 downto 0))) / 2), 8);
                --blur_result_g <= conv_std_logic_vector((conv_integer(unsigned(blur_result_g)) + conv_integer(unsigned(pixel_neighbours(i)(15 downto 8))) / 2), 8);
                --blur_result_b <= conv_std_logic_vector((conv_integer(unsigned(blur_result_b)) + conv_integer(unsigned(pixel_neighbours(i)(23 downto 16))) / 2), 8);
                --blur_result_a <= conv_std_logic_vector((conv_integer(unsigned(blur_result_a)) + conv_integer(unsigned(pixel_neighbours(i)(31 downto 24))) / 2), 8);
                blur_r_var := blur_r_var + conv_integer(unsigned(pixel_neighbours(i)(7 downto 0)));
                blur_g_var := blur_g_var + conv_integer(unsigned(pixel_neighbours(i)(15 downto 8)));
                blur_b_var := blur_b_var + conv_integer(unsigned(pixel_neighbours(i)(23 downto 16)));
                blur_a_var := blur_a_var + conv_integer(unsigned(pixel_neighbours(i)(31 downto 24)));
            end loop;
            blur_result_r <= conv_std_logic_vector(blur_r_var/9, 8);
            blur_result_g <= conv_std_logic_vector(blur_g_var/9, 8);           
            blur_result_b <= conv_std_logic_vector(blur_b_var/9, 8);
            blur_result_a <= conv_std_logic_vector(blur_a_var/9, 8);
            
        end if;  
    end if;
end process;


data_out <= g_out & r_out when (pixel_sel = '1' and mode = '0') else
            a_out & b_out when (pixel_sel = '0' and mode = '0') else 
            blur_result_g & blur_result_r when (pixel_sel = '1' and mode = '1') else 
            blur_result_a & blur_result_b when (pixel_sel = '0' and mode = '1'); 
            


end Behavioral;
