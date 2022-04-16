//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// func_alpha1.cpp
//
// Code generation for function 'func_alpha1'
//

// Include files
#include "func_alpha1.h"
#include "func_alpha1_rtwutil.h"
#include "rt_nonfinite.h"
#include "xcorr.h"
#include "coder_array.h"
#include <cmath>

// Function Declarations
static void binary_expand_op(coder::array<creal_T, 2U> &y, double alpha1_,
                             const coder::array<double, 2U> &r,
                             const coder::array<double, 2U> &a_tmp,
                             const coder::array<double, 2U> &phi_,
                             const coder::array<creal_T, 2U> &b_y,
                             const coder::array<double, 2U> &r1);

static void minus(coder::array<double, 2U> &a_tmp,
                  const coder::array<double, 2U> &t,
                  const coder::array<double, 2U> &tau_);

static double rt_hypotd_snf(double u0, double u1);

// Function Definitions
static void binary_expand_op(coder::array<creal_T, 2U> &y, double alpha1_,
                             const coder::array<double, 2U> &r,
                             const coder::array<double, 2U> &a_tmp,
                             const coder::array<double, 2U> &phi_,
                             const coder::array<creal_T, 2U> &b_y,
                             const coder::array<double, 2U> &r1)
{
  double b_y_im;
  double b_y_re;
  double y_im;
  double y_re;
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  int stride_2_1;
  int stride_3_1;
  y_re = y[0].re;
  y_im = y[0].im;
  b_y_re = b_y[0].re;
  b_y_im = b_y[0].im;
  if (r1.size(1) == 1) {
    if (phi_.size(1) == 1) {
      if (a_tmp.size(1) == 1) {
        i = r.size(1);
      } else {
        i = a_tmp.size(1);
      }
    } else {
      i = phi_.size(1);
    }
  } else {
    i = r1.size(1);
  }
  y.set_size(1, i);
  stride_0_1 = (r.size(1) != 1);
  stride_1_1 = (a_tmp.size(1) != 1);
  stride_2_1 = (phi_.size(1) != 1);
  stride_3_1 = (r1.size(1) != 1);
  if (r1.size(1) == 1) {
    if (phi_.size(1) == 1) {
      if (a_tmp.size(1) == 1) {
        loop_ub = r.size(1);
      } else {
        loop_ub = a_tmp.size(1);
      }
    } else {
      loop_ub = phi_.size(1);
    }
  } else {
    loop_ub = r1.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    double d;
    double d1;
    double d2;
    d = a_tmp[i * stride_1_1];
    d1 = phi_[i * stride_2_1];
    d2 = r1[i * stride_3_1];
    y[i].re =
        ((-alpha1_ * r[i * stride_0_1] + y_re * d) + 0.0 * d1) + b_y_re * d2;
    y[i].im = (y_im * d + d1) + b_y_im * d2;
  }
}

static void minus(coder::array<double, 2U> &a_tmp,
                  const coder::array<double, 2U> &t,
                  const coder::array<double, 2U> &tau_)
{
  int i;
  int loop_ub;
  int stride_0_1;
  int stride_1_1;
  if (tau_.size(1) == 1) {
    i = t.size(1);
  } else {
    i = tau_.size(1);
  }
  a_tmp.set_size(1, i);
  stride_0_1 = (t.size(1) != 1);
  stride_1_1 = (tau_.size(1) != 1);
  if (tau_.size(1) == 1) {
    loop_ub = t.size(1);
  } else {
    loop_ub = tau_.size(1);
  }
  for (i = 0; i < loop_ub; i++) {
    a_tmp[i] = t[i * stride_0_1] - tau_[i * stride_1_1];
  }
}

static double rt_hypotd_snf(double u0, double u1)
{
  double a;
  double y;
  a = std::abs(u0);
  y = std::abs(u1);
  if (a < y) {
    a /= y;
    y *= std::sqrt(a * a + 1.0);
  } else if (a > y) {
    y /= a;
    y = a * std::sqrt(y * y + 1.0);
  } else if (!std::isnan(y)) {
    y = a * 1.4142135623730951;
  }
  return y;
}

