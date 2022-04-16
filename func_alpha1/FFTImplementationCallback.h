//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// FFTImplementationCallback.h
//
// Code generation for function 'FFTImplementationCallback'
//

#ifndef FFTIMPLEMENTATIONCALLBACK_H
#define FFTIMPLEMENTATIONCALLBACK_H

// Include files
#include "rtwtypes.h"
#include "coder_array.h"
#include <cstddef>
#include <cstdlib>

// Type Definitions
namespace coder {
namespace internal {
class FFTImplementationCallback {
public:
  static void get_algo_sizes(int nfft, boolean_T useRadix2, int *n2blue,
                             int *nRows);
  static void r2br_r2dit_trig(const ::coder::array<creal_T, 1U> &x,
                              int n1_unsigned,
                              const ::coder::array<double, 2U> &costab,
                              const ::coder::array<double, 2U> &sintab,
                              ::coder::array<creal_T, 1U> &y);
  static void dobluesteinfft(const ::coder::array<creal_T, 1U> &x, int n2blue,
                             int nfft, const ::coder::array<double, 2U> &costab,
                             const ::coder::array<double, 2U> &sintab,
                             const ::coder::array<double, 2U> &sintabinv,
                             ::coder::array<creal_T, 1U> &y);
  static void b_r2br_r2dit_trig(const ::coder::array<creal_T, 1U> &x,
                                int n1_unsigned,
                                const ::coder::array<double, 2U> &costab,
                                const ::coder::array<double, 2U> &sintab,
                                ::coder::array<creal_T, 1U> &y);
  static void b_dobluesteinfft(const ::coder::array<creal_T, 1U> &x, int n2blue,
                               int nfft,
                               const ::coder::array<double, 2U> &costab,
                               const ::coder::array<double, 2U> &sintab,
                               const ::coder::array<double, 2U> &sintabinv,
                               ::coder::array<creal_T, 1U> &y);
};

} // namespace internal
} // namespace coder

#endif
// End of code generation (FFTImplementationCallback.h)
