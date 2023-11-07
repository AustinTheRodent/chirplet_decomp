
#include <stdio.h>
#include <math.h>
#include "chirplet_transform.h"

void signal_creation
(
  int16_t* return_signal_re,
  int16_t* return_signal_im,
  chirplet_param_t* chirp_params
)
{

  const float beta      = chirp_params->beta.f;
  const float tau       = chirp_params->tau.f;
  const float f_c       = chirp_params->f_c.f;
  const float alpha1    = chirp_params->alpha1.f;
  const float alpha2    = chirp_params->alpha2.f;
  const float phi       = chirp_params->phi.f;
  const float time_step = chirp_params->t_step.f;

  int i;
  float t;
  float return_signal_re_f;
  float return_signal_im_f;
  for(i = 0 ; i < CHIRP_LEN ; i++)
  {
    t = time_step*(float)(i);
    
    return_signal_re_f = beta * exp((float)(-1)*alpha1*((t-tau)*(t-tau))) * cos(2*M_PI*f_c*(t-tau) + phi + alpha2*((t-tau)*(t-tau)));
    return_signal_im_f = beta * exp((float)(-1)*alpha1*((t-tau)*(t-tau))) * sin(2*M_PI*f_c*(t-tau) + phi + alpha2*((t-tau)*(t-tau)));

    return_signal_re[i] = round(return_signal_re_f * (float)RESCALE16);
    return_signal_im[i] = round(return_signal_im_f * (float)RESCALE16);
  }
}

uint32_t chirplet_transform_energy(chirplet_param_t* estimate_params, int16_t* ref_re, int16_t* ref_im)
{
  float chirp_sig_re_f;
  float chirp_sig_im_f;
  //int16_t chirp_sig_re;
  //int16_t chirp_sig_im;

  const float dt      = estimate_params->t_step.f;
  const float beta_   = estimate_params->beta.f;
  const float alpha1_ = estimate_params->alpha1.f;
  const float tau_    = estimate_params->tau.f;
  const float f_c_    = estimate_params->f_c.f;
  const float phi_    = estimate_params->phi.f;
  const float alpha2_ = estimate_params->alpha2.f;
  float ref_re_f;
  float ref_im_f;
  int i;
  float t = 0;
  float conj_sum_re = 0;
  float conj_sum_im = 0;
  float conj_sum_energy_f;
  int32_t conj_sum_energy;

  for(i = 0 ; i < CHIRP_LEN ; i++)
  {
    t = dt * (float)i;
    chirp_sig_re_f = beta_*exp(-1*alpha1_*((t-tau_)*(t-tau_))) * cos(2*M_PI*f_c_*(t-tau_)+phi_+alpha2_*((t-tau_)*(t-tau_)));
    chirp_sig_im_f = beta_*exp(-1*alpha1_*((t-tau_)*(t-tau_))) * sin(2*M_PI*f_c_*(t-tau_)+phi_+alpha2_*((t-tau_)*(t-tau_)));

    ref_re_f = (float)ref_re[i]/(float)RESCALE16;
    ref_im_f = (float)ref_im[i]/(float)RESCALE16;

    conj_sum_re = conj_sum_re + (chirp_sig_re_f*ref_re_f - chirp_sig_im_f*(-ref_im_f));
    conj_sum_im = conj_sum_im + (chirp_sig_re_f*(-ref_im_f) + chirp_sig_im_f*ref_re_f);
  }

  conj_sum_energy_f = conj_sum_re*conj_sum_re + conj_sum_im*conj_sum_im;
  conj_sum_energy = conj_sum_energy_f * (float)(1<<16);
  return conj_sum_energy;

}

