#ifndef CT_DMA_H
#define CT_DMA_H

#define MM2S_DMACR  0x00
#define MM2S_DMASR  0x04
#define MM2S_SA     0x18
#define MM2S_SA_MSB 0x1C
#define MM2S_LENGTH 0x28
#define S2MM_DMACR  0x30
#define S2MM_DMASR  0x34
#define S2MM_DA     0x48
#define S2MM_DA_MSB 0x4C
#define S2MM_LENGTH 0x58

int init_ct_dma(void);
int init_ct_dma_tx(void);
int dma_tx(uint32_t* tx_buff, uint32_t len);
bool is_dma_tx_done(void);
uint32_t get_dma_tx_status_reg(void);
void clear_dma_tx_status_reg(void);
int init_ct_dma_rx(void);
int reset_ct_dma_rx(void);
int dma_rx(uint32_t* rx_buff, uint32_t len);
bool is_dma_rx_done(void);
uint32_t get_dma_rx_status_reg(void);
void clear_dma_rx_status_reg(void);

#endif
