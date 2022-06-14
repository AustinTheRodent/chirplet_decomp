#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

uint8_t filter(float* a, uint32_t num_a, float* b, uint32_t num_b, float* x, uint32_t num_x, float* y)
{
  float y_tmp;

  int i;
  int j;

  for(i = 0 ; i < num_x ; i++)
  {
    y_tmp = 0;
    for(j = 0 ; j < num_b ; j++)
    {
      if(i - j >= 0)
      {
        y_tmp = y_tmp + (b[j]*x[i-j]);
      }
    }
    for(j = 1 ; j <= num_a ; j++)
    {
      if(i - j >= 0)
      {
        y_tmp = y_tmp - (a[j-1]*y[i-j]);
      }
    }
    y[i] = y_tmp;
  }
  return 0;
}

uint32_t get_txt_flen(char* fname)
{
  uint32_t line_count = 0;
  FILE* f = fopen(fname, "r");
  char* line = NULL;
  size_t len = 0;
  while(getline(&line, &len, f) != -1)
  {
    line_count++;
  }
  fclose(f);
  return line_count;
}

uint32_t read_txt_file(char* fname, float* output)
{
  int i = 0;
  FILE* f = fopen(fname, "r");
  char* line = NULL;
  size_t len = 0;
  while(getline(&line, &len, f) != -1)
  {
    output[i] = atof(line);
    i++;
  }
  fclose(f);
  return 0;
}

int main (int argc, char *argv[])
{

  int i;
  char* input_fname;
  char* a_taps_fname;
  char* b_taps_fname;
  char* output_fname;
  FILE* output_file;

  uint32_t ninput;
  uint32_t num_a_taps;
  uint32_t num_b_taps;

  float* x;
  float* y;
  float* b;
  float* a;

  uint8_t arg_count = 0;

  for(i = 0 ; i < argc ; i++)
  {
    if(strcmp(argv[i], "-i") == 0)
    {
      input_fname = argv[i+1];
      arg_count++;
    }
    else if(strcmp(argv[i], "-a") == 0)
    {
      a_taps_fname = argv[i+1];
      arg_count++;
    }
    else if(strcmp(argv[i], "-b") == 0)
    {
      b_taps_fname = argv[i+1];
      arg_count++;
    }
    else if(strcmp(argv[i], "-o") == 0)
    {
      output_fname = argv[i+1];
      arg_count++;
    }
  }

  if(arg_count < 4)
  {
    printf("error: not enough args\n");
    return 0;
  }

  ninput = get_txt_flen(input_fname);
  num_a_taps = get_txt_flen(a_taps_fname);
  num_b_taps = get_txt_flen(b_taps_fname);

  x = malloc(ninput*sizeof(float));
  y = malloc(ninput*sizeof(float));
  a = malloc(num_a_taps*sizeof(float));
  b = malloc(num_b_taps*sizeof(float));

  read_txt_file(input_fname, x);
  read_txt_file(a_taps_fname, a);
  read_txt_file(b_taps_fname, b);

  filter(a, num_a_taps, b, num_b_taps, x, ninput, y);

  output_file = fopen(output_fname, "w");
  for(i = 0 ; i < ninput ; i++)
  {
    fprintf(output_file, "%f\n", y[i]);
  }
  fclose(output_file);

  free(x);
  free(y);
  free(b);
  free(a);

  return 1;

}
