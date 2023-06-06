
#include "sleep.h"
#include "xuartps.h"
#include "xparameters.h"
#include "xil_types.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "platform.h"
#include "xil_printf.h"

#include "ct_dma.h"

#define CT_CONTROL                  0x000
#define CT_STATUS                   0x004
#define CT_CHIRP_GEN_NUM_SAMPS_OUT  0x008
#define CT_DIN_TAU                  0x00C
#define CT_DIN_T_STEP               0x010
#define CT_DIN_ALPHA1               0x014
#define CT_DIN_F_C                  0x018
#define CT_DIN_ALPHA2               0x01C
#define CT_DIN_PHI                  0x020
#define CT_DIN_BETA                 0x024
#define CT_XCORR_REF_SAMP           0x028
#define CT_XCORR_DOUT_RE_MSBS       0x02C
#define CT_XCORR_DOUT_RE_LSBS       0x030
#define CT_XCORR_DOUT_IM_MSBS       0x034
#define CT_XCORR_DOUT_IM_LSBS       0x038
#define CT_CHIRPLET_FEEDBACK        0x03C
#define CT_LED_CONTROL              0x040

#define BYTES_PER_32BIT 4

#define MAX_SAMPLES 50000

XUartPs Uart_Ps; // Instance of the UART Device
int16_t received_samples[MAX_SAMPLES];

uint16_t read_file(void);
//int PS_test(void);
int init_uart_command_line(uint16_t DeviceId);
void wait_for_buttonpress(void);


int main()
{

  int i = 0;
  uint32_t* chirplet_transform_reg_ptr = XPAR_CHIRPLET_DECOMP_TOP_0_BASEADDR;

  uint16_t file_length;

  uint32_t tmp_buff_tx[512];
  uint32_t tmp_buff_rx[512];

  uint32_t status_reg;

  chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 0;

  init_uart_command_line(UART_DEVICE_ID);
  init_ct_dma();

  chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 1;

  wait_for_buttonpress();

  file_length = read_file();

  for(i=0;i<file_length;i++)
  {
    tmp_buff_tx[i] = (received_samples[i*2] << 16) | (received_samples[i*2+1] & 0xFFFF);
  }

  dma_tx(tmp_buff_tx, 512*4);

  //dma_rx(tmp_buff_rx, 512*4);
  //usleep(100000);
  //xil_printf("is_dma_tx_done(): %u\r\n", is_dma_tx_done());
  //usleep(100000);
  //xil_printf("is_dma_tx_done(): %u\r\n", is_dma_tx_done());

  status_reg = chirplet_transform_reg_ptr[CT_STATUS/BYTES_PER_32BIT];

  if((status_reg & 0x2) != 0) // xcorr valid
  {
    xil_printf("warning: xcorr output is valid before it should be\r\n");
  }

  if((status_reg & 0x1) != 0) // chirp_gen ready
  {
    xil_printf("chirplet generator is ready\r\n");
  }

  xil_printf("CT_STATUS: %0X\r\n", status_reg);




  chirplet_transform_reg_ptr[CT_CHIRP_GEN_NUM_SAMPS_OUT/BYTES_PER_32BIT] = 0x0040;
  chirplet_transform_reg_ptr[CT_DIN_T_STEP/BYTES_PER_32BIT]              = 0x322bcc77;
  chirplet_transform_reg_ptr[CT_DIN_TAU/BYTES_PER_32BIT]                 = 0x362bcc77;
  chirplet_transform_reg_ptr[CT_DIN_ALPHA1/BYTES_PER_32BIT]              = 0x5368d4a5;
  chirplet_transform_reg_ptr[CT_DIN_F_C/BYTES_PER_32BIT]                 = 0x4a895440;
  chirplet_transform_reg_ptr[CT_DIN_ALPHA2/BYTES_PER_32BIT]              = 0x5368d4a5;
  chirplet_transform_reg_ptr[CT_DIN_PHI/BYTES_PER_32BIT]                 = 0x3f400000;
  chirplet_transform_reg_ptr[CT_DIN_BETA/BYTES_PER_32BIT]                = 0x3e800000;

  status_reg = chirplet_transform_reg_ptr[CT_STATUS/BYTES_PER_32BIT];
  while((status_reg & 0x2) == 0)
  {
    status_reg = chirplet_transform_reg_ptr[CT_STATUS/BYTES_PER_32BIT];
  }

  xil_printf("CT_XCORR_DOUT_RE_MSBS: %08X\r\n", chirplet_transform_reg_ptr[CT_XCORR_DOUT_RE_MSBS/BYTES_PER_32BIT]);
  xil_printf("CT_XCORR_DOUT_RE_LSBS: %08X\r\n", chirplet_transform_reg_ptr[CT_XCORR_DOUT_RE_LSBS/BYTES_PER_32BIT]);
  xil_printf("CT_XCORR_DOUT_IM_MSBS: %08X\r\n", chirplet_transform_reg_ptr[CT_XCORR_DOUT_IM_MSBS/BYTES_PER_32BIT]);
  xil_printf("CT_XCORR_DOUT_IM_LSBS: %08X\r\n", chirplet_transform_reg_ptr[CT_XCORR_DOUT_IM_LSBS/BYTES_PER_32BIT]);

  status_reg = chirplet_transform_reg_ptr[CT_STATUS/BYTES_PER_32BIT];
  //usleep(100000);
  xil_printf("CT_STATUS: %0X\r\n", status_reg);


  //usleep(100000);
  //xil_printf("is_dma_rx_done(): %u\r\n", is_dma_rx_done());
  //usleep(100000);
  //xil_printf("is_dma_rx_done(): %u\r\n", is_dma_rx_done());


  //PS_test();

  while(1)
  {
    //xil_printf("%i\r\n", i*2);
    //chirplet_transform_reg_ptr[16] = ~chirplet_transform_reg_ptr[16];
    chirplet_transform_reg_ptr[CT_LED_CONTROL/BYTES_PER_32BIT] = ~chirplet_transform_reg_ptr[CT_LED_CONTROL/BYTES_PER_32BIT];
    usleep(1000000);
    //i++;
  }

  return 0;

}

