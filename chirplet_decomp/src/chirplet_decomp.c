#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

#include "chirplet_transform.h"


#define MAX_SAMPLES 50000

int16_t received_samples_re[MAX_SAMPLES];
int16_t received_samples_im[MAX_SAMPLES];

uint16_t get_samples(char* file_name);
void get_max_energy(int32_t* return_energy, uint32_t* return_index, int16_t* input_array_re, int16_t* input_array_im, uint32_t input_len);
float func_fc(float beta_, float tau_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t single_sig_re[CHIRP_LEN], int16_t single_sig_im[CHIRP_LEN]);
float func_tau(float beta_, float f_c_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t single_sig_re[CHIRP_LEN], int16_t single_sig_im[CHIRP_LEN]);
void find_tauandfc(float* return_tau_, float* return_f_c_, uint32_t indx, float time_step, float beta_, int16_t cut_sig_re[CHIRP_LEN], int16_t cut_sig_im[CHIRP_LEN]);
void estimate(float beta_, float tau_, float f_c_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t sig_re[CHIRP_LEN], int16_t sig_im[CHIRP_LEN]);

int main (int argc, char *argv[])
{
  int i,j;
  uint32_t max_index;
  int32_t max_value;
  uint32_t input_len;
  uint32_t start_index;
  chirplet_param_t chirplet_param;
  int16_t cut_sig_re[CHIRP_LEN];
  int16_t cut_sig_im[CHIRP_LEN];
  int16_t estimate_chirp_re[CHIRP_LEN];
  int16_t estimate_chirp_im[CHIRP_LEN];

  const float fs = 100000000; // 100MHz (change this value?)
  const float time_step = 1.0/fs;

  float beta = 0.85;
  float alpha1 = 25e11;
  float alpha2 = 15e11;
  float tau = 2e-5;
  float f_c = 5e6;
  float phi = M_PI/2.0;

  float beta_;
  float alpha1_;
  float alpha2_;
  float tau_;
  float f_c_;
  float phi_;

  chirplet_param.chirp_gen_num_samps_out = CHIRP_LEN/SAMPS_PER_CLK; // 64 cycles of 8 samps per cycle = 512 samps total
  chirplet_param.t_step.f = time_step;
  chirplet_param.beta.f   = beta;
  chirplet_param.alpha1.f = alpha1;
  chirplet_param.alpha2.f = alpha2;
  chirplet_param.tau.f    = tau;
  chirplet_param.f_c.f    = f_c;
  chirplet_param.phi.f    = phi;

  input_len = get_samples("./other/reference.bin");

  get_max_energy(&max_value, &max_index, received_samples_re, received_samples_im, input_len);

  chirplet_param.beta.f = (float)0.5;

  if( (int32_t)max_index - (int32_t)(CHIRP_LEN/2) < 0 )
  {
    start_index = 0;
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

  //chirplet_param.tau.f = (max_index - start_index)*chirplet_param.t_step.f;
  //
  //signal_creation
  //(
  //  estimate_chirp_re,
  //  estimate_chirp_im,
  //  &chirplet_param
  //);
  //
  //for(i = 0 ; i < CHIRP_LEN ; i++)
  //{
  //  printf("%i\n", estimate_chirp_re[i]);
  //}

  beta_ = 0.5;
  find_tauandfc(&tau_, &f_c_, max_index - start_index, time_step, beta_, cut_sig_re, cut_sig_im);

  printf("tau_: %0.16f\n", tau_);
  printf("f_c_: %0.16f\n", f_c_);

  alpha1_ = 24e10;
  alpha2_ = 14e12;
  phi_    = 0;

  estimate(beta_, tau_, f_c_, alpha1_, alpha2_, phi_, time_step, cut_sig_re, cut_sig_im);


  //estimate(&chirplet_param, start_index, received_samples_re, received_samples_im);

  return 0;

}

uint16_t get_samples(char* file_name)
{
  int i;
  FILE* file_ptr;
  uint16_t var_u16;
  uint16_t file_len;
  file_ptr = fopen(file_name, "rb");
  fread(&file_len, sizeof(uint16_t), 1, file_ptr);
  for(i = 0 ; i < file_len ; i++)
  {
    fread(&(received_samples_re[i]), sizeof(uint16_t), 1, file_ptr);
    fread(&(received_samples_im[i]), sizeof(uint16_t), 1, file_ptr);
  }
  fclose(file_ptr);
  return file_len;
}

void get_max_energy(int32_t* return_energy, uint32_t* return_index, int16_t input_array_re[CHIRP_LEN], int16_t input_array_im[CHIRP_LEN], uint32_t input_len)
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

float func_fc(float beta_, float tau_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t single_sig_re[CHIRP_LEN], int16_t single_sig_im[CHIRP_LEN])
{
  // todo: make min/max range not an magic #
  int i;
  uint32_t max_value = 0;
  const int16_t steps = 50;
  const int16_t nestedsteps = 40;
  float f_c_;
  uint32_t CT1;
  chirplet_param_t params;

  params.t_step.f = time_step;
  params.beta.f   = beta_;
  params.alpha1.f = alpha1_;
  params.tau.f    = tau_;
  //params.f_c.f;
  params.phi.f    = phi_;
  params.alpha2.f = alpha2_;

  int16_t indx = 0;
  int16_t oldindx = 0;
  for(i = 0 ; i < steps ; i++)
  {
    params.f_c.f = 4e6 + (float)i*((2e6)/((float)steps));
    CT1 = chirplet_transform_energy(&params, single_sig_re, single_sig_im);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i*nestedsteps;
    }
  }

  oldindx = indx;
  for(i = oldindx-nestedsteps ; i < oldindx+nestedsteps ; i++)
  {
    params.f_c.f = 4e6 + (float)i*((2e6)/(nestedsteps*steps));
    CT1 = chirplet_transform_energy(&params, single_sig_re, single_sig_im);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i;
    }
  }

  f_c_ = 4e6 + (float)indx*((2e6)/(float)(nestedsteps*steps));
  return f_c_;
}

