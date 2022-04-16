//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_func_alpha1_api.h
//
// Code generation for function 'func_alpha1'
//

#ifndef _CODER_FUNC_ALPHA1_API_H
#define _CODER_FUNC_ALPHA1_API_H

// Include files
#include "coder_array_mex.h"
#include "emlrt.h"
#include "tmwtypes.h"
#include <algorithm>
#include <cstring>

// Variable Declarations
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

// Function Declarations
real_T func_alpha1(coder::array<real_T, 2U> *beta_,
                   coder::array<real_T, 2U> *f_c_,
                   coder::array<real_T, 2U> *tau_,
                   coder::array<real_T, 2U> *alpha2_,
                   coder::array<real_T, 2U> *phi_, coder::array<real_T, 2U> *t,
                   coder::array<creal_T, 2U> *single_sig);

void func_alpha1_api(const mxArray *const prhs[7], const mxArray **plhs);

void func_alpha1_atexit();

void func_alpha1_initialize();

void func_alpha1_terminate();

void func_alpha1_xil_shutdown();

void func_alpha1_xil_terminate();

#endif
// End of code generation (_coder_func_alpha1_api.h)
