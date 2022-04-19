function estimate_sig = estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,sig)
% f_c_ = func_fc(beta_,tau_,alpha1_,alpha2_,phi_,t,sig);
% tau_ = func_tau(beta_,f_c_,alpha1_,alpha2_,phi_,t,sig);
alpha2_ = func_alpha2(beta_,f_c_,alpha1_,tau_,phi_,t,sig)
alpha1_ = func_alpha1(beta_,f_c_,tau_,alpha2_,phi_,t,sig)
phi_ = func_phi(beta_,f_c_,alpha1_,alpha2_,tau_,t,sig)
estimate_sig = signal_creation(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t);
end
