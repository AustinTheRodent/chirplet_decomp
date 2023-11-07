#ifndef CHIRPLET_TRANSFORM_H
#define CHIRPLET_TRANSFORM_H

// dual dma:
//#define CT_CONTROL                  0x000
//#define CT_STATUS                   0x004
//#define CT_CHIRP_GEN_NUM_SAMPS_OUT  0x008
//#define CT_XCORR_DMA_NUM_SAMPS_OUT  0x00C
//#define CT_DIN_T_STEP               0x010
//#define CT_LED_CONTROL              0x040
//#define CT_GPIO                     0x044
//#define CT_DMA_GO                   0x048

// param dma:
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
#define CT_GPIO                     0x044
#define CT_XCORR_DOUT_RE32          0x048
#define CT_XCORR_DOUT_IM32          0x04C
#define CT_XCORR_DOUT_ENERGY        0x050

#define BYTES_PER_32BIT 4

#define CHIRP_LEN 512
#define SAMPS_PER_CLK 8
#define RESCALE16 32678

#include <stdint.h>
#include <stdbool.h>
#include "ct_dma.h"

union ufloat
{
  float f;
  uint32_t bytes;
};

typedef struct
{
  uint32_t chirp_gen_num_samps_out;
  union    ufloat t_step;
  union    ufloat tau;
  union    ufloat alpha1;
  union    ufloat f_c;
  union    ufloat alpha2;
  union    ufloat phi;
  union    ufloat beta;
} chirplet_param_t;

void signal_creation
(
  int16_t* return_signal_re,
  int16_t* return_signal_im,
  chirplet_param_t* chirp_params
);

uint32_t chirplet_transform_energy(chirplet_param_t* estimate_params, int16_t* ref_re, int16_t* ref_im);

void signal_creation_hw
(
  int16_t* return_signal_re,
  int16_t* return_signal_im,
  chirplet_param_t* chirp_params,
  uint32_t* chirplet_transform_reg_ptr
);

void chirplet_transform_hw_wr(chirplet_param_t* estimate_params, uint32_t* chirplet_transform_reg_ptr);
void chirplet_transform_dma_hw_wr(uint32_t* params_array, uint32_t array_len);
uint32_t chirplet_transform_energy_hw_rd(uint32_t* chirplet_transform_reg_ptr);
void chirplet_transform_energy_dma_hw_rd(uint32_t* return_buffer, uint32_t array_len, uint32_t* chirplet_transform_reg_ptr);

#endif