

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity dataPath is
    Port (  clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR (15 downto 0);
            wr_flag : in STD_LOGIC;
            mode: in std_logic;
            pixel_sel: in std_LOGIC;
            data_out : out STD_LOGIC_VECTOR (15 downto 0);      
            neighbour_index: in integer range 0 to 8;
            ready: out std_logic
           );
end dataPath;

architecture Behavioral of dataPath is

signal r_out, g_out, b_out, a_out : STD_LOGIC_VECTOR(7 downto 0);
type neighborhood is array(8 downto 0) of std_logic_vector(31 downto 0);
signal pixel_neighbours: neighborhood;
signal blur_result_r, blur_result_g, blur_result_b, blur_result_a: std_logic_vector(7 downto 0);

begin

process(clk, rst_n)
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
    elsif(rising_edge(clk)) then
        if(wr_flag = '1') then
            case pixel_sel is
                when '0' => 
                    r_out <= data_in(7 downto 0);
                    g_out <= data_in(15 downto 8);
                when others => 
                    b_out <= data_in(7 downto 0);
                    a_out <= data_in(15 downto 8);
                    pixel_neighbours(neighbour_index) <= r_out & g_out & b_out & a_out;
            end case;
        end if;  
    end if;
end process;

process(clk, neighbour_index)
begin
    if(rising_edge(clk) and neighbour_index = 8) then
        for i in range 0 to 8 loop
            blur_result_r <= conv_std_logic_vector(conv_integer(unsigned(blur_result_r)) + conv_integer(unsigned(pixel_neighbours(i)(7 downto 0))) / 9, 8);
            blur_result_g <= conv_std_logic_vector(conv_integer(unsigned(blur_result_g)) + conv_integer(unsigned(pixel_neighbours(i)(15 downto 8))) / 9, 8);
            blur_result_b <= conv_std_logic_vector(conv_integer(unsigned(blur_result_b)) + conv_integer(unsigned(pixel_neighbours(i)(23 downto 16))) / 9, 8);
            blur_result_a <= conv_std_logic_vector(conv_integer(unsigned(blur_result_a)) + conv_integer(unsigned(pixel_neighbours(i)(31 downto 24))) / 9, 8);
        end loop;
    else
            blur_result_r <= (others => '0');
            blur_result_g <= (others => '0');
            blur_result_b <= (others => '0');
            blur_result_a <= (others => '0');
    end if;     
end process;

data_out <= g_out & r_out when (pixel_sel = '1' and mode = '0') else
            a_out & b_out when (pixel_sel = '0' and mode = '0') else 
            blur_result_g & blur_result_r when (pixel_sel = '0' and mode = '1') else 
            blur_result_a & blur_result_b when (pixel_sel = '1' and mode = '1') else 
            (others => 'Z');

ready <= '1' when mode = '0' or (mode = '1' and neighbour_index = 8); --flag que controla quando o pixel atual está pronto para ser lido.

end Behavioral;
