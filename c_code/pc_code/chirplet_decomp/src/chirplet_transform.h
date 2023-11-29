#ifndef CHIRPLET_TRANSFORM_H
#define CHIRPLET_TRANSFORM_H

#define CHIRP_LEN 512
#define SAMPS_PER_CLK 8
#define RESCALE16 32678

#include <stdint.h>

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

float chirplet_transform_energy(chirplet_param_t* estimate_params, int16_t* ref_re, int16_t* ref_im);

#endif