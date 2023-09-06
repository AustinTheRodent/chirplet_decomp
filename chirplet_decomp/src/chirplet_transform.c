
#include <stdio.h>
#include <math.h>
#include "chirplet_transform.h"

void signal_creation
(
  int16_t return_signal_re[CHIRP_LEN],
  int16_t return_signal_im[CHIRP_LEN],
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

uint32_t chirplet_transform_energy(chirplet_param_t* estimate_params, int16_t ref_re[CHIRP_LEN], int16_t ref_im[CHIRP_LEN])
{
  float chirp_sig_re_f;
  float chirp_sig_im_f;
  int16_t chirp_sig_re;
  int16_t chirp_sig_im;

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
