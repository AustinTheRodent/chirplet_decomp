//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// fft.cpp
//
// Code generation for function 'fft'
//

// Include files
#include "fft.h"
#include "FFTImplementationCallback.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
void fft(const ::coder::array<creal_T, 1U> &x, double varargin_1,
         ::coder::array<creal_T, 1U> &y)
{
  array<creal_T, 1U> r;
  array<double, 2U> costab;
  array<double, 2U> costab1q;
  array<double, 2U> sintab;
  array<double, 2U> sintabinv;
  int N2blue;
  int nd2;
  if ((x.size(0) == 0) || (0 == static_cast<int>(varargin_1))) {
    nd2 = static_cast<int>(varargin_1);
    y.set_size(nd2);
    for (int i{0}; i < nd2; i++) {
      y[i].re = 0.0;
      y[i].im = 0.0;
    }
  } else {
    double e;
    int i;
    int k;
    int n;
    boolean_T useRadix2;
    useRadix2 = ((static_cast<int>(varargin_1) > 0) &&
                 ((static_cast<int>(varargin_1) &
                   (static_cast<int>(varargin_1) - 1)) == 0));
    internal::FFTImplementationCallback::get_algo_sizes(
        static_cast<int>(varargin_1), useRadix2, &N2blue, &nd2);
    e = 6.2831853071795862 / static_cast<double>(nd2);
    n = nd2 / 2 / 2;
    costab1q.set_size(1, n + 1);
    costab1q[0] = 1.0;
    nd2 = n / 2 - 1;
    for (k = 0; k <= nd2; k++) {
      costab1q[k + 1] = std::cos(e * (static_cast<double>(k) + 1.0));
    }
    i = nd2 + 2;
    nd2 = n - 1;
    for (k = i; k <= nd2; k++) {
      costab1q[k] = std::sin(e * static_cast<double>(n - k));
    }
    costab1q[n] = 0.0;
    if (!useRadix2) {
      n = costab1q.size(1) - 1;
      nd2 = (costab1q.size(1) - 1) << 1;
      costab.set_size(1, nd2 + 1);
      sintab.set_size(1, nd2 + 1);
      costab[0] = 1.0;
      sintab[0] = 0.0;
      sintabinv.set_size(1, nd2 + 1);
      for (k = 0; k < n; k++) {
        sintabinv[k + 1] = costab1q[(n - k) - 1];
      }
      i = costab1q.size(1);
      for (k = i; k <= nd2; k++) {
        sintabinv[k] = costab1q[k - n];
      }
      for (k = 0; k < n; k++) {
        costab[k + 1] = costab1q[k + 1];
        sintab[k + 1] = -costab1q[(n - k) - 1];
      }
      i = costab1q.size(1);
      for (k = i; k <= nd2; k++) {
        costab[k] = -costab1q[nd2 - k];
        sintab[k] = -costab1q[k - n];
      }
    } else {
      n = costab1q.size(1) - 1;
      nd2 = (costab1q.size(1) - 1) << 1;
      costab.set_size(1, nd2 + 1);
      sintab.set_size(1, nd2 + 1);
      costab[0] = 1.0;
      sintab[0] = 0.0;
      for (k = 0; k < n; k++) {
        costab[k + 1] = costab1q[k + 1];
        sintab[k + 1] = -costab1q[(n - k) - 1];
      }
      i = costab1q.size(1);
      for (k = i; k <= nd2; k++) {
        costab[k] = -costab1q[nd2 - k];
        sintab[k] = -costab1q[k - n];
      }
      sintabinv.set_size(1, 0);
    }
    if (useRadix2) {
      internal::FFTImplementationCallback::r2br_r2dit_trig(
          x, static_cast<int>(varargin_1), costab, sintab, r);
      y.set_size(r.size(0));
      nd2 = r.size(0);
      for (i = 0; i < nd2; i++) {
        y[i] = r[i];
      }
    } else {
      internal::FFTImplementationCallback::dobluesteinfft(
          x, N2blue, static_cast<int>(varargin_1), costab, sintab, sintabinv,
          y);
    }
  }
}

} // namespace coder

// End of code generation (fft.cpp)
