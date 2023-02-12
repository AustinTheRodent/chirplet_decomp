#include <Arduino.h>
#include <stdint.h>
#include <stdbool.h>

#define pass (void)0

#define READ 1
#define WRITE 0

int teensy_main(void)
{
  int i;

  uint32_t sin_lut[2048];
  uint32_t cos_lut[2048];
  uint32_t exp_lut[2048];
  uint32_t trig_arg;
  uint32_t exp_arg;

  //uint32_t tau = 5;
  uint32_t alpha = 6;
  uint32_t beta = 7;
  uint32_t phi = 8;
  uint32_t fc = 9;
  uint32_t alpha2 = 10;
  uint32_t t;
  uint32_t t_sqr;
  uint32_t y_re[512];
  uint32_t y_im[512];

  for(i=0;i<2048;i++)
  {
    sin_lut[i] = i;
    cos_lut[i] = i;
    exp_lut[i] = i;
  }

  pinMode(5, OUTPUT);

  Serial.begin(9600);

  delay(100);

  while(1)
  {

    digitalWrite(5, HIGH);
    for(t = 0;t <512;t++)
    {
      t_sqr = t*t;
      trig_arg = phi + fc*t + alpha*t_sqr;
      exp_arg = alpha2*t_sqr;
      y_re[t] = beta*exp_lut[exp_arg%2048]*cos_lut[trig_arg%2048];
      y_im[t] = beta*exp_lut[exp_arg%2048]*sin_lut[trig_arg%2048];
    }
    digitalWrite(5, LOW);

    for(i=0;i<512;i++)
    {
      Serial.print(y_re[i]);
      Serial.print("\n");
      Serial.print(y_im[i]);
      Serial.print("\n");
    }

    delay(100);
  }

}
