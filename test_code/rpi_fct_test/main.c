/*
 * blink.c:
 *      blinks the first LED
 *      Gordon Henderson, projects@drogon.net
 */

#include <stdio.h>
#include <wiringPi.h>
#include <stdint.h>

int main (void)
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

  if (wiringPiSetup () == -1)
    return 1 ;

  for(i=0;i<2048;i++)
  {
    sin_lut[i] = i;
    cos_lut[i] = i;
    exp_lut[i] = i;
  }

  pinMode (0, OUTPUT) ;         // aka BCM_GPIO pin 17

  delay(100);

  while(1)
  {

    digitalWrite (0, 1) ;       // On
    for(t = 0;t <512;t++)
    {
      t_sqr = t*t;
      trig_arg = phi + fc*t + alpha*t_sqr;
      exp_arg = alpha2*t_sqr;
      y_re[t] = beta*exp_lut[exp_arg%2048]*cos_lut[trig_arg%2048];
      y_im[t] = beta*exp_lut[exp_arg%2048]*sin_lut[trig_arg%2048];
    }
    digitalWrite (0, 0) ;       // Off

    for(i=0;i<512;i++)
    {
      printf("%i\n", y_re[i]);
      printf("%i\n", y_im[i]);
    }

    delay(100);
  }

  printf ("Raspberry Pi blink\n") ;



  

  for (;;)
  {
    
    //delay (500) ;               // mS
    
    //delay (500) ;
  }
  return 0 ;
}
