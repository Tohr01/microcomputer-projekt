library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity SPI_Master is
    Generic ( Quarz_Taktfrequenz : integer   := 50000000;  -- Hertz 
              SPI_Taktfrequenz   : integer   :=  1000000;  -- Hertz / zur Berechnung des Reload-Werts für Taktteiler
              Pre_Delay          : integer   :=   50;      -- us / Zeit nach Aktivieren von CS bis Beginn der Übertragung
              Post_Delay         : integer   :=   10;      -- us / Zeit nach Beenden der Übertragung bis Deaktivieren CS 
              Laenge             : integer   :=   32       -- Anzahl der zu übertragenden Bits
             ); 
    Port ( TX_Data  : in  STD_LOGIC_VECTOR (Laenge-1 downto 0); -- Sendedaten
           RX_Data  : out STD_LOGIC_VECTOR (Laenge-1 downto 0); -- Empfangsdaten
           CPHA     : in  STD_LOGIC;                            -- Clock Phase
           CPOL     : in  STD_LOGIC;                            -- Clock Polarity
           MOSI     : out STD_LOGIC;
           MISO     : in  STD_LOGIC;
           SCLK     : out STD_LOGIC;
           SS       : out STD_LOGIC;
           Start_TX : in  STD_LOGIC;
           TX_Done  : out STD_LOGIC;
           clk      : in  STD_LOGIC
         );
end SPI_Master;

architecture Behavioral of SPI_Master is
  signal   delay       : integer range 0 to (Quarz_Taktfrequenz/(2*SPI_Taktfrequenz));
  signal   delay_pre   : integer range 0 to (Pre_Delay*(Quarz_Taktfrequenz/1000))/1000;
  signal   delay_post  : integer range 0 to (Post_Delay*(Quarz_Taktfrequenz/1000))/1000;
  constant clock_delay : integer := (Quarz_Taktfrequenz/(2*SPI_Taktfrequenz))-1;
  
  type   spitx_states is (spi_stx,del_pre,spi_txactive,del_post,spi_etx);
  signal spitxstate    : spitx_states := spi_stx;

  type   spi_clkstates is (shift,sample);
  signal spiclkstate   : spi_clkstates;
  
  signal bitcounter    : integer range 0 to Laenge; -- wenn bitcounter = Laenge --> alle Bits uebertragen
  signal tx_reg        : std_logic_vector(Laenge-1 downto 0) := (others=>'0');
  signal rx_reg        : std_logic_vector(Laenge-1 downto 0) := (others=>'0');

begin
  ------ Verwaltung --------
  process begin 
     wait until rising_edge(CLK);
     MOSI <= tx_reg(tx_reg'left);
     delay_post  <= (Post_Delay*(Quarz_Taktfrequenz/1000))/1000; -- POST-Delay z.B. wenn SS# über Optokoppler 
     delay_pre   <= (Pre_Delay *(Quarz_Taktfrequenz/1000))/1000; -- Initial-Delay z.B. wg SS# über Optokoppler 
     if(delay>0) then delay <= delay-1;
     else             delay <= clock_delay;  
     end if;
     case spitxstate is
       when spi_stx =>
             SS          <= '1'; -- slave select disabled
             TX_Done     <= '0';
             bitcounter  <= Laenge;
             SCLK        <= CPOL;
             if(Start_TX = '1') then spitxstate <= del_pre; end if;

       when del_pre =>                                  -- SS aktivieren und Zeit fuer Optokoppler abwarten 
             SS          <= '0';
             SCLK        <= CPOL;
             if (CPHA='0') then spiclkstate <= sample;  -- sample at odd SCLK-edge  (1st, 3rd, 5th...)
             else               spiclkstate <= shift;   -- sample at even SCLK-edge (2nd, 4th, 6th...)
             end if;
             delay       <= 0;
             if (delay_pre>0) then 
                delay_pre  <= delay_pre-1;
             else
                spitxstate <= spi_txactive;
             end if;

       when spi_txactive =>  -- Daten aus tx_reg uebertragen
---------------------------------------- SPI-Takt generieren -----------------------------
             case spiclkstate is
               when sample =>
                       SCLK <= (CPOL xor CPHA); 
                       if (delay=0) then -- sample                     
                         spiclkstate <= shift;
                         if(CPHA='1') then bitcounter <= bitcounter-1;  end if;
                       end if;
                       
               when shift =>
                       SCLK <= not (CPOL xor CPHA); 
                       if (delay=0) then -- shift
                         spiclkstate <= sample; 
                         if(CPHA='0') then  bitcounter <= bitcounter-1;  end if;
                       end if;         
               end case;
               if (delay=0 and bitcounter=0) then -- alle Bits uebertragen -> deselektieren
                 SCLK       <= CPOL;
                 spitxstate <= del_post;
               end if;
---------------------------------------- SPI-Takt fertig  -----------------------------
       when del_post =>
             SS <= '1'; -- disable Slave Select 
             if (delay_post>0) then
               delay_post <= delay_post-1;
             else 
               spitxstate <= spi_etx;
             end if;

       when spi_etx =>
             TX_Done <= '1';
             if(Start_TX = '0') then -- Handshake: warten, bis Start-Flag geloescht
               spitxstate <= spi_stx;
             end if;
     end case;
  end process;   
  
  ---- Schieberegister in eigenem Prozess ist ressourcensparend -------
  process begin
     wait until rising_edge(clk);
--     if (spitxstate=del_pre) then  -- Initialisierung weglassen spart Ressourcen: 1 Mux = 10 Slices
--        rx_reg <= (others=>'0');
--     end if;
     if(spitxstate=spi_txactive and spiclkstate=sample and delay=0 and bitcounter/=0) then
        rx_reg <= rx_reg(rx_reg'left-1 downto 0) & MISO;
     end if;
     
     if (spitxstate=spi_stx) then
        tx_reg <= TX_Data;
     end if;
     if(spitxstate=spi_txactive and spiclkstate=shift and delay=0 and (cpha='0' or bitcounter/=Laenge)) then
        tx_reg <= tx_reg(tx_reg'left-1 downto 0) & tx_reg(0);
     end if;
  end process;   
  
  RX_Data    <= rx_reg;
  
end Behavioral;
