

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity dataPath is
    Port (  clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR (15 downto 0);
            wr_flag : in STD_LOGIC;
            pixel_sel: in std_LOGIC;
            data_out : out STD_LOGIC_VECTOR (15 downto 0)          
           );
end dataPath;

architecture Behavioral of dataPath is

signal r_out, g_out, b_out, a_out : STD_LOGIC_VECTOR(7 downto 0);

begin

process(clk, rst_n)
begin
    if(rst_n = '0') then
        r_out <= (others => '0');
        g_out <= (others => '0');
        b_out <= (others => '0');
        a_out <= (others => '0');
    elsif(rising_edge(clk)) then
        if(wr_flag = '1') then
            case pixel_sel is
                when '0' => 
                    r_out <= data_in(7 downto 0);
                    g_out <= data_in(15 downto 8);
                when others => 
                    b_out <= data_in(7 downto 0);
                    a_out <= data_in(15 downto 8);
            end case;
        end if;            
    end if;
end process;

data_out <= g_out & r_out when(pixel_sel = '1') else
            a_out & b_out;

end Behavioral;
