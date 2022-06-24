#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

int8_t convert_file(char* fin_name, char* fout_name, char* type, bool radix_is_dec);

int main (int argc, char *argv[])
{

  int i;
  char* input_fname;
  char* output_fname;
  char* type;

  uint8_t arg_count = 0;

  bool radix_is_dec = true;

  for(i = 0 ; i < argc ; i++)
  {
    if(strcmp(argv[i], "-i") == 0)
    {
      input_fname = argv[i+1];
      arg_count++;
    }
    else if(strcmp(argv[i], "-o") == 0)
    {
      output_fname = argv[i+1];arg_count++;
    }
    else if(strcmp(argv[i], "-t") == 0)
    {
      type = argv[i+1];
      arg_count++;
      if(type == NULL)
      {
        printf("error: unallowed type\n use stdint, float, or double\n");
        return 0;
      }
      if(!((strcmp(type, "uint8_t") == 0) ||
           (strcmp(type, "uint16_t") == 0) ||
           (strcmp(type, "uint32_t") == 0) ||
           (strcmp(type, "int8_t") == 0) ||
           (strcmp(type, "int16_t") == 0) ||
           (strcmp(type, "int32_t") == 0) ||
           (strcmp(type, "float") == 0) ||
           (strcmp(type, "double") == 0)))
       {
         printf("error: unallowed type\n use stdint, float, or double\n");
         return 0;
       }
    }
    else if(strcmp(argv[i], "-r") == 0)
    {
      if(strcmp(argv[i+1], "h") == 0)
      {
        radix_is_dec = false;
      }
      else if(strcmp(argv[i+1], "d") == 0)
      {
        radix_is_dec = true;
      }
    }
  }

  if(arg_count < 3)
  {
    printf("error: not enough args\n");
    return 0;
  }

  convert_file(input_fname, output_fname, type, radix_is_dec);

  return 1;

}

int8_t convert_file(char* fin_name, char* fout_name, char* type, bool radix_is_dec)
{
  FILE* fin_ptr = fopen(fin_name, "rb");
  FILE* fout_ptr = fopen(fout_name, "w");

  uint8_t var_u8;
  uint16_t var_u16;
  uint32_t var_u32;
  int8_t var_8;
  int16_t var_16;
  int32_t var_32;
  float var_float;
  float var_double;

  uint8_t type_num;
  if(strcmp(type, "uint8_t") == 0)
  {
    type_num = 0;
  }
  else if(strcmp(type, "uint16_t") == 0)
  {
    type_num = 1;
  }
  else if(strcmp(type, "uint32_t") == 0)
  {
    type_num = 2;
  }
  else if(strcmp(type, "int8_t") == 0)
  {
    type_num = 3;
  }
  else if(strcmp(type, "int16_t") == 0)
  {
    type_num = 4;
  }
  else if(strcmp(type, "int32_t") == 0)
  {
    type_num = 5;
  }
  else if(strcmp(type, "float") == 0)
  {
    type_num = 6;
  }
  else if(strcmp(type, "double") == 0)
  {
    type_num = 7;
  }

  while(1)
  {
    if(type_num == 0)
    {
      fread(&var_u8, sizeof(uint8_t), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      if(radix_is_dec == true)
      {
        fprintf(fout_ptr, "%u\n", var_u8);
      }
      else
      {
        fprintf(fout_ptr, "%02X\n", var_u8);
      }
    }
    else if(type_num == 1)
    {
      fread(&var_u16, sizeof(uint16_t), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      if(radix_is_dec == true)
      {
        fprintf(fout_ptr, "%u\n", var_u16);
      }
      else
      {
        fprintf(fout_ptr, "%04X\n", var_u16);
      }
    }
    else if(type_num == 2)
    {
      fread(&var_u32, sizeof(uint32_t), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      if(radix_is_dec == true)
      {
        fprintf(fout_ptr, "%u\n", var_u32);
      }
      else
      {
        fprintf(fout_ptr, "%08X\n", var_u32);
      }
    }
    else if(type_num == 3)
    {
      fread(&var_8, sizeof(int8_t), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      if(radix_is_dec == true)
      {
        fprintf(fout_ptr, "%i\n", var_8);
      }
      else
      {
        fprintf(fout_ptr, "%02X\n", var_8);
      }
    }
    else if(type_num == 4)
    {
      fread(&var_16, sizeof(int16_t), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      if(radix_is_dec == true)
      {
        fprintf(fout_ptr, "%i\n", var_16);
      }
      else
      {
        fprintf(fout_ptr, "%04X\n", var_16);
      }
    }
    else if(type_num == 5)
    {
      fread(&var_32, sizeof(int32_t), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      if(radix_is_dec == true)
      {
        fprintf(fout_ptr, "%i\n", var_32);
      }
      else
      {
        fprintf(fout_ptr, "%08X\n", var_32);
      }
    }
    else if(type_num == 6)
    {
      fread(&var_float, sizeof(float), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      fprintf(fout_ptr, "%f\n", var_float);
    }
    else if(type_num == 7)
    {
      fread(&var_double, sizeof(double), 1, fin_ptr);
      if(feof(fin_ptr)){break;}
      fprintf(fout_ptr, "%d\n", var_double);
    }

  }

  fclose(fin_ptr);
  fclose(fout_ptr);

}


