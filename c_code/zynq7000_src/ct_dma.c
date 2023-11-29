#include <stdint.h>
#include <stdbool.h>
#include "xil_cache.h"
#include "xparameters.h"
#include "ct_dma.h"

#define BYTES_PER_32BIT 4

int init_ct_dma(void)
{
  init_ct_dma_tx();
  init_ct_dma_rx();
  return 0;
}

int init_ct_dma_tx(void)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;
  dma_ptr[MM2S_DMACR/BYTES_PER_32BIT] = 0b10; // reset
  dma_ptr[MM2S_DMACR/BYTES_PER_32BIT] = 0;
  dma_ptr[MM2S_DMACR/BYTES_PER_32BIT] = 0b1000000000001; //IOC_IrqEn, run
  return 0;
}

int dma_tx(uint32_t* tx_buff, uint32_t len)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;

  // flush buffer out of cache
  Xil_DCacheFlushRange((uint32_t)tx_buff, len);

  dma_ptr[MM2S_SA/BYTES_PER_32BIT] = (uint32_t)&tx_buff[0];
  dma_ptr[MM2S_SA_MSB/BYTES_PER_32BIT] = 0;
  dma_ptr[MM2S_LENGTH/BYTES_PER_32BIT] = len;
  return 0;
}

bool is_dma_tx_done(void)
{
  if((get_dma_tx_status_reg() & (1<<12)) == 0)
  {
    return false;
  }
  else
  {
    clear_dma_tx_status_reg();
    return true;
  }
}

uint32_t get_dma_tx_status_reg(void)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;
  return (uint32_t)dma_ptr[MM2S_DMASR/BYTES_PER_32BIT];
}

void clear_dma_tx_status_reg(void)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;
  dma_ptr[MM2S_DMASR/BYTES_PER_32BIT] = 0xFFFFFFFF;
}

int init_ct_dma_rx(void)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;
  dma_ptr[S2MM_DMACR/BYTES_PER_32BIT] = 0b10; // reset
  dma_ptr[S2MM_DMACR/BYTES_PER_32BIT] = 0;
  dma_ptr[S2MM_DMACR/BYTES_PER_32BIT] = 0b1000000000001; //IOC_IrqEn, run
  return 0;
}

int reset_ct_dma_rx(void)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;
  dma_ptr[S2MM_DMACR/BYTES_PER_32BIT] = 0b10; // reset
  //dma_ptr[S2MM_DMACR/BYTES_PER_32BIT] = 0;
  return 0;
}

int dma_rx(uint32_t* rx_buff, uint32_t len)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;

  dma_ptr[S2MM_DA/BYTES_PER_32BIT] = (uint32_t)&rx_buff[0];
  dma_ptr[S2MM_DA_MSB/BYTES_PER_32BIT] = 0;
  dma_ptr[S2MM_LENGTH/BYTES_PER_32BIT] = len;

  // invalidate buffer in cache
  Xil_DCacheInvalidateRange((uint32_t)rx_buff, len);

  return 0;
}

bool is_dma_rx_done(void)
{
  if((get_dma_rx_status_reg() & (1<<12)) == 0)
  {
    return false;
  }
  else
  {
    clear_dma_rx_status_reg();
    return true;
  }
}

uint32_t get_dma_rx_status_reg(void)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;
  return (uint32_t)dma_ptr[S2MM_DMASR/BYTES_PER_32BIT];
}

void clear_dma_rx_status_reg(void)
{
  uint32_t* dma_ptr = XPAR_AXI_DMA_0_BASEADDR;
  dma_ptr[S2MM_DMASR/BYTES_PER_32BIT] = 0xFFFFFFFF;
}