void signal_creation_hw
(
  int16_t* return_signal_re,
  int16_t* return_signal_im,
  chirplet_param_t* chirp_params,
  uint32_t* chirplet_transform_reg_ptr
)
{
  //int i;
  //uint32_t tmp_buff_rx[CHIRP_LEN];
  //
  //
  //while(chirp_params->phi.f < 0)
  //{
  //  chirp_params->phi.f = chirp_params->phi.f + 2.0*M_PI;
  //}
  //chirp_params->phi.f = chirp_params->phi.f/(2.0*M_PI);
  //
  //chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 0; // feedback, enable
  //chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 0b11; // feedback, enable
  //
  //chirplet_transform_reg_ptr[CT_CHIRP_GEN_NUM_SAMPS_OUT/BYTES_PER_32BIT] = chirp_params->chirp_gen_num_samps_out;
  //chirplet_transform_reg_ptr[CT_DIN_T_STEP/BYTES_PER_32BIT]              = chirp_params->t_step.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_TAU/BYTES_PER_32BIT]                 = chirp_params->tau.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_ALPHA1/BYTES_PER_32BIT]              = chirp_params->alpha1.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_F_C/BYTES_PER_32BIT]                 = chirp_params->f_c.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_ALPHA2/BYTES_PER_32BIT]              = chirp_params->alpha2.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_PHI/BYTES_PER_32BIT]                 = chirp_params->phi.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_BETA/BYTES_PER_32BIT]                = chirp_params->beta.bytes;
  //
  //dma_rx(tmp_buff_rx, CHIRP_LEN*4);
  //while(is_dma_rx_done() == false){};
  //
  //
  //for(i = 0 ; i < CHIRP_LEN ; i++)
  //{
  //  return_signal_re[i] = (tmp_buff_rx[i] & 0xFFFF0000) >> 16;
  //  return_signal_im[i] = (tmp_buff_rx[i] & 0xFFFF);
  //}
  //
  //chirplet_transform_reg_ptr[CT_CONTROL/BYTES_PER_32BIT] = 0b01; // no feedback, enable

}

void chirplet_transform_hw_wr(chirplet_param_t* estimate_params, uint32_t* chirplet_transform_reg_ptr)
{
  //chirplet_transform_reg_ptr[CT_CHIRP_GEN_NUM_SAMPS_OUT/BYTES_PER_32BIT] = estimate_params->chirp_gen_num_samps_out;
  //chirplet_transform_reg_ptr[CT_DIN_T_STEP/BYTES_PER_32BIT]              = estimate_params->t_step.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_TAU/BYTES_PER_32BIT]                 = estimate_params->tau.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_ALPHA1/BYTES_PER_32BIT]              = estimate_params->alpha1.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_F_C/BYTES_PER_32BIT]                 = estimate_params->f_c.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_ALPHA2/BYTES_PER_32BIT]              = estimate_params->alpha2.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_PHI/BYTES_PER_32BIT]                 = estimate_params->phi.bytes;
  //chirplet_transform_reg_ptr[CT_DIN_BETA/BYTES_PER_32BIT]                = estimate_params->beta.bytes;
}

void chirplet_transform_dma_hw_wr(uint32_t* params_array, uint32_t array_len)
{
  dma_tx(params_array, array_len*6*4); // 4 bytes per sample_byte
  while(is_dma_tx_done() == false){};
}

uint32_t chirplet_transform_energy_hw_rd(uint32_t* chirplet_transform_reg_ptr)
{
  uint32_t status_reg = chirplet_transform_reg_ptr[CT_STATUS/BYTES_PER_32BIT];
  while((status_reg & 0x2) == 0) // wait for xcorr valid
  {
    status_reg = chirplet_transform_reg_ptr[CT_STATUS/BYTES_PER_32BIT];
  }
  return chirplet_transform_reg_ptr[CT_XCORR_DOUT_ENERGY/BYTES_PER_32BIT];
}
void chirplet_transform_energy_dma_hw_rd(uint32_t* return_buffer, uint32_t array_len, uint32_t* chirplet_transform_reg_ptr)
{
  //uint32_t timeout = 0;
  //chirplet_transform_reg_ptr[CT_XCORR_DMA_NUM_SAMPS_OUT/BYTES_PER_32BIT] = array_len;
  //dma_rx(return_buffer, array_len*4);
  //chirplet_transform_reg_ptr[CT_DMA_GO/BYTES_PER_32BIT] = 0xFFFFFFFF;
  ////init_ct_dma_rx();
  //while(is_dma_rx_done() == false)
  //{
  //  timeout++;
  //  if (timeout > 5000)
  //  {
  //    break;
  //  }
  //};
  //chirplet_transform_reg_ptr[CT_DMA_GO/BYTES_PER_32BIT] = 0;
  ////reset_ct_dma_rx();
}

