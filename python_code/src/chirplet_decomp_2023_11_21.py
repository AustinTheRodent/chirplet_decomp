
import chirplet_transform as ct
import numpy as np

MAX_SAMPLES = 8192

fs = float(100e6)
faux_fs = float(1) # 100MHz (make configurable)

C_FMIN = 0e6
C_FMAX = 50e6

C_A1MIN = 1e12
C_A1MAX = 1e15

C_A2MIN = -2e13
C_A2MAX = 2e13

#C_FMIN = 0e6
#C_FMAX = fs/2
#
#C_A1MIN = (fs**2)/10000
#C_A1MAX = (fs**2)/10
#
#C_A2MAX =  (fs**2)*2/1000
#C_A2MIN = -C_A2MAX

#print("C_A1MAX: %f" % C_A1MAX)
#print("C_A1MIN: %f" % C_A1MIN)
#print("C_A2MIN: %f" % C_A2MIN)
#
#quit()

def get_samples(fname):

  received_samples = np.array([0.0+1j*0.0 for i in range(MAX_SAMPLES)], dtype=complex)

  is_I = True
  index = 0
  f = open(fname, "r")
  flen = 0
  for line in f:
    if is_I == True:
      received_samples.real[index] = float(line)
      is_I = False
    else:
      received_samples.imag[index] = float(line)
      is_I = True
      index += 1
    flen += 1
  f.close
  return [received_samples, flen]

def get_max_energy(input_array):
  return_energy = 0;
  return_index = 0;

  return_energy = np.max(np.abs(input_array))
  return_index = np.argmax(np.abs(input_array))
  try:
    if len(return_index) > 1:
      return_index = return_index[0]
  except:
    pass

  return [return_energy, return_index]

def func_fc(beta_, tau_, alpha1_, alpha2_, phi_, time_step, single_sig):
  max_value = 0.0
  steps = 50
  nestedsteps = 40
  params = ct.chirplet_param_t()

  fmin = float(C_FMIN)
  fmax = float(C_FMAX)

  params.t_step = time_step
  params.beta   = beta_
  params.alpha1 = alpha1_
  params.tau    = tau_
  #params.f_c.f;
  params.phi    = phi_
  params.alpha2 = alpha2_

  indx = 0
  oldindx = 0
  for i in range(steps+1):
    params.f_c = fmin + float(i)*((fmax-fmin)/(float(steps)))
    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1;
      indx = i*nestedsteps;

  oldindx = indx;
  if oldindx < nestedsteps:
    oldindx = nestedsteps;
    indx = nestedsteps;

  for i in np.arange(oldindx-nestedsteps, oldindx+nestedsteps+1, 1, dtype=int):
    params.f_c = fmin + float(i)*((fmax-fmin)/float(nestedsteps*steps))
    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1
      indx = i

  f_c_ = fmin + float(indx)*((fmax-fmin)/float(nestedsteps*steps))
  return f_c_

def func_tau(beta_, f_c_, alpha1_, alpha2_, phi_, time_step, single_sig):
#  int i;
  max_value = 0
  steps = 32 # todo: relate to chirplet length
  nestedsteps = 32 # todo: relate to chirplet length
#  float tau_;
  tau_max = time_step*(float(ct.CHIRP_LEN)-1.0);
#  uint32_t CT1;
  params = ct.chirplet_param_t()

  params.t_step = time_step
  params.beta   = beta_
  params.alpha1 = alpha1_
  #params.tau;
  params.f_c    = f_c_
  params.phi    = phi_
  params.alpha2 = alpha2_

  indx = 0
  oldindx = 0
#  for(i = 0 ; i <= steps ; i++)
  for i in range(steps+1):
    params.tau = float(i)*((tau_max)/float(steps))
    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1
      indx = i*nestedsteps

  oldindx = indx
  if oldindx < nestedsteps:
    oldindx = nestedsteps
    indx = nestedsteps

#  for(i = oldindx-nestedsteps ; i <= oldindx+nestedsteps ; i++)
  for i in np.arange(oldindx-nestedsteps, oldindx+nestedsteps+1, 1, dtype=int):
    params.tau = float(i)*((tau_max)/float(nestedsteps*steps))
    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1
      indx = i

  tau_ = float(indx)*((tau_max)/float(nestedsteps*steps))
  return tau_

def find_tauandfc(approx_tau_index, time_step, beta_, cut_sig):
  tau_ = approx_tau_index*time_step;
  #alpha1_ = 25e12 # todo: number relative to sample rate
  alpha1_ = C_A1MIN * 2.5
  alpha2_ = 0.0 # no frequency sweep
  phi_ = 1 # todo: change to 0?

  f_c_ = 0.0
  tau_ = 0.0

  for i in range(5): # found diminishing returs after 5 iterations
    f_c_ = func_fc(beta_, tau_, alpha1_, alpha2_, phi_, time_step, cut_sig)
    tau_ = func_tau(beta_, f_c_, alpha1_, alpha2_, phi_, time_step, cut_sig)

  return [tau_, f_c_]

