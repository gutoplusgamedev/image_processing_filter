
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
            wr_flag: in STD_LOGIC;
            wr_blur: in std_logic;
            mode: in std_logic;
            pixel_sel: in std_LOGIC;
            ready: in std_logic;       
            neighbour_index: in integer range 0 to 8;            
            data_out : out STD_LOGIC_VECTOR (15 downto 0)
           );
end dataPath;

architecture Behavioral of dataPath is

type neighborhood is array(8 downto 0) of std_logic_vector(31 downto 0);
signal pixel_neighbours: neighborhood; -- pequeno buffer de pixeis necessarios para o calculo do filtro blur
signal blur_result_r, blur_result_g, blur_result_b, blur_result_a: std_logic_vector(7 downto 0); -- registradores que guardam o resultado do efeito blur

begin

process(clk, rst_n, neighbour_index)
    variable blur_a_var, blur_g_var, blur_b_var, blur_r_var  : integer; -- variaveis utilizadas para guardar a aritmetica do efeito blur
begin
    if(rst_n = '0') then        
        blur_result_r <= (others => '0');
        blur_result_g <= (others => '0');
        blur_result_b <= (others => '0');
        blur_result_a <= (others => '0');
        for i in 0 to 8 loop
            pixel_neighbours(i) <= (others => '0');
        end loop;
    elsif(rising_edge(clk)) then
        if((wr_flag = '1' and mode = '0') or mode = '1') then   -- quando o efeito for o pixelate e precisamos guardar o pixel ou quando o modo for blur onde guardamos todos os pixels
            case pixel_sel is -- como a saída tem 16 bits, serializamos os 32 bits necessarios para cada pixel (8 de cada cor)
                when '0' => 
                    pixel_neighbours(neighbour_index)(15 downto 0) <= data_in;   
                when others => 
                    pixel_neighbours(neighbour_index)(31 downto 16) <= data_in;                    
            end case;        
        end if;
        
        if(wr_blur = '1') then -- quando tivermos os vizinhos o processamento do blur e possivel.                     
            blur_a_var := 0;
            blur_b_var := 0;
            blur_r_var := 0;
            blur_g_var := 0;
            for i in 0 to 8 loop               
                blur_r_var := blur_r_var + conv_integer(unsigned(pixel_neighbours(i)(7 downto 0))); -- soma de todos os vizinhos
                blur_g_var := blur_g_var + conv_integer(unsigned(pixel_neighbours(i)(15 downto 8)));
                blur_b_var := blur_b_var + conv_integer(unsigned(pixel_neighbours(i)(23 downto 16)));
                blur_a_var := blur_a_var + conv_integer(unsigned(pixel_neighbours(i)(31 downto 24)));
            end loop;
            blur_result_r <= conv_std_logic_vector(blur_r_var/9, 8); -- divisao pelo numero de vizinhos, fazendo uma media
            blur_result_g <= conv_std_logic_vector(blur_g_var/9, 8);           
            blur_result_b <= conv_std_logic_vector(blur_b_var/9, 8);
            blur_result_a <= conv_std_logic_vector(blur_a_var/9, 8);            
        end if;  
    end if;
end process;

data_out <= pixel_neighbours(0)(15 downto 0) when (pixel_sel = '1' and mode = '0') else -- o pixel referente ao pixelate fica guardado nesse buffer quando o mode for 0
            pixel_neighbours(0)(31 downto 16) when (pixel_sel = '0' and mode = '0') else 
            blur_result_g & blur_result_r when (pixel_sel = '1' and mode = '1') else -- passamos o resultado do blur quando o modo for um
            blur_result_a & blur_result_b when (pixel_sel = '0' and mode = '1'); 
            
end Behavioral;
