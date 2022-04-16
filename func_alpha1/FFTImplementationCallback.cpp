//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// FFTImplementationCallback.cpp
//
// Code generation for function 'FFTImplementationCallback'
//

// Include files
#include "FFTImplementationCallback.h"
#include "rt_nonfinite.h"
#include "coder_array.h"
#include <cmath>

// Function Definitions
namespace coder {
namespace internal {
void FFTImplementationCallback::b_dobluesteinfft(
    const ::coder::array<creal_T, 1U> &x, int n2blue, int nfft,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab,
    const ::coder::array<double, 2U> &sintabinv, ::coder::array<creal_T, 1U> &y)
{
  array<creal_T, 1U> b_fv;
  array<creal_T, 1U> fv;
  array<creal_T, 1U> wwc;
  double b_re_tmp;
  double nt_im;
  double nt_re;
  double re_tmp;
  int i;
  int k;
  int minNrowsNx;
  int nInt2;
  int nInt2m1;
  int rt;
  nInt2m1 = (nfft + nfft) - 1;
  wwc.set_size(nInt2m1);
  rt = 0;
  wwc[nfft - 1].re = 1.0;
  wwc[nfft - 1].im = 0.0;
  nInt2 = nfft << 1;
  for (k = 0; k <= nfft - 2; k++) {
    minNrowsNx = ((k + 1) << 1) - 1;
    if (nInt2 - rt <= minNrowsNx) {
      rt += minNrowsNx - nInt2;
    } else {
      rt += minNrowsNx;
    }
    nt_im = 3.1415926535897931 * static_cast<double>(rt) /
            static_cast<double>(nfft);
    if (nt_im == 0.0) {
      nt_re = 1.0;
      nt_im = 0.0;
    } else {
      nt_re = std::cos(nt_im);
      nt_im = std::sin(nt_im);
    }
    i = (nfft - k) - 2;
    wwc[i].re = nt_re;
    wwc[i].im = -nt_im;
  }
  i = nInt2m1 - 1;
  for (k = i; k >= nfft; k--) {
    wwc[k] = wwc[(nInt2m1 - k) - 1];
  }
  fv.set_size(nfft);
  if (nfft > x.size(0)) {
    fv.set_size(nfft);
    for (i = 0; i < nfft; i++) {
      fv[i].re = 0.0;
      fv[i].im = 0.0;
    }
  }
  y.set_size(fv.size(0));
  minNrowsNx = fv.size(0);
  for (i = 0; i < minNrowsNx; i++) {
    y[i] = fv[i];
  }
  minNrowsNx = x.size(0);
  if (nfft <= minNrowsNx) {
    minNrowsNx = nfft;
  }
  for (k = 0; k < minNrowsNx; k++) {
    nInt2m1 = (nfft + k) - 1;
    nt_re = wwc[nInt2m1].re;
    nt_im = wwc[nInt2m1].im;
    re_tmp = x[k].im;
    b_re_tmp = x[k].re;
    y[k].re = nt_re * b_re_tmp + nt_im * re_tmp;
    y[k].im = nt_re * re_tmp - nt_im * b_re_tmp;
  }
  i = minNrowsNx + 1;
  for (k = i; k <= nfft; k++) {
    y[k - 1].re = 0.0;
    y[k - 1].im = 0.0;
  }
  FFTImplementationCallback::r2br_r2dit_trig(y, n2blue, costab, sintab, fv);
  FFTImplementationCallback::r2br_r2dit_trig(wwc, n2blue, costab, sintab, b_fv);
  b_fv.set_size(fv.size(0));
  minNrowsNx = fv.size(0);
  for (i = 0; i < minNrowsNx; i++) {
    nt_re = fv[i].re;
    nt_im = b_fv[i].im;
    re_tmp = fv[i].im;
    b_re_tmp = b_fv[i].re;
    b_fv[i].re = nt_re * b_re_tmp - re_tmp * nt_im;
    b_fv[i].im = nt_re * nt_im + re_tmp * b_re_tmp;
  }
  FFTImplementationCallback::b_r2br_r2dit_trig(b_fv, n2blue, costab, sintabinv,
                                               fv);
  i = wwc.size(0);
  for (k = nfft; k <= i; k++) {
    double ar;
    nt_re = wwc[k - 1].re;
    nt_im = fv[k - 1].im;
    re_tmp = wwc[k - 1].im;
    b_re_tmp = fv[k - 1].re;
    ar = nt_re * b_re_tmp + re_tmp * nt_im;
    nt_re = nt_re * nt_im - re_tmp * b_re_tmp;
    if (nt_re == 0.0) {
      minNrowsNx = k - nfft;
      y[minNrowsNx].re = ar / static_cast<double>(nfft);
      y[minNrowsNx].im = 0.0;
    } else if (ar == 0.0) {
      minNrowsNx = k - nfft;
      y[minNrowsNx].re = 0.0;
      y[minNrowsNx].im = nt_re / static_cast<double>(nfft);
    } else {
      minNrowsNx = k - nfft;
      y[minNrowsNx].re = ar / static_cast<double>(nfft);
      y[minNrowsNx].im = nt_re / static_cast<double>(nfft);
    }
  }
}

void FFTImplementationCallback::b_r2br_r2dit_trig(
    const ::coder::array<creal_T, 1U> &x, int n1_unsigned,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab, ::coder::array<creal_T, 1U> &y)
{
  double temp_im;
  double temp_re;
  double temp_re_tmp;
  double twid_re;
  int i;
  int iDelta2;
  int iheight;
  int istart;
  int iy;
  int ju;
  int k;
  int nRowsD2;
  y.set_size(n1_unsigned);
  if (n1_unsigned > x.size(0)) {
    y.set_size(n1_unsigned);
    for (iDelta2 = 0; iDelta2 < n1_unsigned; iDelta2++) {
      y[iDelta2].re = 0.0;
      y[iDelta2].im = 0.0;
    }
  }
  iheight = x.size(0);
  if (iheight > n1_unsigned) {
    iheight = n1_unsigned;
  }
  istart = n1_unsigned - 2;
  nRowsD2 = n1_unsigned / 2;
  k = nRowsD2 / 2;
  iy = 0;
  ju = 0;
  for (i = 0; i <= iheight - 2; i++) {
    boolean_T tst;
    y[iy] = x[i];
    iDelta2 = n1_unsigned;
    tst = true;
    while (tst) {
      iDelta2 >>= 1;
      ju ^= iDelta2;
      tst = ((ju & iDelta2) == 0);
    }
    iy = ju;
  }
  y[iy] = x[iheight - 1];
  if (n1_unsigned > 1) {
    for (i = 0; i <= istart; i += 2) {
      temp_re_tmp = y[i + 1].re;
      temp_im = y[i + 1].im;
      temp_re = y[i].re;
      twid_re = y[i].im;
      y[i + 1].re = temp_re - temp_re_tmp;
      y[i + 1].im = twid_re - temp_im;
      y[i].re = temp_re + temp_re_tmp;
      y[i].im = twid_re + temp_im;
    }
  }
  iy = 2;
  iDelta2 = 4;
  iheight = ((k - 1) << 2) + 1;
  while (k > 0) {
    int b_temp_re_tmp;
    for (i = 0; i < iheight; i += iDelta2) {
      b_temp_re_tmp = i + iy;
      temp_re = y[b_temp_re_tmp].re;
      temp_im = y[b_temp_re_tmp].im;
      y[b_temp_re_tmp].re = y[i].re - temp_re;
      y[b_temp_re_tmp].im = y[i].im - temp_im;
      y[i].re = y[i].re + temp_re;
      y[i].im = y[i].im + temp_im;
    }
    istart = 1;
    for (ju = k; ju < nRowsD2; ju += k) {
      double twid_im;
      int ihi;
      twid_re = costab[ju];
      twid_im = sintab[ju];
      i = istart;
      ihi = istart + iheight;
      while (i < ihi) {
        b_temp_re_tmp = i + iy;
        temp_re_tmp = y[b_temp_re_tmp].im;
        temp_im = y[b_temp_re_tmp].re;
        temp_re = twid_re * temp_im - twid_im * temp_re_tmp;
        temp_im = twid_re * temp_re_tmp + twid_im * temp_im;
        y[b_temp_re_tmp].re = y[i].re - temp_re;
        y[b_temp_re_tmp].im = y[i].im - temp_im;
        y[i].re = y[i].re + temp_re;
        y[i].im = y[i].im + temp_im;
        i += iDelta2;
      }
      istart++;
    }
    k /= 2;
    iy = iDelta2;
    iDelta2 += iDelta2;
    iheight -= iy;
  }
  if (y.size(0) > 1) {
    temp_im = 1.0 / static_cast<double>(y.size(0));
    iy = y.size(0);
    for (iDelta2 = 0; iDelta2 < iy; iDelta2++) {
      y[iDelta2].re = temp_im * y[iDelta2].re;
      y[iDelta2].im = temp_im * y[iDelta2].im;
    }
  }
}

void FFTImplementationCallback::dobluesteinfft(
    const ::coder::array<creal_T, 1U> &x, int n2blue, int nfft,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab,
    const ::coder::array<double, 2U> &sintabinv, ::coder::array<creal_T, 1U> &y)
{
  array<creal_T, 1U> b_fv;
  array<creal_T, 1U> fv;
  array<creal_T, 1U> wwc;
  double b_re_tmp;
  double nt_im;
  double nt_re;
  double re_tmp;
  int i;
  int k;
  int minNrowsNx;
  int nInt2;
  int nInt2m1;
  int rt;
  nInt2m1 = (nfft + nfft) - 1;
  wwc.set_size(nInt2m1);
  rt = 0;
  wwc[nfft - 1].re = 1.0;
  wwc[nfft - 1].im = 0.0;
  nInt2 = nfft << 1;
  for (k = 0; k <= nfft - 2; k++) {
    minNrowsNx = ((k + 1) << 1) - 1;
    if (nInt2 - rt <= minNrowsNx) {
      rt += minNrowsNx - nInt2;
    } else {
      rt += minNrowsNx;
    }
    nt_im = -3.1415926535897931 * static_cast<double>(rt) /
            static_cast<double>(nfft);
    if (nt_im == 0.0) {
      nt_re = 1.0;
      nt_im = 0.0;
    } else {
      nt_re = std::cos(nt_im);
      nt_im = std::sin(nt_im);
    }
    i = (nfft - k) - 2;
    wwc[i].re = nt_re;
    wwc[i].im = -nt_im;
  }
  i = nInt2m1 - 1;
  for (k = i; k >= nfft; k--) {
    wwc[k] = wwc[(nInt2m1 - k) - 1];
  }
  fv.set_size(nfft);
  if (nfft > x.size(0)) {
    fv.set_size(nfft);
    for (i = 0; i < nfft; i++) {
      fv[i].re = 0.0;
      fv[i].im = 0.0;
    }
  }
  y.set_size(fv.size(0));
  minNrowsNx = fv.size(0);
  for (i = 0; i < minNrowsNx; i++) {
    y[i] = fv[i];
  }
  minNrowsNx = x.size(0);
  if (nfft <= minNrowsNx) {
    minNrowsNx = nfft;
  }
  for (k = 0; k < minNrowsNx; k++) {
    nInt2m1 = (nfft + k) - 1;
    nt_re = wwc[nInt2m1].re;
    nt_im = wwc[nInt2m1].im;
    re_tmp = x[k].im;
    b_re_tmp = x[k].re;
    y[k].re = nt_re * b_re_tmp + nt_im * re_tmp;
    y[k].im = nt_re * re_tmp - nt_im * b_re_tmp;
  }
  i = minNrowsNx + 1;
  for (k = i; k <= nfft; k++) {
    y[k - 1].re = 0.0;
    y[k - 1].im = 0.0;
  }
  FFTImplementationCallback::r2br_r2dit_trig(y, n2blue, costab, sintab, fv);
  FFTImplementationCallback::r2br_r2dit_trig(wwc, n2blue, costab, sintab, b_fv);
  b_fv.set_size(fv.size(0));
  minNrowsNx = fv.size(0);
  for (i = 0; i < minNrowsNx; i++) {
    nt_re = fv[i].re;
    nt_im = b_fv[i].im;
    re_tmp = fv[i].im;
    b_re_tmp = b_fv[i].re;
    b_fv[i].re = nt_re * b_re_tmp - re_tmp * nt_im;
    b_fv[i].im = nt_re * nt_im + re_tmp * b_re_tmp;
  }
  FFTImplementationCallback::b_r2br_r2dit_trig(b_fv, n2blue, costab, sintabinv,
                                               fv);
  i = wwc.size(0);
  for (k = nfft; k <= i; k++) {
    re_tmp = wwc[k - 1].re;
    b_re_tmp = fv[k - 1].im;
    nt_re = wwc[k - 1].im;
    nt_im = fv[k - 1].re;
    minNrowsNx = k - nfft;
    y[minNrowsNx].re = re_tmp * nt_im + nt_re * b_re_tmp;
    y[minNrowsNx].im = re_tmp * b_re_tmp - nt_re * nt_im;
  }
}

void FFTImplementationCallback::get_algo_sizes(int nfft, boolean_T useRadix2,
                                               int *n2blue, int *nRows)
{
  *n2blue = 1;
  if (useRadix2) {
    *nRows = nfft;
  } else {
    if (nfft > 0) {
      int n;
      int pmax;
      n = (nfft + nfft) - 1;
      pmax = 31;
      if (n <= 1) {
        pmax = 0;
      } else {
        int pmin;
        boolean_T exitg1;
        pmin = 0;
        exitg1 = false;
        while ((!exitg1) && (pmax - pmin > 1)) {
          int k;
          int pow2p;
          k = (pmin + pmax) >> 1;
          pow2p = 1 << k;
          if (pow2p == n) {
            pmax = k;
            exitg1 = true;
          } else if (pow2p > n) {
            pmax = k;
          } else {
            pmin = k;
          }
        }
      }
      *n2blue = 1 << pmax;
    }
    *nRows = *n2blue;
  }
}

void FFTImplementationCallback::r2br_r2dit_trig(
    const ::coder::array<creal_T, 1U> &x, int n1_unsigned,
    const ::coder::array<double, 2U> &costab,
    const ::coder::array<double, 2U> &sintab, ::coder::array<creal_T, 1U> &y)
{
  double temp_im;
  double temp_re;
  double temp_re_tmp;
  double twid_re;
  int i;
  int iDelta2;
  int iheight;
  int iy;
  int ju;
  int k;
  int nRowsD2;
  y.set_size(n1_unsigned);
  if (n1_unsigned > x.size(0)) {
    y.set_size(n1_unsigned);
    for (iy = 0; iy < n1_unsigned; iy++) {
      y[iy].re = 0.0;
      y[iy].im = 0.0;
    }
  }
  iDelta2 = x.size(0);
  if (iDelta2 > n1_unsigned) {
    iDelta2 = n1_unsigned;
  }
  iheight = n1_unsigned - 2;
  nRowsD2 = n1_unsigned / 2;
  k = nRowsD2 / 2;
  iy = 0;
  ju = 0;
  for (i = 0; i <= iDelta2 - 2; i++) {
    boolean_T tst;
    y[iy] = x[i];
    iy = n1_unsigned;
    tst = true;
    while (tst) {
      iy >>= 1;
      ju ^= iy;
      tst = ((ju & iy) == 0);
    }
    iy = ju;
  }
  y[iy] = x[iDelta2 - 1];
  if (n1_unsigned > 1) {
    for (i = 0; i <= iheight; i += 2) {
      temp_re_tmp = y[i + 1].re;
      temp_im = y[i + 1].im;
      temp_re = y[i].re;
      twid_re = y[i].im;
      y[i + 1].re = temp_re - temp_re_tmp;
      y[i + 1].im = twid_re - temp_im;
      y[i].re = temp_re + temp_re_tmp;
      y[i].im = twid_re + temp_im;
    }
  }
  iy = 2;
  iDelta2 = 4;
  iheight = ((k - 1) << 2) + 1;
  while (k > 0) {
    int b_temp_re_tmp;
    for (i = 0; i < iheight; i += iDelta2) {
      b_temp_re_tmp = i + iy;
      temp_re = y[b_temp_re_tmp].re;
      temp_im = y[b_temp_re_tmp].im;
      y[b_temp_re_tmp].re = y[i].re - temp_re;
      y[b_temp_re_tmp].im = y[i].im - temp_im;
      y[i].re = y[i].re + temp_re;
      y[i].im = y[i].im + temp_im;
    }
    ju = 1;
    for (int j{k}; j < nRowsD2; j += k) {
      double twid_im;
      int ihi;
      twid_re = costab[j];
      twid_im = sintab[j];
      i = ju;
      ihi = ju + iheight;
      while (i < ihi) {
        b_temp_re_tmp = i + iy;
        temp_re_tmp = y[b_temp_re_tmp].im;
        temp_im = y[b_temp_re_tmp].re;
        temp_re = twid_re * temp_im - twid_im * temp_re_tmp;
        temp_im = twid_re * temp_re_tmp + twid_im * temp_im;
        y[b_temp_re_tmp].re = y[i].re - temp_re;
        y[b_temp_re_tmp].im = y[i].im - temp_im;
        y[i].re = y[i].re + temp_re;
        y[i].im = y[i].im + temp_im;
        i += iDelta2;
      }
      ju++;
    }
    k /= 2;
    iy = iDelta2;
    iDelta2 += iDelta2;
    iheight -= iy;
  }
}

} // namespace internal
} // namespace coder

// End of code generation (FFTImplementationCallback.cpp)