int init_uart_command_line(uint16_t DeviceId)
{
  int status;
  uint32_t ModeRegister;
  XUartPs_Config *Config;
  XUartPs *InstancePtr = &Uart_Ps;

  Config = XUartPs_LookupConfig(DeviceId);
  if (Config == NULL)
  {
    return XST_FAILURE;
  }

  status = XUartPs_CfgInitialize(&Uart_Ps, Config, Config->BaseAddress);
  if (status != XST_SUCCESS) {
    return XST_FAILURE;
  }

  // Assert validates the input arguments
  Xil_AssertNonvoid(InstancePtr != NULL);
  Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

  // Disable all interrupts in the interrupt disable register
  XUartPs_WriteReg(InstancePtr->Config.BaseAddress, XUARTPS_IDR_OFFSET,
    XUARTPS_IXR_MASK);

  // set UART mode to normal
  ModeRegister = XUartPs_ReadReg(InstancePtr->Config.BaseAddress,
           XUARTPS_MR_OFFSET);
  XUartPs_WriteReg(InstancePtr->Config.BaseAddress, XUARTPS_MR_OFFSET,
         ((ModeRegister & (u32)(~XUARTPS_MR_CHMODE_MASK)) |
        (u32)XUARTPS_MR_CHMODE_NORM));
  return XST_SUCCESS;
}

void wait_for_buttonpress(void)
{
  uint32_t ReceiveDataResult;
  XUartPs *InstancePtr = &Uart_Ps;

  uint8_t tmp_byte;

  xil_printf("press any key to continue...\r\n");
  ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
    XUARTPS_SR_RXEMPTY;
  while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
  {
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
  }
  (void)XUartPs_Recv(InstancePtr, &tmp_byte, 1U);

}