def func_alpha2(beta_, f_c_, alpha1_, tau_, phi_, time_step, single_sig):
  max_value = 0.0
  steps = 50
  nestedsteps = 40
  params = ct.chirplet_param_t()

  a2min = float(C_A2MIN)
  a2max = float(C_A2MAX)

  params.t_step = time_step
  params.beta   = beta_
  params.alpha1 = alpha1_
  params.tau    = tau_
  params.f_c    = f_c_
  params.phi    = phi_
  #params.alpha2 = alpha2_

  indx = 0
  oldindx = 0
  for i in range(steps+1):
    params.alpha2 = a2min + float(i)*((a2max-a2min)/(float(steps)))
    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1;
      indx = i*nestedsteps;

  oldindx = indx;
  if oldindx < nestedsteps:
    oldindx = nestedsteps;
    indx = nestedsteps;

  for i in np.arange(oldindx-nestedsteps, oldindx+nestedsteps+1, 1, dtype=int):
    params.alpha2 = a2min + float(i)*((a2max-a2min)/float(nestedsteps*steps))
    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1
      indx = i

  alpha2_ = a2min + float(indx)*((a2max-a2min)/float(nestedsteps*steps))
  return alpha2_

def func_alpha1(f_c_, tau_, alpha2_, phi_, time_step, single_sig):
  max_value = 0.0
  steps = 50
  nestedsteps = 40
  params = ct.chirplet_param_t()

  a1min = float(C_A1MIN)
  a1max = float(C_A1MAX)
  
  params.t_step = time_step
  #params.beta   = beta_
  #params.alpha1 = alpha1_
  params.tau    = tau_
  params.f_c    = f_c_
  params.phi    = phi_
  params.alpha2 = alpha2_

  indx = 0
  oldindx = 0
  for i in range(steps+1):
    params.alpha1 = a1min + float(i)*((a1max-a1min)/float(steps))
    params.beta = 4e-4 * (2.0*np.pi*params.alpha1)**0.25

    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1;
      indx = i*nestedsteps;

  oldindx = indx;
  if oldindx < nestedsteps:
    oldindx = nestedsteps;
    indx = nestedsteps;

  for i in np.arange(oldindx-nestedsteps, oldindx+nestedsteps+1, 1, dtype=int):
    params.alpha1 = a1min + float(i)*((a1max-a1min)/float(nestedsteps*steps))
    params.beta = 4e-4 * (2.0*np.pi*params.alpha1)**0.25

    CT1 = ct.chirplet_transform_energy(params, single_sig)
    if CT1 > max_value:
      max_value = CT1
      indx = i

  alpha1_ = a1min + float(indx)*((a1max-a1min)/float(nestedsteps*steps))
  return alpha1_

def func_phi_beta(f_c_, alpha1_, alpha2_, tau_, time_step, single_sig):
  estimate_params = ct.chirplet_param_t()

  estimate_params.beta    = 1.0
  estimate_params.f_c     = f_c_
  estimate_params.alpha1  = alpha1_
  estimate_params.alpha2  = alpha2_
  estimate_params.tau     = tau_
  estimate_params.t_step  = time_step

  x_hat = ct.signal_creation(estimate_params)

  single_sig_f = single_sig/float(ct.RESCALE16)
  x_hat_f = x_hat/float(ct.RESCALE16)
  x_conj_sum = np.sum(single_sig_f * np.conj(x_hat_f))

  ss = np.sum(np.abs(x_hat_f)**2)

  if np.imag(x_conj_sum) >= 0 and np.real(x_conj_sum) >= 0:
    phi_ = np.arctan(np.imag(x_conj_sum)/np.real(x_conj_sum))
  elif np.imag(x_conj_sum) >= 0 and np.real(x_conj_sum) < 0:
    phi_ = np.arctan(np.imag(x_conj_sum)/np.real(x_conj_sum)) + np.pi
  elif np.imag(x_conj_sum) < 0 and np.real(x_conj_sum) < 0:
    phi_ = np.arctan(np.imag(x_conj_sum)/np.real(x_conj_sum)) - np.pi
  else:
    phi_ = np.arctan(np.imag(x_conj_sum)/np.real(x_conj_sum))

  beta_ = np.abs(x_conj_sum)/(ss)

  return [phi_, beta_]

