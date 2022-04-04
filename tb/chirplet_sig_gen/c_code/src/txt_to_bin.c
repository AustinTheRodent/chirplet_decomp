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



  //FILE* bin_out;
  //float val = 1.0;
  //
  //bin_out = fopen("other/output.bin", "wb");
  //fwrite(&val, sizeof(float), 1, bin_out);
  //fclose(bin_out);

  convert_file(input_fname, output_fname, type, radix_is_dec);

  return 1;

}

int8_t convert_file(char* fin_name, char* fout_name, char* type, bool radix_is_dec)
{
  FILE* fin_ptr = fopen(fin_name, "r");
  FILE* fout_ptr = fopen(fout_name, "wb");

  char * line = NULL;
  size_t len = 0;

  int int_line;
  double doub_line;

  uint8_t var_u8;
  uint16_t var_u16;
  uint32_t var_u32;
  int8_t var_8;
  int16_t var_16;
  int32_t var_32;
  float var_float;

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

  while(getline(&line, &len, fin_ptr) != -1)
  {
    if(type_num < 6)
    {
      if(radix_is_dec == true)
      {
        int_line = strtol(line, NULL, 10);
      }
      else
      {
        int_line = strtol(line, NULL, 16);
      }
    }
    else
    {
      doub_line = strtod(line, NULL);
    }

    if(type_num == 0)
    {
      var_u8 = (uint8_t)int_line;
      fwrite(&var_u8, sizeof(uint8_t), 1, fout_ptr);
    }
    else if(type_num == 1)
    {
      var_u16 = (uint16_t)int_line;
      fwrite(&var_u16, sizeof(uint16_t), 1, fout_ptr);
    }
    else if(type_num == 2)
    {
      var_u32 = (uint32_t)int_line;
      fwrite(&var_u32, sizeof(uint32_t), 1, fout_ptr);
    }
    else if(type_num == 3)
    {
      var_8 = (int8_t)int_line;
      fwrite(&var_8, sizeof(int8_t), 1, fout_ptr);
    }
    else if(type_num == 4)
    {
      var_16 = (int16_t)int_line;
      fwrite(&var_16, sizeof(int16_t), 1, fout_ptr);
    }
    else if(type_num == 5)
    {
      var_32 = (int32_t)int_line;
      fwrite(&var_32, sizeof(int32_t), 1, fout_ptr);
    }
    else if(type_num == 6)
    {
      var_float = (float)doub_line;
      fwrite(&var_float, sizeof(float), 1, fout_ptr);
    }
    else if(type_num == 7)
    {
      fwrite(&doub_line, sizeof(double), 1, fout_ptr);
    }

  }

  fclose(fin_ptr);
  fclose(fout_ptr);

}


