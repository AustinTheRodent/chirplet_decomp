//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// fft.h
//
// Code generation for function 'fft'
//

#ifndef FFT_H
#define FFT_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void fft(const ::coder::array<creal_T, 1U> &x, double varargin_1,
         ::coder::array<creal_T, 1U> &y);

}

#endif
// End of code generation (fft.h)