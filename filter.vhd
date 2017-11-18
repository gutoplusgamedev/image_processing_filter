

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity filter is
    Port ( data_in : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
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
            pixel_sel: in std_LOGIC;
            data_out : out STD_LOGIC_VECTOR (15 downto 0)          
           );
end component;
component controlPath is
    port(
            clk : in std_logic;
            rst_n : in std_logic;
            wr_flag : out STD_LOGIC;
            pixel_sel: out std_LOGIC
    );
end component;

signal pixel_sel : std_logic;
signal wr_flag: std_logic;

begin

data: dataPath
    port map(
    clk => clk, 
    rst_n => rst_n,
    data_in => data_in,
    wr_flag => wr_flag, 
    pixel_sel => pixel_sel,
    data_out => data_out
    );

control_path: controlPath
    port map(
    clk => clk,
    rst_n => rst_n,
    wr_flag => wr_flag,
    pixel_sel => pixel_sel
    );

end Behavioral;
