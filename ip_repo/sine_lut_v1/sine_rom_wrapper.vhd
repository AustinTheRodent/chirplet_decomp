-- Quartus Prime VHDL Template
-- Single port RAM with single read/write address 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_rom_wrapper is
    generic
    (
        constant DWIDTH : natural range 1 to 64 := 16
    );
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        
        dout : out std_logic_vector(DWIDTH-1 downto 0);
        dout_valid : out std_logic;
        dout_ready : in std_logic
    );
end entity;

architecture rtl of sine_rom_wrapper is

    component sine_rom is

        generic 
        (
            DATA_WIDTH : natural := 16;
            ADDR_WIDTH : natural := 8
        );

        port 
        (
            clk		: in std_logic;
            addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
            q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
        );

    end component;

    constant ADDR_BITS : natural range 1 to 256 := 8;
    constant SAMPLES_USED : natural range 1 to 10000 := 200;

    signal delay : std_logic;
    signal buffer_filled : std_logic;
    signal refill_buf : std_logic;
    signal rom_addr : natural range 0 to 2**ADDR_BITS-1;
    signal dout_buf : std_logic_vector(DWIDTH-1 downto 0);
    signal use_buffer : std_logic;
    
    signal rom_q : std_logic_vector(DWIDTH-1 downto 0);
    
    signal dout_valid_int : std_logic;


begin

    dout_valid <= dout_valid_int;
    dout <= dout_buf when use_buffer = '1' else rom_q;

    p_rom_sync : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                delay <= '0';
                buffer_filled <= '0';
                dout_buf <= (others => '0');
                dout_valid_int <= '0';
                use_buffer <= '0';
                rom_addr <= 0;
                refill_buf <= '0';
            else
                if delay = '0' then
                    delay <= '1';
                elsif buffer_filled = '0' then 
                    dout_buf <= rom_q;
                    buffer_filled <= '1';
                    dout_valid_int <= '1';
                    use_buffer <= '1';
                    rom_addr <= rom_addr + 1;
                elsif use_buffer = '1' and dout_ready = '1' then
                    refill_buf <= '0';
                    if rom_addr = SAMPLES_USED-1 then
                        rom_addr <= 0;
                    else
                        rom_addr <= rom_addr + 1;
                    end if;
                    dout_buf <= rom_q;
                    use_buffer <= '0';
                elsif use_buffer = '0' and dout_ready = '1' then
                    refill_buf <= '0';
                    dout_buf <= rom_q;
                    if rom_addr = SAMPLES_USED-1 then
                        rom_addr <= 0;
                    else
                        rom_addr <= rom_addr + 1;
                    end if;
                else
                    if refill_buf = '0' then
                        dout_buf <= rom_q;
                        refill_buf <= '1';
                    end if;
                    use_buffer <= '1';
                end if;
            end if;
        end if;
    end process;
    
    rom : sine_rom
        generic map
        (
            DATA_WIDTH => DWIDTH,
            ADDR_WIDTH => ADDR_BITS
        )
        port map
        (
            clk => clk,
            addr => rom_addr,
            q => rom_q
        );

end rtl;
















