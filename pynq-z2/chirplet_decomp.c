
#include "sleep.h"
#include "xuartps.h"
#include "xparameters.h"
#include "xil_types.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include "platform.h"
#include "xil_printf.h"

#include "ct_dma.h"
#include "chirplet_transform.h"

//#define CT_CONTROL                  0x000
//#define CT_STATUS                   0x004
//#define CT_CHIRP_GEN_NUM_SAMPS_OUT  0x008
//#define CT_DIN_TAU                  0x00C
//#define CT_DIN_T_STEP               0x010
//#define CT_DIN_ALPHA1               0x014
//#define CT_DIN_F_C                  0x018
//#define CT_DIN_ALPHA2               0x01C
//#define CT_DIN_PHI                  0x020
//#define CT_DIN_BETA                 0x024
//#define CT_XCORR_REF_SAMP           0x028
//#define CT_XCORR_DOUT_RE_MSBS       0x02C
//#define CT_XCORR_DOUT_RE_LSBS       0x030
//#define CT_XCORR_DOUT_IM_MSBS       0x034
//#define CT_XCORR_DOUT_IM_LSBS       0x038
//#define CT_CHIRPLET_FEEDBACK        0x03C
//#define CT_LED_CONTROL              0x040
//#define CT_GPIO                     0x044
//#define CT_XCORR_DOUT_RE32          0x048
//#define CT_XCORR_DOUT_IM32          0x04C
//#define CT_XCORR_DOUT_ENERGY        0x050

//#define BYTES_PER_32BIT 4

#define MAX_SAMPLES 8192

#define C_FMIN 0e6
#define C_FMAX 50e6

#define C_A1MIN 1e12
#define C_A1MAX 1e15

#define C_A2MIN -2e13
#define C_A2MAX 2e13

XUartPs Uart_Ps; // Instance of the UART Device
//int16_t received_samples[MAX_SAMPLES];

int16_t received_samples_re[MAX_SAMPLES];
int16_t received_samples_im[MAX_SAMPLES];

uint16_t read_file(void);
void print_float(float input);
//int PS_test(void);
int init_uart_command_line(uint16_t DeviceId);
void wait_for_buttonpress(void);

void get_max_energy(int32_t* return_energy, uint32_t* return_index, int16_t* input_array_re, int16_t* input_array_im, uint32_t input_len);
float func_fc(float beta_, float tau_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im);
float func_tau(float beta_, float f_c_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im);
float func_alpha2(float beta_, float f_c_, float alpha1_, float tau_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im);
float func_alpha1(float f_c_, float tau_, float alpha2_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im);
void func_phi_beta(float* return_phi_, float* return_beta_, float f_c_, float alpha1_, float alpha2_, float tau_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im);
void find_tauandfc(float* return_tau_, float* return_f_c_, uint32_t indx, float time_step, float beta_, int16_t* cut_sig_re, int16_t* cut_sig_im);
void estimate
(
  chirplet_param_t* return_est_params,
  uint32_t indx,
  float time_step,
  int16_t* sig_re,
  int16_t* sig_im
);

uint32_t* chirplet_transform_reg_ptr = XPAR_CHIRPLET_DECOMP_TOP_0_BASEADDR;

