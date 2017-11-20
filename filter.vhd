

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity filter is
    Port ( data_in : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           mode_i: in std_logic;
           start_i : in STD_LOGIC;
           ready_o : out STD_LOGIC;
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
end filter;

architecture Behavioral of filter is
component dataPath is
     Port (  
            clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR (15 downto 0);
            wr_flag : in STD_LOGIC;
            mode: in std_logic;
            pixel_sel: in std_LOGIC;
            wr_blur: in std_logic;
            data_out : out STD_LOGIC_VECTOR (15 downto 0);
            neighbour_index: in integer range 0 to 8;
            ready: in std_logic 
           );
end component;
component controlPath is
    port(
            clk : in std_logic;
            rst_n : in std_logic;
            mode_i: in std_logic;
            start_i: in std_logic;
            ready_o: out std_logic;
            wr_flag : out STD_LOGIC;
            wr_blur: out std_logic;
            pixel_sel: out std_LOGIC;
            neighbour_index: out integer range 0 to 8
    );
end component;

signal pixel_sel : std_logic;
signal wr_flag, wr_blur: std_logic;
signal ready_out: std_logic;
signal neighbour_index: integer range 0 to 8;

begin

ready_o <= ready_out; --when (mode_i = '0') else
           --(ready_out and wr_blur);


data: dataPath
    port map(
    clk => clk, 
    rst_n => rst_n,
    data_in => data_in,
    wr_flag => wr_flag,
    mode => mode_i,
    pixel_sel => pixel_sel,
    data_out => data_out,
    wr_blur => wr_blur,
    neighbour_index => neighbour_index,
    ready => ready_out
    );

control_path: controlPath
    port map(
    clk => clk,
    rst_n => rst_n,
    mode_i => mode_i,
    start_i => start_i,
    ready_o => ready_out,
    wr_flag => wr_flag,
    wr_blur => wr_blur,
    pixel_sel => pixel_sel,
    neighbour_index => neighbour_index
    );

end Behavioral;