float func_tau(float beta_, float f_c_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t single_sig_re[CHIRP_LEN], int16_t single_sig_im[CHIRP_LEN])
{
  int i;
  uint32_t max_value = 0;
  const int16_t steps = 32;
  const int16_t nestedsteps = 32;
  float tau_;
  const float tau_max = time_step*((float)CHIRP_LEN-1.0);
  uint32_t CT1;
  chirplet_param_t params;

  params.t_step.f = time_step;
  params.beta.f   = beta_;
  params.alpha1.f = alpha1_;
  //params.tau.f;
  params.f_c.f    = f_c_;
  params.phi.f    = phi_;
  params.alpha2.f = alpha2_;

  int16_t indx = 0;
  int16_t oldindx = 0;
  for(i = 0 ; i < steps ; i++)
  {
    params.tau.f = (float)i*((tau_max)/steps);
    CT1 = chirplet_transform_energy(&params, single_sig_re, single_sig_im);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i*nestedsteps;
    }
  }

  oldindx = indx;
  for(i = oldindx-nestedsteps ; i < oldindx+nestedsteps ; i++)
  {
    params.tau.f = i*((tau_max)/(nestedsteps*steps));
    CT1 = chirplet_transform_energy(&params, single_sig_re, single_sig_im);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i;
    }
  }

  tau_ = (float)indx*((tau_max)/(float)(nestedsteps*steps));
  return tau_;
}

float func_alpha2(float beta_, float f_c_, float alpha1_, float tau_, float phi_, float time_step, int16_t single_sig_re[CHIRP_LEN], int16_t single_sig_im[CHIRP_LEN])
{
  // todo: make min/max range not an magic #
  int i;
  uint32_t max_value = 0;
  const int16_t steps = 50;
  const int16_t nestedsteps = 40;
  float alpha2_;
  uint32_t CT1;
  chirplet_param_t params;

  params.t_step.f = time_step;
  params.beta.f   = beta_;
  params.alpha1.f = alpha1_;
  params.tau.f    = tau_;
  params.f_c.f    = f_c_;
  params.phi.f    = phi_;
  //params.alpha2.f = alpha2_;

  int16_t indx = 0;
  int16_t oldindx = 0;
  for(i = 0 ; i < steps ; i++)
  {
    params.alpha2.f = 1e12 + (float)i*((1e12)/((float)steps));
    CT1 = chirplet_transform_energy(&params, single_sig_re, single_sig_im);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i*nestedsteps;
    }
  }

  oldindx = indx;
  for(i = oldindx-nestedsteps ; i < oldindx+nestedsteps ; i++)
  {
    params.alpha2.f = 1e12 + (float)i*((1e12)/(nestedsteps*steps));
    CT1 = chirplet_transform_energy(&params, single_sig_re, single_sig_im);

    if(CT1 > max_value)
    {
      max_value = CT1;
      indx = i;
    }
  }

  alpha2_ = 1e12 + (float)indx*((1e12)/(float)(nestedsteps*steps));
  return alpha2_;
}

void find_tauandfc(float* return_tau_, float* return_f_c_, uint32_t indx, float time_step, float beta_, int16_t cut_sig_re[CHIRP_LEN], int16_t cut_sig_im[CHIRP_LEN])
{
  int i;
  float tau_ = indx*time_step;
  float f_c_;
  const float alpha1_ = 25e12;
  const float alpha2_ = 0*15e12;
  const float phi_ = 1;

  for(i = 0 ; i < 5 ; i++)
  {
    f_c_ = func_fc(beta_, tau_, alpha1_, alpha2_, phi_, time_step, cut_sig_re, cut_sig_im);
    tau_ = func_tau(beta_, f_c_, alpha1_, alpha2_, phi_, time_step, cut_sig_re, cut_sig_im);
  }

  *return_tau_ = tau_;
  *return_f_c_ = f_c_;

}

void estimate(float beta_, float tau_, float f_c_, float alpha1_, float alpha2_, float phi_, float time_step, int16_t sig_re[CHIRP_LEN], int16_t sig_im[CHIRP_LEN])
{

  alpha2_ = func_alpha2(beta_, f_c_, alpha1_, tau_, phi_, time_step, sig_re, sig_im);
  
  //alpha1_ = func_alpha1(beta_,f_c_,tau_,alpha2_,phi_,t,sig)
  //%phi_ = func_phi(beta_,f_c_,alpha1_,alpha2_,tau_,t,sig)

  //x_hat = signal_creation(1,tau_,f_c_,alpha1_,alpha2_,0,t);
  //x_conj_sum = sum(sig.*conj(x_hat));

  //phi_ = angle(x_conj_sum)
  //beta_ = abs(x_conj_sum)/sum(abs(x_hat).^2)

  //estimate_sig = signal_creation(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t);

  printf("alpha2_: %f\n", alpha2_);

}