int main()
{

  int i,j,chirp_count;
  uint32_t max_index;
  int32_t max_value;
  uint32_t input_len;
  uint32_t start_index;
  chirplet_param_t chirplet_param;
  int16_t cut_sig_re[CHIRP_LEN];
  int16_t cut_sig_im[CHIRP_LEN];
  int16_t estimate_chirp_re[CHIRP_LEN];
  int16_t estimate_chirp_im[CHIRP_LEN];
  //int16_t estimate_chirp_sw_re[CHIRP_LEN];
  //int16_t estimate_chirp_sw_im[CHIRP_LEN];

  const float fs = 100000000; // 100MHz (change this value?)
  const float time_step = 1.0/fs;

  init_uart_command_line(UART_DEVICE_ID);
  init_ct_dma();

  chirplet_param.chirp_gen_num_samps_out = CHIRP_LEN/SAMPS_PER_CLK; // 64 cycles of 8 samps per cycle = 512 samps total

  while(1)
  {

    input_len = read_file();
    xil_printf("Waiting For Button Press:\r\n");
    wait_for_buttonpress();
    chirplet_transform_reg_ptr[CT_GPIO/BYTES_PER_32BIT] = 0x00000001;

    for(chirp_count = 0 ; chirp_count < 100 ; chirp_count++)
    {
      get_max_energy(&max_value, &max_index, received_samples_re, received_samples_im, input_len);
      //xil_printf("max_value: %i\r\n", max_value);
      if(max_value < 55000)
      {
        break;
      }

      if( (int32_t)max_index - (int32_t)(CHIRP_LEN/2) < 0 )
      {
        start_index = 0;
      }
      else if((int32_t)max_index - (int32_t)(CHIRP_LEN/2) > input_len)
      {
        start_index = input_len - CHIRP_LEN;
      }
      else
      {
        start_index = max_index - (CHIRP_LEN/2);
      }

      i = 0;
      for(j = start_index ; j < start_index + CHIRP_LEN ; j++)
      {
        cut_sig_re[i] = received_samples_re[j];
        cut_sig_im[i] = received_samples_im[j];
        i++;
      }

      estimate(&chirplet_param, max_index - start_index, time_step, cut_sig_re, cut_sig_im);

      //chirplet_param.f_c.f = 0;
      //chirplet_param.alpha2.f = 0;
      //chirplet_param.phi.f = 1.5707963267948966;
      //
      signal_creation(estimate_chirp_re, estimate_chirp_im, &chirplet_param);
      //
      //chirplet_param.phi.f = 0.25;

      //signal_creation_hw(estimate_chirp_re, estimate_chirp_im, &chirplet_param, chirplet_transform_reg_ptr);

      //for(j = 0 ; j < CHIRP_LEN ; j++)
      //{
      //  xil_printf("estimate_chirp_sw_im[%i]: %i\r\n", j, estimate_chirp_sw_im[j]);
      //  xil_printf("estimate_chirp_im[%i]: %i\r\n\r\n", j, estimate_chirp_im[j]);
      //}




      xil_printf("start_index : %i\r\n" , start_index);
      xil_printf("tau_        : "); print_float(chirplet_param.tau.f    ); xil_printf("\r\n");
      xil_printf("f_c_        : "); print_float(chirplet_param.f_c.f    ); xil_printf("\r\n");
      xil_printf("alpha1_     : "); print_float(chirplet_param.alpha1.f ); xil_printf("\r\n");
      xil_printf("alpha2_     : "); print_float(chirplet_param.alpha2.f ); xil_printf("\r\n");
      xil_printf("phi_        : "); print_float(chirplet_param.phi.f    ); xil_printf("\r\n");
      xil_printf("beta_       : "); print_float(chirplet_param.beta.f   ); xil_printf("\r\n\r\n");

      xil_printf("tau_    bytes    : 0x%08X\r\n", chirplet_param.tau.bytes    );
      xil_printf("f_c_    bytes    : 0x%08X\r\n", chirplet_param.f_c.bytes    );
      xil_printf("alpha1_ bytes    : 0x%08X\r\n", chirplet_param.alpha1.bytes );
      xil_printf("alpha2_ bytes    : 0x%08X\r\n", chirplet_param.alpha2.bytes );
      xil_printf("phi_    bytes    : 0x%08X\r\n", chirplet_param.phi.bytes    );
      xil_printf("beta_   bytes    : 0x%08X\r\n\r\n\r\n", chirplet_param.beta.bytes   );




      i = 0;
      for(j = start_index ; j < start_index+CHIRP_LEN ; j++)
      {
        received_samples_re[j] = received_samples_re[j] - estimate_chirp_re[i];
        received_samples_im[j] = received_samples_im[j] - estimate_chirp_im[i];
        i++;
      }

    }

    chirplet_transform_reg_ptr[CT_GPIO/BYTES_PER_32BIT] = 0x00000000;

    xil_printf("max_value: %i\r\n", max_value);
    xil_printf("chirp_count: %i\r\n\r\n\r\n", chirp_count);

    //xil_printf("start_index : %i\r\n" , start_index);
    //xil_printf("tau_        : "); print_float(chirplet_param.tau.f    ); xil_printf("\r\n");
    //xil_printf("f_c_        : "); print_float(chirplet_param.f_c.f    ); xil_printf("\r\n");
    //xil_printf("alpha1_     : "); print_float(chirplet_param.alpha1.f ); xil_printf("\r\n");
    //xil_printf("alpha2_     : "); print_float(chirplet_param.alpha2.f ); xil_printf("\r\n");
    //xil_printf("phi_        : "); print_float(chirplet_param.phi.f    ); xil_printf("\r\n");
    //xil_printf("beta_       : "); print_float(chirplet_param.beta.f   ); xil_printf("\r\n\r\n");
    //
    //xil_printf("tau_    bytes    : 0x%08X\r\n", chirplet_param.tau.bytes    );
    //xil_printf("f_c_    bytes    : 0x%08X\r\n", chirplet_param.f_c.bytes    );
    //xil_printf("alpha1_ bytes    : 0x%08X\r\n", chirplet_param.alpha1.bytes );
    //xil_printf("alpha2_ bytes    : 0x%08X\r\n", chirplet_param.alpha2.bytes );
    //xil_printf("phi_    bytes    : 0x%08X\r\n", chirplet_param.phi.bytes    );
    //xil_printf("beta_   bytes    : 0x%08X\r\n", chirplet_param.beta.bytes   );

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
  //bool pass = true;
  uint32_t i;
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
    received_samples_re[i] = sample_byte;
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
    {
      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
        XUARTPS_SR_RXEMPTY;
    }
    (void)XUartPs_Recv(InstancePtr, &sample_byte, 1U);
    received_samples_re[i] |= sample_byte << 8;

    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
    {
      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
        XUARTPS_SR_RXEMPTY;
    }
    (void)XUartPs_Recv(InstancePtr, &sample_byte, 1U);
    received_samples_im[i] = sample_byte;
    ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
      XUARTPS_SR_RXEMPTY;
    while (ReceiveDataResult == XUARTPS_SR_RXEMPTY )
    {
      ReceiveDataResult = Xil_In32((InstancePtr->Config.BaseAddress) + XUARTPS_SR_OFFSET) &
        XUARTPS_SR_RXEMPTY;
    }
    (void)XUartPs_Recv(InstancePtr, &sample_byte, 1U);
    received_samples_im[i] |= sample_byte << 8;
  }

  //for(i=0;i<data_len;i++)
  //{
  //  xil_printf("I[%i]: %i\t", i, received_samples[i*2]);
  //  xil_printf("Q[%i]: %i\r\n", i, received_samples[i*2+1]);
  //}

  return data_len;
}

