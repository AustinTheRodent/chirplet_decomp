import multiprocessing
import numpy as np

CHIRP_LEN     = 512
SAMPS_PER_CLK = 8
RESCALE16     = 32678

class chirplet_param_t:
  def __init__(self):
    self.t_step                   = 0.0
    self.tau                      = 0.0
    self.alpha1                   = 0.0
    self.f_c                      = 0.0
    self.alpha2                   = 0.0
    self.phi                      = 0.0
    self.beta                     = 0.0


def signal_creation(chirp_params):

  dt        = chirp_params.t_step
  beta      = chirp_params.beta
  tau       = chirp_params.tau
  f_c       = chirp_params.f_c
  alpha1    = chirp_params.alpha1
  alpha2    = chirp_params.alpha2
  phi       = chirp_params.phi
  time_step = chirp_params.t_step

  t = dt * np.arange(0, CHIRP_LEN, 1, dtype=float)
  chirp_sig_f = beta*np.exp(-1.0*alpha1*((t-tau)**2)) * np.exp(1j*(2.0*np.pi*f_c*(t-tau)+phi+alpha2*((t-tau)**2)))
  chirp_sig_f = np.round(chirp_sig_f * float(RESCALE16))

  return chirp_sig_f

def chirplet_transform_energy(estimate_params, ref):

  dt      = estimate_params.t_step
  beta_   = estimate_params.beta
  alpha1_ = estimate_params.alpha1
  tau_    = estimate_params.tau
  f_c_    = estimate_params.f_c
  phi_    = estimate_params.phi
  alpha2_ = estimate_params.alpha2

  t = dt * np.arange(0, CHIRP_LEN, 1, dtype=float)
  chirp_sig_f = beta_*np.exp(-1.0*alpha1_*((t-tau_)**2)) * np.exp(1j*(2.0*np.pi*f_c_*(t-tau_)+phi_+alpha2_*((t-tau_)**2)))
  ref_f = ref/RESCALE16

  #print(alpha1_)
  #print(np.exp(-1.0*alpha1_*((t-tau_)**2)))

  conj_sum = np.sum(chirp_sig_f * np.conj(ref_f))
  conj_sum_energy = int(np.abs(conj_sum)**2 * float(1<<16))
  return conj_sum_energy
