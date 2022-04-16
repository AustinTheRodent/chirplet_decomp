//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xcorr.h
//
// Code generation for function 'xcorr'
//

#ifndef XCORR_H
#define XCORR_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Function Declarations
namespace coder {
void xcorr(const ::coder::array<creal_T, 2U> &x,
           const ::coder::array<creal_T, 2U> &varargin_1,
           ::coder::array<creal_T, 2U> &c);

}

#endif
// End of code generation (xcorr.h)
