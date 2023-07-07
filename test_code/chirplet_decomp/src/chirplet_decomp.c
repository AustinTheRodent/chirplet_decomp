#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

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

#define MAX_SAMPLES 25000
#define CHIRP_LEN 512
#define SAMPS_PER_CLK 8

int16_t received_samples_re[MAX_SAMPLES];
int16_t received_samples_im[MAX_SAMPLES];

void get_max(int32_t* return_value, uint32_t* return_index, int16_t* input_array, uint32_t input_len);
find_tauandfc(chirplet_param_t* chirplet_param, uint32_t start_index, uint32_t* received_samples);
estimate(chirplet_param_t* chirplet_param, uint32_t start_index, uint32_t* received_samples);

int main (int argc, char *argv[])
{

  uint32_t max_index;
  int32_t max_value;
  uint32_t input_len;
  uint32_t start_index;
  const float fs = 100000000.0; // 100MHz (change this value?)
  chirplet_param_t chirplet_param;

  //todo:
  //  get received_samples data from file
  //  get received_samples length from file

  chirplet_param.chirp_gen_num_samps_out = CHIRP_LEN/SAMPS_PER_CLK; // 64 cycles of 8 samps per cycle = 512 samps total
  chirplet_param.t_step.f = 1.0/fs;

  get_max(&max_value, &max_index, received_samples, input_len);
  chirplet_param.beta.f = (float)max_value;

  if( (int32_t)max_index - (int32_t)((CHIRP_LEN/SAMPS_PER_CLK)/2) < 0 )
  {
    start_index = 0;
  }
  else
  {
    start_index = max_index - ((CHIRP_LEN/SAMPS_PER_CLK)/2);
  }

  find_tauandfc(&chirplet_param, start_index, received_samples);
  estimate(&chirplet_param, start_index, received_samples);

  return 0;

}

void get_max(int32_t* return_value, uint32_t* return_index, int16_t* input_array_re, int16_t* input_array_im, uint32_t input_len)
{
  // make sure to find max magnitude, input array should be complex valued
}

find_tauandfc(chirplet_param_t* chirplet_param, uint32_t start_index, uint32_t* received_samples)
{
}

estimate(chirplet_param_t* chirplet_param, uint32_t start_index, uint32_t* received_samples)
{
}