double func_alpha1(const coder::array<double, 2U> &beta_,
                   const coder::array<double, 2U> &f_c_,
                   const coder::array<double, 2U> &tau_,
                   const coder::array<double, 2U> &alpha2_,
                   const coder::array<double, 2U> &phi_,
                   const coder::array<double, 2U> &t,
                   const coder::array<creal_T, 2U> &single_sig)
{
  coder::array<creal_T, 2U> CT1;
  coder::array<creal_T, 2U> b_y;
  coder::array<creal_T, 2U> y;
  coder::array<double, 2U> a_tmp;
  coder::array<double, 2U> b_r;
  coder::array<double, 2U> c_y;
  coder::array<double, 2U> r1;
  double alpha1_;
  double max_value;
  int b_loop_ub;
  int c_loop_ub;
  int indx;
  int loop_ub;
  indx = 0;
  max_value = 0.0;
  loop_ub = f_c_.size(1);
  b_loop_ub = alpha2_.size(1);
  c_loop_ub = beta_.size(1);
  for (int i{0}; i < 2000; i++) {
    double r;
    int k;
    int nx;
    // CT = xcorr(single_sig,chirp_sig);
    //   a = 4e6+i*(2e6/250);
    alpha1_ = (static_cast<double>(i) + 1.0) * 1.0E+9 + 2.4E+13;
    if (t.size(1) == tau_.size(1)) {
      a_tmp.set_size(1, t.size(1));
      nx = t.size(1);
      for (k = 0; k < nx; k++) {
        a_tmp[k] = t[k] - tau_[k];
      }
    } else {
      minus(a_tmp, t, tau_);
    }
    y.set_size(1, f_c_.size(1));
    for (k = 0; k < loop_ub; k++) {
      y[k].re = f_c_[k] * 0.0;
      y[k].im = f_c_[k] * 6.2831853071795862;
    }
    b_y.set_size(1, alpha2_.size(1));
    for (k = 0; k < b_loop_ub; k++) {
      b_y[k].re = alpha2_[k] * 0.0;
      b_y[k].im = alpha2_[k];
    }
    r = rt_powd_snf(6.2831853071795862 * alpha1_, 0.25);
    c_y.set_size(1, beta_.size(1));
    for (k = 0; k < c_loop_ub; k++) {
      c_y[k] = beta_[k] * r;
    }
    b_r.set_size(1, a_tmp.size(1));
    nx = a_tmp.size(1);
    for (k = 0; k < nx; k++) {
      r = a_tmp[k];
      b_r[k] = r * r;
    }
    r1.set_size(1, a_tmp.size(1));
    nx = a_tmp.size(1);
    for (k = 0; k < nx; k++) {
      r = a_tmp[k];
      r1[k] = r * r;
    }
    if (b_r.size(1) == 1) {
      nx = a_tmp.size(1);
    } else {
      nx = b_r.size(1);
    }
    if (b_r.size(1) == 1) {
      k = a_tmp.size(1);
    } else {
      k = b_r.size(1);
    }
    if (k == 1) {
      k = phi_.size(1);
    } else if (b_r.size(1) == 1) {
      k = a_tmp.size(1);
    } else {
      k = b_r.size(1);
    }
    if ((b_r.size(1) == a_tmp.size(1)) && (nx == phi_.size(1)) &&
        (k == r1.size(1))) {
      double y_im;
      r = y[0].re;
      y_im = y[0].im;
      y.set_size(1, b_r.size(1));
      nx = b_r.size(1);
      for (k = 0; k < nx; k++) {
        y[k].re = ((-alpha1_ * b_r[k] + r * a_tmp[k]) + 0.0 * phi_[k]) +
                  b_y[0].re * r1[k];
        y[k].im = (y_im * a_tmp[k] + phi_[k]) + b_y[0].im * r1[k];
      }
    } else {
      binary_expand_op(y, alpha1_, b_r, a_tmp, phi_, b_y, r1);
    }
    nx = y.size(1);
    for (k = 0; k < nx; k++) {
      if (y[k].im == 0.0) {
        y[k].re = std::exp(y[k].re);
        y[k].im = 0.0;
      } else if (std::isinf(y[k].im) && std::isinf(y[k].re) &&
                 (y[k].re < 0.0)) {
        y[k].re = 0.0;
        y[k].im = 0.0;
      } else {
        r = std::exp(y[k].re / 2.0);
        y[k].re = r * (r * std::cos(y[k].im));
        y[k].im = r * (r * std::sin(y[k].im));
      }
    }
    // chirp_sig =
    // beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    r = c_y[0];
    b_y.set_size(1, y.size(1));
    nx = y.size(1);
    for (k = 0; k < nx; k++) {
      b_y[k].re = r * y[k].re;
      b_y[k].im = r * y[k].im;
    }
    coder::xcorr(b_y, single_sig, CT1);
    //   figure();
    //   plot(abs(CT_cur)
    r = rt_hypotd_snf(CT1[100000].re, CT1[100000].im);
    if (r > max_value) {
      max_value = r;
      indx = i + 1;
    }
  }
  return static_cast<double>(indx) * 1.0E+9 + 2.4E+13;
}

// End of code generation (func_alpha1.cpp)