uint16_t read_file(void)
{
  bool pass = true;
  uint32_t i,j;
  uint32_t ReceiveDataResult;
  XUartPs *InstancePtr = &Uart_Ps;

  uint8_t data_len_byte;
  uint8_t sample_byte;
  uint16_t data_len;

  xil_printf("send binary file...\r\n");

  // Data Length 8 LSBs:
  ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
    XUARTPS_SR_RXEMPTY;
  while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
  {
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
  }
  (void)XUartPs_Recv(InstancePtr, &data_len_byte, 1U);
  data_len = data_len_byte;

  // Data Length 8 MSBs:
  ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
    XUARTPS_SR_RXEMPTY;
  while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
  {
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
  }
  (void)XUartPs_Recv(InstancePtr, &data_len_byte, 1U);
  data_len |= data_len_byte << 8;

  // print data len:
  xil_printf("data len: %i\r\n", data_len);

  for(i=0;i<data_len;i++)
  {
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
    {
      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
        XUARTPS_SR_RXEMPTY;
    }
    (void)XUartPs_Recv(InstancePtr, &sample_byte, 1U);
    received_samples[i*2] = sample_byte;
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
    {
      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
        XUARTPS_SR_RXEMPTY;
    }
    (void)XUartPs_Recv(InstancePtr, &sample_byte, 1U);
    received_samples[i*2] |= sample_byte << 8;

    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
    {
      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
        XUARTPS_SR_RXEMPTY;
    }
    (void)XUartPs_Recv(InstancePtr, &sample_byte, 1U);
    received_samples[i*2+1] = sample_byte;
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
    {
      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
        XUARTPS_SR_RXEMPTY;
    }
    (void)XUartPs_Recv(InstancePtr, &sample_byte, 1U);
    received_samples[i*2+1] |= sample_byte << 8;
  }

  //for(i=0;i<data_len;i++)
  //{
  //  xil_printf("I[%i]: %i\t", i, received_samples[i*2]);
  //  xil_printf("Q[%i]: %i\r\n", i, received_samples[i*2+1]);
  //}

  return data_len;
}

//int PS_test(void)
//{
//  bool pass = true;
//  uint32_t i,j;
//  uint32_t ReceiveDataResult;
//  XUartPs *InstancePtr = &Uart_Ps;
//
//  xil_printf("send 40k bytes...\r\n");
//  for(i=0;i<MAX_SAMPLES;i++)
//  {
//    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
//      XUARTPS_SR_RXEMPTY;
//    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
//    {
//      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
//        XUARTPS_SR_RXEMPTY;
//    }
//    (void)XUartPs_Recv(InstancePtr, &received_bytes[i], 1U);
//  }
//
//  xil_printf("bytes received:\r\n");
//  j = 0;
//  for(i=0;i<MAX_SAMPLES;i++)
//  {
//
//    if(received_bytes[i] != j)
//    {
//      pass = false;
//      break;
//    }
//    j++;
//    j = j%10;
//  }
//
//  if(pass == true)
//  {
//    xil_printf("pass\r\n");
//  }
//  else
//  {
//    xil_printf("fail\r\n");
//    xil_printf("received_bytes[%i]:%i\r\n",i,received_bytes[i]);
//    xil_printf("i:%i\r\n",i);
//    xil_printf("j:%i\r\n",j);
//  }
//
//  return XST_SUCCESS;
//
//}

//  TXDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
//    XUARTPS_SR_TXFULL;
//  while (TXDataResult == XUARTPS_SR_TXFULL )
//  {
//    TXDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
//      XUARTPS_SR_TXFULL;
//  }
//  (void)XUartPs_Send(InstancePtr, &ReturnString[Index], 1U);
//  usleep(100);
