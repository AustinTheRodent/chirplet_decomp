function [tau_,f_c_,a,b] = find_tauandfc(indx,fs,t,beta_,cutted_sig)

tau_ = indx/fs
N = length(cutted_sig);
xdft = fft(cutted_sig);
xdft = xdft(1:N/2+1);
psdx = (1/(fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:fs/length(cutted_sig):fs/2;
[peakpsd,indx]=max(psdx)
f_c_ = freq(indx)
alpha1_ = 25e12;
alpha2_ = 15e12;
phi_ = 1;

disp " "
for i = 1:5
    f_c_ = func_fc(beta_,tau_,alpha1_,alpha2_,phi_,t,cutted_sig);
    a= f_c_
    tau_ = func_tau(beta_,f_c_,alpha1_,alpha2_,phi_,t,cutted_sig);
    b= tau_
end
disp " "