void print_float(float input)
{
  const uint32_t decimal = (float)(input*1000000000.0 - (float)(((int32_t)input)*1000000000.0));
  xil_printf("%i." , (int32_t)input);
  xil_printf("%09u", decimal);
}


void get_max_energy(int32_t* return_energy, uint32_t* return_index, int16_t* input_array_re, int16_t* input_array_im, uint32_t input_len)
{
  int i;
  uint32_t input_re_squared;
  uint32_t input_im_squared;
  uint32_t input_energy;

  *return_energy = 0;
  *return_index = 0;

  for(i = 0 ; i < input_len ; i++)
  {
    input_re_squared = input_array_re[i] * input_array_re[i];
    input_im_squared = input_array_im[i] * input_array_im[i];
    input_energy = input_re_squared + input_im_squared;
    if(input_energy > *return_energy)
    {
      *return_energy = input_energy;
      *return_index = i;
    }
  }
}

float func_fc(float beta_, float tau_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im)
{
  int i;
  int param_count;
  uint32_t max_value = 0;
  const int16_t steps = 50;
  const int16_t nestedsteps = 40;
  float f_c_;
  uint32_t CT1;
  chirplet_param_t params;

  const float fmin = C_FMIN;
  const float fmax = C_FMAX;

  uint32_t param_array[256*6];

  params.chirp_gen_num_samps_out  = CHIRP_LEN/SAMPS_PER_CLK;
  params.t_step.f                 = time_step;
  params.beta.f                   = beta_;
  params.alpha1.f                 = alpha1_;
  params.tau.f                    = tau_;
  //params.f_c.f;
  params.phi.f                    = phi_;
  params.alpha2.f                 = alpha2_;

  int16_t indx = 0;
  int16_t oldindx = 0;
  param_count = 0;
  for(i = 0 ; i <= steps ; i++)
  {
    params.f_c.f = fmin + (float)i*((fmax-fmin)/((float)steps));
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);

    //tau, alpha1, fc, alpha2, phi, beta
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);

  for(i = 0 ; i <= steps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);
    //xil_printf("CT1: %u\r\n", CT1);
    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i*nestedsteps;
    }
  }
  //xil_printf("indx: %u\r\n", indx);
  //xil_printf("\r\n");

  oldindx = indx;
  if(oldindx < nestedsteps)
  {
    oldindx = nestedsteps;
    indx = nestedsteps;
  }


  param_count = 0;
  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    params.f_c.f = fmin + (float)i*((fmax-fmin)/(nestedsteps*steps));
    //xil_printf("f_c: 0x%08X\r\n", params.f_c.bytes);
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);
  
  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);
    //xil_printf("CT1: %u\r\n", CT1);
    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i;
    }
  }
  //xil_printf("indx: %u\r\n", indx);
  //xil_printf("\r\n");
  f_c_ = fmin + (float)indx*((fmax-fmin)/(float)(nestedsteps*steps));
  //xil_printf("indx: %u\r\n", indx);
  //xil_printf("f_c_: ");print_float(f_c_);xil_printf("\r\n");
  return f_c_;
}

