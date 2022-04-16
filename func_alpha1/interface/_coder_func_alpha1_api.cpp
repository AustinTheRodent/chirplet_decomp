//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_func_alpha1_api.cpp
//
// Code generation for function 'func_alpha1'
//

// Include files
#include "_coder_func_alpha1_api.h"
#include "_coder_func_alpha1_mex.h"
#include "coder_array_mex.h"

// Variable Definitions
emlrtCTX emlrtRootTLSGlobal{nullptr};

emlrtContext emlrtContextGlobal{
    true,                                                 // bFirstTime
    false,                                                // bInitialized
    131611U,                                              // fVersionInfo
    nullptr,                                              // fErrorFunction
    "func_alpha1",                                        // fFunctionName
    nullptr,                                              // fRTCallStack
    false,                                                // bDebugMode
    {2045744189U, 2170104910U, 2743257031U, 4284093946U}, // fSigWrd
    nullptr                                               // fSigMem
};

// Function Declarations
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret);

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<creal_T, 2U> &ret);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *beta_,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *single_sig,
                             const char_T *identifier,
                             coder::array<creal_T, 2U> &y);

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<creal_T, 2U> &y);

static const mxArray *emlrt_marshallOut(const real_T u);

// Function Definitions
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<real_T, 2U> &ret)
{
  static const int32_T dims[2]{1, 100001};
  int32_T iv[2];
  const boolean_T bv[2]{false, true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                            false, 2U, (void *)&dims[0], &bv[0], &iv[0]);
  ret.prealloc(iv[0] * iv[1]);
  ret.set_size(iv[0], iv[1]);
  ret.set((real_T *)emlrtMxGetData(src), ret.size(0), ret.size(1));
  emlrtDestroyArray(&src);
}

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
                               const emlrtMsgIdentifier *msgId,
                               coder::array<creal_T, 2U> &ret)
{
  static const int32_T dims[2]{1, 100001};
  int32_T iv[2];
  const boolean_T bv[2]{false, true};
  emlrtCheckVsBuiltInR2012b((emlrtCTX)sp, msgId, src, (const char_T *)"double",
                            true, 2U, (void *)&dims[0], &bv[0], &iv[0]);
  ret.set_size(iv[0], iv[1]);
  emlrtImportArrayR2015b((emlrtCTX)sp, src, &ret[0], 8, true);
  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *beta_,
                             const char_T *identifier,
                             coder::array<real_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(beta_), &thisId, y);
  emlrtDestroyArray(&beta_);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<real_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *single_sig,
                             const char_T *identifier,
                             coder::array<creal_T, 2U> &y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char_T *>(identifier);
  thisId.fParent = nullptr;
  thisId.bParentIsCell = false;
  emlrt_marshallIn(sp, emlrtAlias(single_sig), &thisId, y);
  emlrtDestroyArray(&single_sig);
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
                             const emlrtMsgIdentifier *parentId,
                             coder::array<creal_T, 2U> &y)
{
  b_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static const mxArray *emlrt_marshallOut(const real_T u)
{
  const mxArray *m;
  const mxArray *y;
  y = nullptr;
  m = emlrtCreateDoubleScalar(u);
  emlrtAssign(&y, m);
  return y;
}

void func_alpha1_api(const mxArray *const prhs[7], const mxArray **plhs)
{
  coder::array<creal_T, 2U> single_sig;
  coder::array<real_T, 2U> alpha2_;
  coder::array<real_T, 2U> beta_;
  coder::array<real_T, 2U> f_c_;
  coder::array<real_T, 2U> phi_;
  coder::array<real_T, 2U> t;
  coder::array<real_T, 2U> tau_;
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  real_T alpha1_;
  st.tls = emlrtRootTLSGlobal;
  emlrtHeapReferenceStackEnterFcnR2012b(&st);
  // Marshall function inputs
  beta_.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "beta_", beta_);
  f_c_.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs[1]), "f_c_", f_c_);
  tau_.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs[2]), "tau_", tau_);
  alpha2_.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs[3]), "alpha2_", alpha2_);
  phi_.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs[4]), "phi_", phi_);
  t.no_free();
  emlrt_marshallIn(&st, emlrtAlias(prhs[5]), "t", t);
  emlrt_marshallIn(&st, emlrtAliasP(prhs[6]), "single_sig", single_sig);
  // Invoke the target function
  alpha1_ = func_alpha1(beta_, f_c_, tau_, alpha2_, phi_, t, single_sig);
  // Marshall function outputs
  *plhs = emlrt_marshallOut(alpha1_);
  emlrtHeapReferenceStackLeaveFcnR2012b(&st);
}

void func_alpha1_atexit()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  func_alpha1_xil_terminate();
  func_alpha1_xil_shutdown();
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void func_alpha1_initialize()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, nullptr);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

void func_alpha1_terminate()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

// End of code generation (_coder_func_alpha1_api.cpp)
