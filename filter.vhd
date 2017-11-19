

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity filter is
    Port ( data_in : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           mode: in std_logic;
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
            data_out : out STD_LOGIC_VECTOR (15 downto 0);
            neighbour_index: out integer range 0 to 8;
            ready: out std_logic 
           );
end component;
component controlPath is
    port(
            clk : in std_logic;
            rst_n : in std_logic;
            wr_flag : out STD_LOGIC;
            pixel_sel: out std_LOGIC;
            neighbour_index: in integer range 0 to 8
    );
end component;

signal pixel_sel : std_logic;
signal wr_flag: std_logic;
signal neighbour_index: integer range 0 to 8;
signal ready: std_logic;

begin

ready_o <= ready;

data: dataPath
    port map(
    clk => clk, 
    rst_n => rst_n,
    data_in => data_in,
    wr_flag => wr_flag,
    mode => mode,
    pixel_sel => pixel_sel,
    data_out => data_out,
    neighbour_index => neighbour_index
    );

control_path: controlPath
    port map(
    clk => clk,
    rst_n => rst_n,
    wr_flag => wr_flag,
    pixel_sel => pixel_sel
    neighbour_index => neighbour_index
    );

end Behavioral;
