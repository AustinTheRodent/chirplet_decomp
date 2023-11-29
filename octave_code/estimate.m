function estimate_sig = estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,sig)
tau_
f_c_
alpha2_ = func_alpha2(beta_,f_c_,alpha1_,tau_,phi_,t,sig)
alpha1_ = func_alpha1(beta_,f_c_,tau_,alpha2_,phi_,t,sig)
%phi_ = func_phi(beta_,f_c_,alpha1_,alpha2_,tau_,t,sig)

x_hat = signal_creation(1,tau_,f_c_,alpha1_,alpha2_,0,t);
x_conj_sum = sum(sig.*conj(x_hat));

%{
figure();hold on;
plot(real(sig));
plot(real(x_hat));

figure();hold on;
plot(real(sig.*(x_hat)));
%}

phi_ = angle(x_conj_sum)

beta_ = abs(x_conj_sum)/sum(abs(x_hat).^2)
% below line is equivilant (easier to compute in C):
%beta_ = sqrt((real(x_conj_sum)^2 + imag(x_conj_sum)^2)/sum(real(x_hat).^2 + imag(x_hat).^2)^2)

%[beta_, index] = max(abs(sig));%*0.25
%beta_ = mean(abs(sig(index-20:index+20)));
%beta_ = mean(abs(sig(index-100:index+100)));

%alpha2_ = 0;

estimate_sig = signal_creation(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t);
end

