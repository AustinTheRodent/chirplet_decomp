#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

//uint32_t read_txt_file(char* fname, float* output)
//{
//  int i = 0;
//  FILE* f = fopen(fname, "r");
//  char* line = NULL;
//  size_t len = 0;
//  while(getline(&line, &len, f) != -1)
//  {
//    output[i] = atof(line);
//    i++;
//  }
//  fclose(f);
//  return 0;
//}

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

int main (int argc, char *argv[])
{

  int i;
  uint8_t arg_count;
  float bits_per_samp;
  char* f1_name;
  char* f2_name;
  FILE* f1;
  FILE* f2;
  uint32_t f1_len;
  uint32_t f2_len;
  uint32_t smaller_len;

  char* line = NULL;
  size_t len = 0;

  float samp1;
  float samp2;

  float evm;
  float avg_evm = 0;
  float max_evm = 0;
  uint32_t max_evm_sample = 0;

  for(i = 0 ; i < argc ; i++)
  {
    if(strcmp(argv[i], "-f1") == 0)
    {
      f1_name = argv[i+1];
      arg_count++;
    }
    else if(strcmp(argv[i], "-f2") == 0)
    {
      f2_name = argv[i+1];
      arg_count++;
    }
    else if(strcmp(argv[i], "-s") == 0)
    {
      bits_per_samp = atof(argv[i+1]);
      arg_count++;
    }
  }

  if(arg_count < 3)
  {
    printf("error: not enough args\n");
    return 0;
  }

  f1_len = get_txt_flen(f1_name);
  f2_len = get_txt_flen(f2_name);

  if(f1_len != f2_len)
  {
    printf("warning: file lengths differ\n");
  }

  if(f1_len < f2_len)
  {
    smaller_len = f1_len;
  }
  else
  {
    smaller_len = f2_len;
  }

  printf("smaller_len: %i\n", smaller_len);

  f1 = fopen(f1_name, "r");
  f2 = fopen(f2_name, "r");

  for(i = 0 ; i < smaller_len ; i++)
  {
    getline(&line, &len, f1);
    samp1 = atof(line);

    getline(&line, &len, f2);
    samp2 = atof(line);

    evm = abs(samp1 - samp2)/pow(2, bits_per_samp-1);
    if(evm > max_evm)
    {
      max_evm = evm;
      max_evm_sample = i+1;
    }
    avg_evm = avg_evm + evm;

  }

  fclose(f1);
  fclose(f2);

  printf("avg_evm: %f%%\n", 100.0*avg_evm/((float)i));
  printf("max_evm: %f%%\n", 100.0*max_evm);
  printf("max_evm_sample: %i\n", max_evm_sample);



}



