//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// xcorr.cpp
//
// Code generation for function 'xcorr'
//

// Include files
#include "xcorr.h"
#include "FFTImplementationCallback.h"
#include "fft.h"
#include "func_alpha1_rtwutil.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>
#include <math.h>

// Function Declarations
namespace coder {
static void crosscorrTD(const ::coder::array<creal_T, 1U> &x,
                        const ::coder::array<creal_T, 1U> &y, double maxlag,
                        ::coder::array<creal_T, 1U> &c);

}

// Function Definitions
namespace coder {
static void crosscorrTD(const ::coder::array<creal_T, 1U> &x,
                        const ::coder::array<creal_T, 1U> &y, double maxlag,
                        ::coder::array<creal_T, 1U> &c)
{
  double b_im;
  double b_re;
  double b_s_re_tmp;
  double mxl;
  double s_im;
  double s_re;
  double s_re_tmp;
  int b_i;
  int b_re_tmp;
  int i;
  int k;
  int loop_ub_tmp;
  int m;
  int n;
  m = x.size(0);
  n = y.size(0);
  mxl = std::fmin(maxlag, std::fmax(static_cast<double>(x.size(0)),
                                    static_cast<double>(y.size(0))) -
                              1.0);
  loop_ub_tmp = static_cast<int>(2.0 * mxl + 1.0);
  c.set_size(loop_ub_tmp);
  for (i = 0; i < loop_ub_tmp; i++) {
    c[i].re = 0.0;
    c[i].im = 0.0;
  }
  i = static_cast<int>(mxl + 1.0);
  for (k = 0; k < i; k++) {
    s_re = 0.0;
    s_im = 0.0;
    loop_ub_tmp = static_cast<int>(
        std::fmin(static_cast<double>(m - k), static_cast<double>(n)));
    for (b_i = 0; b_i < loop_ub_tmp; b_i++) {
      b_re_tmp = k + b_i;
      b_re = x[b_re_tmp].re;
      b_im = x[b_re_tmp].im;
      s_re_tmp = y[b_i].re;
      b_s_re_tmp = y[b_i].im;
      s_re += s_re_tmp * b_re + b_s_re_tmp * b_im;
      s_im += s_re_tmp * b_im - b_s_re_tmp * b_re;
    }
    loop_ub_tmp = static_cast<int>((mxl + static_cast<double>(k)) + 1.0) - 1;
    c[loop_ub_tmp].re = s_re;
    c[loop_ub_tmp].im = s_im;
  }
  i = static_cast<int>(mxl);
  for (k = 0; k < i; k++) {
    s_re = 0.0;
    s_im = 0.0;
    loop_ub_tmp = static_cast<int>(
        std::fmin(static_cast<double>(m),
                  static_cast<double>(n) - (static_cast<double>(k) + 1.0)));
    for (b_i = 0; b_i < loop_ub_tmp; b_i++) {
      b_re_tmp = (k + b_i) + 1;
      b_re = y[b_re_tmp].re;
      b_im = y[b_re_tmp].im;
      s_re_tmp = x[b_i].im;
      b_s_re_tmp = x[b_i].re;
      s_re += b_re * b_s_re_tmp + b_im * s_re_tmp;
      s_im += b_re * s_re_tmp - b_im * b_s_re_tmp;
    }
    loop_ub_tmp =
        static_cast<int>((mxl - (static_cast<double>(k) + 1.0)) + 1.0) - 1;
    c[loop_ub_tmp].re = s_re;
    c[loop_ub_tmp].im = s_im;
  }
}

void xcorr(const ::coder::array<creal_T, 2U> &x,
           const ::coder::array<creal_T, 2U> &varargin_1,
           ::coder::array<creal_T, 2U> &c)
{
  array<creal_T, 1U> X;
  array<creal_T, 1U> Y;
  array<creal_T, 1U> b_c1;
  array<creal_T, 1U> b_varargin_1;
  array<creal_T, 1U> b_x;
  array<creal_T, 1U> c1;
  array<creal_T, 1U> r1;
  array<double, 2U> costab;
  array<double, 2U> costab1q;
  array<double, 2U> r;
  array<double, 2U> sintab;
  array<double, 2U> sintabinv;
  double m2;
  double mxl;
  double tdops;
  int c0;
  int ceilLog2;
  int i;
  int m;
  int maxval;
  int n;
  maxval =
      static_cast<int>(std::fmax(static_cast<double>(x.size(1)),
                                 static_cast<double>(varargin_1.size(1)))) -
      1;
  m = x.size(1);
  c0 = varargin_1.size(1);
  b_x = x.reshape(m);
  b_varargin_1 = varargin_1.reshape(c0);
  m = static_cast<int>(std::fmax(static_cast<double>(b_x.size(0)),
                                 static_cast<double>(b_varargin_1.size(0))));
  mxl = std::fmin(static_cast<double>(maxval + 1) - 1.0,
                  static_cast<double>(m) - 1.0);
  tdops = frexp(static_cast<double>(static_cast<int>(
                    std::abs(2.0 * static_cast<double>(m) - 1.0))),
                &ceilLog2);
  if (tdops == 0.5) {
    ceilLog2--;
  }
  m2 = rt_powd_snf(2.0, static_cast<double>(ceilLog2));
  m = static_cast<int>(std::fmax(static_cast<double>(b_x.size(0)),
                                 static_cast<double>(b_varargin_1.size(0))));
  n = static_cast<int>(std::fmin(static_cast<double>(b_x.size(0)),
                                 static_cast<double>(b_varargin_1.size(0))));
  c0 = (n << 3) - 2;
  if (mxl <= static_cast<double>(n) - 1.0) {
    tdops = mxl * ((static_cast<double>(c0) - 4.0 * mxl) - 4.0);
    if (mxl <= m - n) {
      tdops += static_cast<double>(c0) + mxl * static_cast<double>(c0);
    } else {
      tdops +=
          (static_cast<double>(c0) +
           static_cast<double>(m - n) * static_cast<double>(c0)) +
          (mxl - static_cast<double>(m - n)) *
              (4.0 * ((static_cast<double>(m) - mxl) + static_cast<double>(n)) -
               6.0);
    }
  } else if (mxl <= static_cast<double>(m) - 1.0) {
    tdops = (static_cast<double>(n) - 1.0) * static_cast<double>(c0) -
            4.0 * (static_cast<double>(n) - 1.0) * static_cast<double>(n);
    if (static_cast<int>(mxl) <= m - n) {
      tdops += static_cast<double>(c0) + mxl * static_cast<double>(c0);
    } else {
      tdops +=
          (static_cast<double>(c0) +
           static_cast<double>(m - n) * static_cast<double>(c0)) +
          (mxl - static_cast<double>(m - n)) *
              (4.0 * ((static_cast<double>(m) - mxl) + static_cast<double>(n)) -
               6.0);
    }
  } else {
    tdops = 8.0 * static_cast<double>(m) * static_cast<double>(n) -
            2.0 * (static_cast<double>(m + n) - 1.0);
  }
  if (tdops < m2 * (15.0 * static_cast<double>(ceilLog2) + 6.0)) {
    crosscorrTD(b_x, b_varargin_1, mxl, c1);
  } else {
    fft(b_x, m2, X);
    fft(b_varargin_1, m2, Y);
    Y.set_size(X.size(0));
    m = X.size(0);
    for (i = 0; i < m; i++) {
      double Y_im;
      double d;
      double d1;
      tdops = Y[i].re;
      Y_im = -Y[i].im;
      d = X[i].re;
      d1 = X[i].im;
      Y[i].re = d * tdops - d1 * Y_im;
      Y[i].im = d * Y_im + d1 * tdops;
    }
    if (Y.size(0) == 0) {
      X.set_size(0);
    } else {
      boolean_T useRadix2;
      useRadix2 = ((Y.size(0) & (Y.size(0) - 1)) == 0);
      internal::FFTImplementationCallback::get_algo_sizes(Y.size(0), useRadix2,
                                                          &c0, &m);
      tdops = 6.2831853071795862 / static_cast<double>(m);
      n = m / 2 / 2;
      costab1q.set_size(1, n + 1);
      costab1q[0] = 1.0;
      m = n / 2 - 1;
      for (ceilLog2 = 0; ceilLog2 <= m; ceilLog2++) {
        costab1q[ceilLog2 + 1] =
            std::cos(tdops * (static_cast<double>(ceilLog2) + 1.0));
      }
      i = m + 2;
      m = n - 1;
      for (ceilLog2 = i; ceilLog2 <= m; ceilLog2++) {
        costab1q[ceilLog2] =
            std::sin(tdops * static_cast<double>(n - ceilLog2));
      }
      costab1q[n] = 0.0;
      if (!useRadix2) {
        n = costab1q.size(1) - 1;
        m = (costab1q.size(1) - 1) << 1;
        costab.set_size(1, m + 1);
        sintab.set_size(1, m + 1);
        costab[0] = 1.0;
        sintab[0] = 0.0;
        sintabinv.set_size(1, m + 1);
        for (ceilLog2 = 0; ceilLog2 < n; ceilLog2++) {
          sintabinv[ceilLog2 + 1] = costab1q[(n - ceilLog2) - 1];
        }
        i = costab1q.size(1);
        for (ceilLog2 = i; ceilLog2 <= m; ceilLog2++) {
          sintabinv[ceilLog2] = costab1q[ceilLog2 - n];
        }
        for (ceilLog2 = 0; ceilLog2 < n; ceilLog2++) {
          costab[ceilLog2 + 1] = costab1q[ceilLog2 + 1];
          sintab[ceilLog2 + 1] = -costab1q[(n - ceilLog2) - 1];
        }
        i = costab1q.size(1);
        for (ceilLog2 = i; ceilLog2 <= m; ceilLog2++) {
          costab[ceilLog2] = -costab1q[m - ceilLog2];
          sintab[ceilLog2] = -costab1q[ceilLog2 - n];
        }
      } else {
        n = costab1q.size(1) - 1;
        m = (costab1q.size(1) - 1) << 1;
        costab.set_size(1, m + 1);
        sintab.set_size(1, m + 1);
        costab[0] = 1.0;
        sintab[0] = 0.0;
        for (ceilLog2 = 0; ceilLog2 < n; ceilLog2++) {
          costab[ceilLog2 + 1] = costab1q[ceilLog2 + 1];
          sintab[ceilLog2 + 1] = costab1q[(n - ceilLog2) - 1];
        }
        i = costab1q.size(1);
        for (ceilLog2 = i; ceilLog2 <= m; ceilLog2++) {
          costab[ceilLog2] = -costab1q[m - ceilLog2];
          sintab[ceilLog2] = costab1q[ceilLog2 - n];
        }
        sintabinv.set_size(1, 0);
      }
      if (useRadix2) {
        internal::FFTImplementationCallback::b_r2br_r2dit_trig(
            Y, Y.size(0), costab, sintab, r1);
        X.set_size(r1.size(0));
        m = r1.size(0);
        for (i = 0; i < m; i++) {
          X[i] = r1[i];
        }
      } else {
        internal::FFTImplementationCallback::b_dobluesteinfft(
            Y, c0, Y.size(0), costab, sintab, sintabinv, X);
      }
    }
    if (mxl < 1.0) {
      r.set_size(1, 0);
    } else {
      m = static_cast<int>(mxl) - 1;
      r.set_size(1, m + 1);
      for (i = 0; i <= m; i++) {
        r[i] = static_cast<double>(i) + 1.0;
      }
    }
    if (1.0 > mxl + 1.0) {
      m = 0;
    } else {
      m = static_cast<int>(mxl + 1.0);
    }
    m2 -= mxl;
    c1.set_size(r.size(1) + m);
    c0 = r.size(1);
    for (i = 0; i < c0; i++) {
      c1[i] = X[static_cast<int>(m2 + r[i]) - 1];
    }
    for (i = 0; i < m; i++) {
      c1[i + r.size(1)] = X[i];
    }
  }
  m = maxval << 1;
  b_c1.set_size(m + 1);
  for (i = 0; i <= m; i++) {
    b_c1[i].re = 0.0;
    b_c1[i].im = 0.0;
  }
  m = c1.size(0);
  for (i = 0; i < m; i++) {
    b_c1[i] = c1[i];
  }
  c.set_size(1, b_c1.size(0));
  m = b_c1.size(0);
  for (i = 0; i < m; i++) {
    c[i] = b_c1[i];
  }
}

} // namespace coder

// End of code generation (xcorr.cpp)