def estimate(approx_tau_index, time_step, cut_sig):
  beta_ = 0.5


  [tau_, f_c_] = find_tauandfc(approx_tau_index, time_step, beta_, cut_sig)



  #alpha1_ = 24e10 # todo: set relative to sample rate
  alpha1_ = C_A1MIN/4.166666666666667
  phi_    = 0.0
  
  alpha2_ = func_alpha2(beta_, f_c_, alpha1_, tau_, phi_, time_step, cut_sig)
  alpha1_ = func_alpha1(f_c_, tau_, alpha2_, 0, time_step, cut_sig)
  [phi_, beta_] = func_phi_beta(f_c_, alpha1_, alpha2_, tau_, time_step, cut_sig)

  return_est_params = ct.chirplet_param_t()

  return_est_params.t_step = time_step
  return_est_params.tau    = tau_
  return_est_params.alpha1 = alpha1_
  return_est_params.f_c    = f_c_
  return_est_params.alpha2 = alpha2_
  return_est_params.phi    = phi_
  return_est_params.beta   = beta_

  return return_est_params

def chirplet_decomp():

  #estimate_sig = np.array([0.0+1j*0.0 for i in range(MAX_SAMPLES)], dtype=complex)

  i           = int(0)
  j           = int(0)
  chirp_count = int(0)
  max_index   = int(0)
  max_value   = int(0)
  input_len   = int(0)
  start_index = int(0)

  chirplet_param = ct.chirplet_param_t()

  cut_sig_re        = np.array([0 for i in range(ct.CHIRP_LEN)], dtype=int)
  cut_sig_im        = np.array([0 for i in range(ct.CHIRP_LEN)], dtype=int)
  estimate_chirp_re = np.array([0 for i in range(ct.CHIRP_LEN)], dtype=int)
  estimate_chirp_im = np.array([0 for i in range(ct.CHIRP_LEN)], dtype=int)

  time_step = 1.0/fs

  reference_fname = "../other/reference.txt" # make configurable
  [received_samples, input_len] = get_samples(reference_fname)
  if input_len%2 != 0:
    print("Error, chirplet_decomp.py: Input reference file length is not even")
    quit()

  input_len = input_len/2 # real and imaginary components broken up across individual lines

  use_residual_noise = True # todo: make configurable
  chirp_limit = 10 # todo: make configurable
  beta_lim = 0.005*0

  estimate_signal = np.array([0.0+1j*0.0 for i in range(MAX_SAMPLES)], dtype=complex)

  for chirp_count in range(chirp_limit):
    [max_value, max_index] = get_max_energy(received_samples)

    #the next lines are to make sure our window always is within the bounds of the received signal
    if (max_index - (ct.CHIRP_LEN/2)) < 0:
      start_index = 0
    elif (max_index - (ct.CHIRP_LEN/2)) > input_len:
      start_index = int(input_len - ct.CHIRP_LEN)
    else:
      start_index = int(max_index - (ct.CHIRP_LEN/2))

    cut_sig = received_samples[start_index:start_index+ct.CHIRP_LEN]
    chirplet_param = estimate(max_index - start_index, time_step, cut_sig)
    estimate_chirp = ct.signal_creation(chirplet_param)

    received_samples[start_index:start_index+ct.CHIRP_LEN] -= estimate_chirp
    estimate_signal[start_index:start_index+ct.CHIRP_LEN] += estimate_chirp

    print("chirp_count: %i" % chirp_count)
    print("start_index            : %i"     % (start_index                             ))
    print("chirplet_param.t_step  : %0.16f" % (chirplet_param.t_step * (fs/faux_fs)    ))
    print("chirplet_param.tau     : %0.16f" % (chirplet_param.tau    * (fs/faux_fs)    ))
    print("chirplet_param.alpha1  : %0.16f" % (chirplet_param.alpha1 * (faux_fs/fs)**2 ))
    print("chirplet_param.f_c     : %0.16f" % (chirplet_param.f_c    * (faux_fs/fs)    ))
    print("chirplet_param.alpha2  : %0.16f" % (chirplet_param.alpha2 * (faux_fs/fs)**2 ))
    print("chirplet_param.phi     : %0.16f" % (chirplet_param.phi                      ))
    print("chirplet_param.beta    : %0.16f" % (chirplet_param.beta                     ))

    if (chirplet_param.beta < beta_lim) and (use_residual_noise == True):
      break

  print("chirp_count: %i" % chirp_count)

  f_est = open("../other/estimate_sig_re.txt", "w")
  for i in range(len(estimate_signal)):
    f_est.write("%f\n" % np.real(estimate_signal[i]))
  f_est.close()

  f_est = open("../other/estimate_sig_im.txt", "w")
  for i in range(len(estimate_signal)):
    f_est.write("%f\n" % np.imag(estimate_signal[i]))
  f_est.close()

if __name__ == "__main__":
  chirplet_decomp()

