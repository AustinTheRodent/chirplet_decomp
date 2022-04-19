pkg load communications

fs =100e8;
t = 0:1/fs:10e-6;
beta1 = 1;
alpha1 = 25e12;
alpha2 = 15e12;
tau =2e-6;
f_c = 5e6;
phi = pi/2;
%chirplet sginal kernel
sig1= signal_creation(beta1,tau,f_c,alpha1,alpha2,phi,t);
plot(real(sig1))
beta2 = -0.7;
alpha1 = 25e12;
alpha2 = 15e12;
tau = 2.5e-6;
f_c = 5.2e6;
phi = pi/2;
sig2= signal_creation(beta2,tau,f_c,alpha1,alpha2,phi,t);
plot(real(sig2))
beta3= 1.5
alpha1 = 25e12;
alpha2 = 15e12;
tau = 2.8e-6;
f_c = 5.1e6;
phi = pi/2*0.8;
sig3= signal_creation(beta3,tau,f_c,alpha1,alpha2,phi,t);
single_sig = sig1+sig2+sig3;
plot(real(single_sig));
with_noise = awgn(single_sig,30);
fc = 10000000;
[b,a] = butter(6,fc/(fs/2));
dataOut = filter(b,a,with_noise);
plot(real(with_noise));
hold on 
%plot(real(single_sig))
%%
[peak_value,indx] = max(with_noise);
cutted_sig = zeros(1,100001);
cutted_sig (indx-1900:indx+2000)= with_noise (indx-1900:indx+2000);
beta_ = abs(peak_value);
plot(real(cutted_sig));
[tau_,f_c_]=find_tauandfc(indx,fs,t,beta_,cutted_sig);
alpha1_ = 24e12;
alpha2_ = 14e12;
phi_ = 1;
estimated_sig= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,cutted_sig);
%%
figure()
with_noise1 = with_noise-estimated_sig;
plot((real(with_noise1)))
%%
[peak_value,indx] = max(with_noise1);
cutted_sig = zeros(1,100001);
cutted_sig (indx-1900:indx+2100)= with_noise1 (indx-1900:indx+2100);
beta_ = abs(peak_value);
plot(real(cutted_sig));
[tau_,f_c_]=find_tauandfc(indx,fs,t,beta_,cutted_sig);
alpha1_ = 24e12;
alpha2_ = 14e12;
phi_ = 1;

estimated_sig1= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,cutted_sig);
%%
with_noise2 = with_noise1-estimated_sig1;
plot((real(with_noise2)))

%%
[peak_value,indx] = max(with_noise2);
cutted_sig = zeros(1,100001);
cutted_sig (indx-1900:indx+2100)= with_noise2 (indx-1900:indx+2100);
beta_ = abs(peak_value);
plot(real(cutted_sig));
[tau_,f_c_]=find_tauandfc(indx,fs,t,beta_,cutted_sig);
alpha1_ = 24e12;
alpha2_ = 14e12;
phi_ = 1;
estimated_sig2= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,cutted_sig);
%%
with_noise3 = with_noise2+estimated_sig2;
plot((real(with_noise3)))
%%
[peak_value,indx] = max(with_noise3);
cutted_sig = zeros(1,100001);
cutted_sig (indx-1900:indx+2100)= with_noise3 (indx-1900:indx+2100);
beta_ = abs(peak_value);
plot(real(cutted_sig));
[tau_,f_c_]=find_tauandfc(indx,fs,t,beta_,cutted_sig);
alpha1_ = 24e12;
alpha2_ = 14e12;
phi_ = 1;
estimated_sig3= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,cutted_sig);
%%
with_noise4 = with_noise3+estimated_sig3;
plot((real(with_noise4)))
%%
[tau_,f_c_]=find_tauandfc(indx,fs,t,beta_,cutted_sig);
alpha1_ = 24e12;
alpha2_ = 14e12;
phi_ = 1;

% estimated_sig1= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,sig1);
% estimated_sig2= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,sig(2,:));
% estimated_sig3= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,sig(3,:));
% estimated_sig4= estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,sig(4,:));
