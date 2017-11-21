

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
        ready_o: out std_logic;
        wr_flag : out STD_LOGIC;
        wr_blur : out std_logic;
        pixel_sel: out std_LOGIC;
        neighbour_index: out integer range 0 to 8
  );
end controlPath;

architecture Behavioral of controlPath is

signal count_pixel : std_logic_vector(2 downto 0);
signal full_flag, pixel_selection_signal, blur_init : std_logic;
signal neighbour_index_buff: integer range 0 to 8; 
type state_type is (S0, S1, S2); --state s0 = estado inicial, esperando start, s1 e s2 alternam para definir os pixeis que sao mandados para a saida
signal state, next_state : state_type; 
begin

process(clk, rst_n)
begin
    if(rst_n = '0') then        
        state <= s0;
    elsif (rising_edge(clk)) then
        state <= next_state;   
    end if;
end process;

NEXT_STATE_DECODE: process(state, start_i)
    begin
        case (state) is
            when s0 =>
                count_pixel <= (others => '0');
                neighbour_index_buff <= 0;
                full_flag <= '0';
                blur_init <= '0';
                if(start_i = '1') then
                    next_state <= s1;
                else
                    next_state <= s0;
                end if;
            when s1 =>                
                if (mode_i = '1' and neighbour_index_buff = 0 and full_flag = '1') then --necessario para sincronizar e comecar a processar no estado s1
                    blur_init <= '1'; --variavel para controle externo do ready no modo blur
                else
                    count_pixel <= count_pixel + 1; -- variavel utilizada como controle para saber quando o pixel pode ser descartado no modo pixelate
                end if;                
                next_state <= s2;                
            when s2 =>                                
                if(mode_i = '1') then -- somente no modo blur
                    if (neighbour_index_buff < 8) then -- incrementa o index do buffer de vizinhos se o index for menor q 8
                        neighbour_index_buff <= neighbour_index_buff + 1; 
                    else
                        full_flag <= '1'; -- flag necessaria para saber quando o buffer ja esta cheio, ou seja, podemos comecar a processar
                        neighbour_index_buff <= 0; -- zera o index do buffer de vizinhos
                    end if;                    
                else
                    count_pixel <= count_pixel + 1;
                end if;
                
                next_state <= s1;
        end case;
    end process;
        
pixel_selection_signal <= '1' when state = s1 else --selecao de qual pixel e lido e guardado
             '0' ;

pixel_sel <= pixel_selection_signal;

wr_flag <= '1' when (count_pixel (2 downto 1) = "00" and (next_state = s1 or next_state = s2)) else -- flag utilzada para controlar os pixeis escritos no efeito pixelate
           '0';

neighbour_index <= neighbour_index_buff when mode_i = '1' else 0; -- deixa o index sempre em zero no modo 0 para gravar o efeito pixelado

ready_o <= '1' when ((state = s1 or state = s2) and mode_i = '0') or (blur_init = '1') else --sinal para controle externo, ack para verificar se o dado da saida e utilizavel
           '0';

wr_blur <= full_flag and not pixel_selection_signal; -- sinal para saber onde escrever o pixel do blur

end Behavioral;