float func_tau(float beta_, float f_c_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im)
{
  int i;
  uint32_t max_value = 0;
  const int16_t steps = 32;
  const int16_t nestedsteps = 32;
  float tau_;
  const float tau_max = time_step*((float)CHIRP_LEN-1.0);
  uint32_t CT1;
  chirplet_param_t params;

  uint32_t param_array[256*6];
  int param_count;

  params.chirp_gen_num_samps_out  = CHIRP_LEN/SAMPS_PER_CLK;
  params.t_step.f                 = time_step;
  params.beta.f                   = beta_;
  params.alpha1.f                 = alpha1_;
  //params.tau.f;
  params.f_c.f                    = f_c_;
  params.phi.f                    = phi_;
  params.alpha2.f                 = alpha2_;

  int16_t indx = 0;
  int16_t oldindx = 0;
  param_count = 0;
  for(i = 0 ; i <= steps ; i++)
  {
    params.tau.f = (float)i*((tau_max)/steps);
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);

  for(i = 0 ; i <= steps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);
    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i*nestedsteps;
    }
  }

  oldindx = indx;
  if(oldindx < nestedsteps)
  {
    oldindx = nestedsteps;
    indx = nestedsteps;
  }

  param_count = 0;
  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    params.tau.f = i*((tau_max)/(nestedsteps*steps));
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);

  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);
    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i;
    }
  }

  tau_ = (float)indx*((tau_max)/(float)(nestedsteps*steps));
  return tau_;
}

float func_alpha2(float beta_, float f_c_, float alpha1_, float tau_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im)
{
  int i;
  uint32_t max_value = 0;
  const int16_t steps = 50;
  const int16_t nestedsteps = 40;
  float alpha2_;
  uint32_t CT1;
  chirplet_param_t params;

  uint32_t param_array[256*6];
  int param_count;

  const float a2min = C_A2MIN;
  const float a2max = C_A2MAX;

  params.chirp_gen_num_samps_out  = CHIRP_LEN/SAMPS_PER_CLK;
  params.t_step.f                 = time_step;
  params.beta.f                   = beta_;
  params.alpha1.f                 = alpha1_;
  params.tau.f                    = tau_;
  params.f_c.f                    = f_c_;
  params.phi.f                    = phi_;
  //params.alpha2.f = alpha2_;

  int16_t indx = 0;
  int16_t oldindx = 0;
  param_count = 0;
  for(i = 0 ; i <= steps ; i++)
  {
    params.alpha2.f = a2min + (float)i*((a2max-a2min)/((float)steps));
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);

  for(i = 0 ; i <= steps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i*nestedsteps;
    }
  }

  oldindx = indx;
  if(oldindx < nestedsteps)
  {
    oldindx = nestedsteps;
    indx = nestedsteps;
  }
  param_count = 0;
  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    params.alpha2.f = a2min + (float)i*((a2max-a2min)/(nestedsteps*steps));
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);

  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i;
    }
  }
  alpha2_ = a2min + (float)((float)((int64_t)indx*(int64_t)(a2max-a2min))/(float)(nestedsteps*steps));
  return alpha2_;
}

