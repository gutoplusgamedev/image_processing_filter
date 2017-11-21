
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std;
use IEEE.STD_LOGIC_ARITH.ALL;

entity filter_tb is
end filter_tb;

architecture Behavioral of filter_tb is
component filter is
    Port ( data_in : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           mode_i: in std_logic;
           start_i : in STD_LOGIC;
           ready_o : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
end component;
    file red_output, green_output, blue_output, alpha_output : text; -- arquivos de saida
    file red_matrix, green_matrix, blue_matrix, alpha_matrix : text; -- arquivos de entrada
    signal data_in, data_out : STD_LOGIC_VECTOR (15 downto 0);
    signal start_i, clk, rst_n : std_logic := ('0');
    signal ready_o: std_logic;    
    signal mode_i: std_logic := '1';
    constant clk_period : time := 1 ns;
    constant path: string := "C:\Users\Miguel-Windows\imageFilter\imageFilter.srcs\sim_1\new\";
begin
    
    filter_inst: filter
    port map(
        data_in, 
        clk, 
        rst_n,          
        mode_i,
        start_i, 
        ready_o,
        data_out
    );

    process
        variable red_line, green_line, blue_line, alpha_line : line; -- uma linha da matriz de entrada
        variable red_outline, green_outline, blue_outline, alpha_outline : line; -- uma linha da matriz de saida
        variable red_term, green_term, blue_term, alpha_term : integer; --termo atual, pixel atual
        variable SPACE     : character; -- caractere de espaco
        variable I : integer range 0 to 600;
        variable J : integer range 0 to 1; -- selecao de qual pixel mandar
    begin
    rst_n <= '1' after clk_period/4 ;
    start_i <= '1' after clk_period/4 + 100 ps;
    -- arquivos de entrada/saida --
    file_open(red_matrix, path & "small_orig_red_matrix.txt" , read_mode);
    file_open(green_matrix, path & "small_orig_green_matrix.txt", read_mode);
    file_open(blue_matrix, path & "small_orig_blue_matrix.txt", read_mode);
    file_open(alpha_matrix, path & "small_orig_alpha_matrix.txt", read_mode);
    file_open(red_output, path & "small_orig_red_matrix_output.txt", write_mode);
    file_open(green_output, path & "small_orig_green_matrix_output.txt", write_mode);
    file_open(blue_output, path & "small_orig_blue_matrix_output.txt", write_mode);
    file_open(alpha_output, path & "small_orig_alpha_matrix_output.txt", write_mode);    
    while not endfile(red_matrix) loop -- enquanto nao acabar a matriz le linha por linha
        readline(red_matrix, red_line);
        readline(green_matrix, green_line);
        readline(blue_matrix, blue_line);
        readline(alpha_matrix, alpha_line);
        I := 0;
        while (I < 600) loop
            if (J = 0) then
                read(red_line, red_term); -- le um pixel da matriz vermelha
                read(red_line, SPACE);
                data_in(7 downto 0) <= conv_std_logic_vector(red_term, 8);
                read(green_line, green_term); -- le um pixel da matriz verde
                read(green_line, SPACE);
                data_in(15 downto 8) <= conv_std_logic_vector(green_term, 8); -- manda os dois pixels e espera um periodo de clock
                wait for clk_period;
                if(ready_o = '1') then -- se o pixel estiver pronto escreve no out      
                    write (red_outline, conv_integer(unsigned(data_out(7 downto 0))), right);
                    write (red_outline, SPACE, right); --write space
                    write (green_outline, conv_integer(unsigned(data_out(15 downto 8))), right);
                    write (green_outline, SPACE, right); --write space
                    I := I + 1;                            
                end if;
                J:= 1;
            else -- faz o mesmo do if só que com as matrizes blue e alpha
                read(blue_line, blue_term);
                read(blue_line, SPACE);
                data_in(7 downto 0) <= conv_std_logic_vector(blue_term, 8);
                read(alpha_line, alpha_term);
                read(alpha_line, SPACE);
                data_in(15 downto 8) <= conv_std_logic_vector(alpha_term, 8);
                wait for clk_period;
                if(ready_o = '1') then      
                    write (blue_outline, conv_integer(unsigned(data_out(7 downto 0))), right);
                    write (blue_outline, SPACE, right); --write space
                    write (alpha_outline, conv_integer(unsigned(data_out(15 downto 8))), right);
                    write (alpha_outline, SPACE, right); --write space
                    I := I + 1;
                end if;                
                J:= 0;
            end if;                                    
        end loop;
        --escreve a linha no arquivo      
        writeline(red_output, red_outline); 
        writeline(green_output, green_outline);
        writeline(blue_output, blue_outline);
        writeline(alpha_output, alpha_outline);
    end loop;
    file_close(red_matrix);
    file_close(green_matrix);
    file_close(blue_matrix);
    file_close(alpha_matrix);
    file_close(red_output);
    file_close(green_output);
    file_close(blue_output);
    file_close(alpha_output);
    wait;
    end process;
    
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;  
        clk <= '1';
        wait for clk_period/2;  
    end process;
    
end Behavioral;
