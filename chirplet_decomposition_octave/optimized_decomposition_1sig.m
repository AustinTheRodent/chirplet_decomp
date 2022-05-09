pkg load communications

fs =100e6;
t = 0:1/fs:10e-4;
beta1 = 1;
alpha1 = 25e12;
alpha2 = 15e12;
tau =2e-4;
f_c = 5e6;
phi = pi/2;
%chirplet sginal kernel
single_sig= signal_creation(beta1,tau,f_c,alpha1,alpha2,phi,t);
%plot(real(single_sig))
%plot(real(single_sig));
with_noise = awgn(single_sig,10);
fc = 100000;
[b,a] = butter(6,fc/(fs/2));
dataOut = filter(b,a,with_noise);
%plot(real(with_noise));
%hold on 

[peak_value,indx] = max(with_noise);
cutted_sig = zeros(1,100001);
cutted_sig (indx-190:indx+200)= with_noise (indx-190:indx+200);
beta_ = abs(peak_value);
%plot(real(cutted_sig));
[tau_,f_c_]=find_tauandfc(indx,fs,t,beta_,cutted_sig);
alpha1_ = 24e12;
alpha2_ = 14e12;
phi_ = 1;
estimated_sig= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,cutted_sig);

%figure()
%with_noise1 = with_noise-estimated_sig;
%plot((real(with_noise1)))