float func_alpha1(float f_c_, float tau_, float alpha2_, float phi_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im)
{
  int i;
  uint32_t max_value = 0;
  const int16_t steps = 50;
  const int16_t nestedsteps = 40;
  float alpha1_;
  uint32_t CT1;
  chirplet_param_t params;

  uint32_t param_array[256*6];
  int param_count;

  const float a1min = C_A1MIN;
  const float a1max = C_A1MAX;

  params.chirp_gen_num_samps_out  = CHIRP_LEN/SAMPS_PER_CLK;
  params.t_step.f                 = time_step;
  //params.beta.f   = beta_;
  //params.alpha1.f = alpha1_;
  params.tau.f                    = tau_;
  params.f_c.f                    = f_c_;
  params.phi.f                    = phi_;
  params.alpha2.f                 = alpha2_;

  int16_t indx = 0;
  int16_t oldindx = 0;
  param_count = 0;
  for(i = 0 ; i <= steps ; i++)
  {
    params.alpha1.f = a1min + (float)i*((a1max-a1min)/((float)steps));
    params.beta.f = 0.25 * 4e-4 * pow(2.0*M_PI*params.alpha1.f, 0.25);
    //xil_printf("params.beta.f: ");print_float(params.beta.f);xil_printf("\r\n");
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);

  for(i = 0 ; i <= steps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);
    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i*nestedsteps;
    }
  }

  oldindx = indx;
  if(oldindx < nestedsteps)
  {
    oldindx = nestedsteps;
    indx = nestedsteps;
  }
  param_count = 0;
  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    params.alpha1.f = a1min + (float)i*((a1max-a1min)/(nestedsteps*steps));
    params.beta.f = 0.25 *  4e-4 * pow(2.0*M_PI*params.alpha1.f, 0.25);
    //chirplet_transform_hw_wr(&params, chirplet_transform_reg_ptr);
    param_array[param_count*6 + 0] = params.tau.bytes;
    param_array[param_count*6 + 1] = params.alpha1.bytes;
    param_array[param_count*6 + 2] = params.f_c.bytes;
    param_array[param_count*6 + 3] = params.alpha2.bytes;
    param_array[param_count*6 + 4] = params.phi.bytes;
    param_array[param_count*6 + 5] = params.beta.bytes;
    param_count++;
  }
  chirplet_transform_dma_hw_wr(param_array, param_count);

  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  {
    CT1 = chirplet_transform_energy_hw_rd(chirplet_transform_reg_ptr);
    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i;
    }
  }
  alpha1_ = a1min + (float)indx*((a1max-a1min)/(float)(nestedsteps*steps));
  return alpha1_;
}

void func_phi_beta(float* return_phi_, float* return_beta_, float f_c_, float alpha1_, float alpha2_, float tau_, float time_step, int16_t* single_sig_re, int16_t* single_sig_im)
{
  int i;
  int16_t x_hat_re[CHIRP_LEN];
  int16_t x_hat_im[CHIRP_LEN];
  float x_hat_re_f;
  float x_hat_im_f;
  float single_sig_re_f;
  float single_sig_im_f;
  float x_conj_sum_re = 0;
  float x_conj_sum_im = 0;
  float phi_;
  float beta_;
  float s_re = 0;
  float s_im = 0;
  float ss = 0;

  chirplet_param_t estimate_params;

  estimate_params.beta.f    = 1.0;
  estimate_params.f_c.f     = f_c_;
  estimate_params.alpha1.f  = alpha1_;
  estimate_params.alpha2.f  = alpha2_;
  estimate_params.tau.f     = tau_;
  estimate_params.t_step.f  = time_step;

  signal_creation(x_hat_re, x_hat_im, &estimate_params);

  for(i = 0 ; i < CHIRP_LEN ; i++)
  {
    single_sig_re_f = (float)single_sig_re[i]/(float)RESCALE16;
    single_sig_im_f = (float)single_sig_im[i]/(float)RESCALE16;

    x_hat_re_f = (float)x_hat_re[i]/(float)RESCALE16;
    x_hat_im_f = (float)x_hat_im[i]/(float)RESCALE16;

    x_conj_sum_re = x_conj_sum_re + (single_sig_re_f*x_hat_re_f - single_sig_im_f*(-x_hat_im_f));
    x_conj_sum_im = x_conj_sum_im + (single_sig_re_f*(-x_hat_im_f) + single_sig_im_f*x_hat_re_f);

    s_re = s_re + x_hat_re_f*x_hat_re_f;
    s_im = s_im + x_hat_im_f*x_hat_im_f;
    ss = s_re + s_im;
  }

  if(x_conj_sum_im >= 0 && x_conj_sum_re >= 0)
  {
    phi_ = atan(x_conj_sum_im/x_conj_sum_re);
  }
  else if(x_conj_sum_im >= 0 && x_conj_sum_re < 0)
  {
    phi_ = atan(x_conj_sum_im/x_conj_sum_re) + M_PI;
  }
  else if(x_conj_sum_im < 0 && x_conj_sum_re < 0)
  {
    phi_ = atan(x_conj_sum_im/x_conj_sum_re) - M_PI;
  }
  else
  {
    phi_ = atan(x_conj_sum_im/x_conj_sum_re);
  }

  //phi_ = atan(x_conj_sum_im/x_conj_sum_re);
  beta_ = sqrt((x_conj_sum_re*x_conj_sum_re + x_conj_sum_im*x_conj_sum_im)/(ss*ss));

  *return_phi_ = phi_;
  *return_beta_ = beta_;

}

