//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// main.cpp
//
// Code generation for function 'main'
//

/*************************************************************************/
/* This automatically generated example C++ main file shows how to call  */
/* entry-point functions that MATLAB Coder generated. You must customize */
/* this file for your application. Do not modify this file directly.     */
/* Instead, make a copy of this file, modify it, and integrate it into   */
/* your development environment.                                         */
/*                                                                       */
/* This file initializes entry-point function arguments to a default     */
/* size and value before calling the entry-point functions. It does      */
/* not store or use any values returned from the entry-point functions.  */
/* If necessary, it does pre-allocate memory for returned values.        */
/* You can use this file as a starting point for a main function that    */
/* you can deploy in your application.                                   */
/*                                                                       */
/* After you copy the file, and before you deploy it, you must make the  */
/* following changes:                                                    */
/* * For variable-size function arguments, change the example sizes to   */
/* the sizes that your application requires.                             */
/* * Change the example values of function arguments to the values that  */
/* your application requires.                                            */
/* * If the entry-point functions return values, store these values or   */
/* otherwise use them as required by your application.                   */
/*                                                                       */
/*************************************************************************/

// Include files
#include "main.h"
#include "func_alpha1.h"
#include "func_alpha1_terminate.h"
#include "rt_nonfinite.h"
#include "coder_array.h"

// Function Declarations
static coder::array<creal_T, 2U> argInit_1xd100001_creal_T();

static coder::array<double, 2U> argInit_1xd100001_real_T();

static creal_T argInit_creal_T();

static double argInit_real_T();

static void main_func_alpha1();

// Function Definitions
static coder::array<creal_T, 2U> argInit_1xd100001_creal_T()
{
  coder::array<creal_T, 2U> result;
  // Set the size of the array.
  // Change this size to the value that the application requires.
  result.set_size(1, 2);
  // Loop over the array to initialize each element.
  for (int idx0{0}; idx0 < 1; idx0++) {
    for (int idx1{0}; idx1 < result.size(1); idx1++) {
      // Set the value of the array element.
      // Change this value to the value that the application requires.
      result[idx1] = argInit_creal_T();
    }
  }
  return result;
}

static coder::array<double, 2U> argInit_1xd100001_real_T()
{
  coder::array<double, 2U> result;
  // Set the size of the array.
  // Change this size to the value that the application requires.
  result.set_size(1, 2);
  // Loop over the array to initialize each element.
  for (int idx0{0}; idx0 < 1; idx0++) {
    for (int idx1{0}; idx1 < result.size(1); idx1++) {
      // Set the value of the array element.
      // Change this value to the value that the application requires.
      result[idx1] = argInit_real_T();
    }
  }
  return result;
}

static creal_T argInit_creal_T()
{
  creal_T result;
  double re_tmp;
  // Set the value of the complex variable.
  // Change this value to the value that the application requires.
  re_tmp = argInit_real_T();
  result.re = re_tmp;
  result.im = re_tmp;
  return result;
}

static double argInit_real_T()
{
  return 0.0;
}

static void main_func_alpha1()
{
  coder::array<creal_T, 2U> single_sig;
  coder::array<double, 2U> beta__tmp;
  double alpha1_;
  // Initialize function 'func_alpha1' input arguments.
  // Initialize function input argument 'beta_'.
  beta__tmp = argInit_1xd100001_real_T();
  // Initialize function input argument 'f_c_'.
  // Initialize function input argument 'tau_'.
  // Initialize function input argument 'alpha2_'.
  // Initialize function input argument 'phi_'.
  // Initialize function input argument 't'.
  // Initialize function input argument 'single_sig'.
  single_sig = argInit_1xd100001_creal_T();
  // Call the entry-point 'func_alpha1'.
  alpha1_ = func_alpha1(beta__tmp, beta__tmp, beta__tmp, beta__tmp, beta__tmp,
                        beta__tmp, single_sig);
}

int main(int, char **)
{
  // The initialize function is being called automatically from your entry-point
  // function. So, a call to initialize is not included here. Invoke the
  // entry-point functions.
  // You can call entry-point functions multiple times.
  main_func_alpha1();
  // Terminate the application.
  // You do not need to do this more than one time.
  func_alpha1_terminate();
  return 0;
}

// End of code generation (main.cpp)