void find_tauandfc(float* return_tau_, float* return_f_c_, uint32_t indx, float time_step, float beta_, int16_t* cut_sig_re, int16_t* cut_sig_im)
{
  int i;
  float tau_ = indx*time_step;
  float f_c_;
  const float alpha1_ = 25e12;
  const float alpha2_ = 0*15e12;
  const float phi_ = 1;
  //xil_printf("indx : %i\r\n", indx);
  //xil_printf("tau_ : "); print_float(tau_); xil_printf("\r\n");
  //xil_printf("f_c_ : "); print_float(f_c_); xil_printf("\r\n\r\n");
  for(i = 0 ; i < 5 ; i++)
  {
    f_c_ = func_fc(beta_, tau_, alpha1_, alpha2_, phi_, time_step, cut_sig_re, cut_sig_im);
    tau_ = func_tau(beta_, f_c_, alpha1_, alpha2_, phi_, time_step, cut_sig_re, cut_sig_im);
    //xil_printf("tau_ : "); print_float(tau_); xil_printf("\r\n");
    //xil_printf("f_c_ : "); print_float(f_c_); xil_printf("\r\n");
  }

  *return_tau_ = tau_;
  *return_f_c_ = f_c_;

}

void estimate
(
  chirplet_param_t* return_est_params,
  uint32_t indx,
  float time_step,
  int16_t* sig_re,
  int16_t* sig_im
)
{
  int i;
  uint32_t tmp_buff_tx[CHIRP_LEN];
  //uint32_t status_reg;
  float phi_, beta_, alpha1_, alpha2_, tau_, f_c_;

  return_est_params->chirp_gen_num_samps_out = CHIRP_LEN/SAMPS_PER_CLK;
  return_est_params->t_step.f = time_step;

  chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 0; // reset control register
  chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 0b101; // DMA is reference, no feedback, enable

  // write CT reference signal:
  //xil_printf("CT Reference Signal: \r\n");
  for(i = 0 ; i < CHIRP_LEN ; i++)
  {
    tmp_buff_tx[i] = (sig_re[i] << 16) | (sig_im[i] & 0xFFFF);
    //xil_printf("tmp_buff_tx[%i]: 0x%08X\r\n", i, tmp_buff_tx[i]);
  }
  dma_tx(tmp_buff_tx, 512*4); // 512 samples, 4 bytes per sample_byte
  while(is_dma_tx_done() == false){};

  chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 0b001; // DMA is parameters, no feedback, enable
  chirplet_transform_reg_ptr[CT_CHIRP_GEN_NUM_SAMPS_OUT/BYTES_PER_32BIT] = return_est_params->chirp_gen_num_samps_out;
  chirplet_transform_reg_ptr[CT_DIN_T_STEP/BYTES_PER_32BIT]              = return_est_params->t_step.bytes;

  beta_ = 0.5;
  find_tauandfc(&tau_, &f_c_, indx, time_step, beta_, sig_re, sig_im);

  alpha1_ = 24e10;
  alpha2_ = 14e12;
  phi_    = 0;

  alpha2_ = func_alpha2(0.5, f_c_, alpha1_, tau_, 0, time_step, sig_re, sig_im);
  alpha1_ = func_alpha1(f_c_, tau_, alpha2_, 0, time_step, sig_re, sig_im);
  func_phi_beta(&phi_, &beta_, f_c_, alpha1_, alpha2_, tau_, time_step, sig_re, sig_im);

  return_est_params->tau.f    = tau_;
  return_est_params->alpha1.f =alpha1_;
  return_est_params->f_c.f    = f_c_;
  return_est_params->alpha2.f = alpha2_;
  return_est_params->phi.f    = phi_;
  return_est_params->beta.f   = beta_;

}


