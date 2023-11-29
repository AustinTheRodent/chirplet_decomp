%clear all;
close all;
pkg load communications;

reference_fname = "reference.bin";
fid = fopen(reference_fname, "r");
data = fread(fid, "int16");
data = data(2:end);
fclose(fid);

iq = zeros(length(data)/2, 1);
for i=0:length(iq)-1
  iq(i+1) = data(i*2+1) + 1i*data(i*2+2);
end
iq = iq/2^15;
iq = [zeros(1024, 1) ; iq];
iq = conj(iq');

%iq = iq(1:1300);

chirplet_len = 512;

fs = 100e6;
%t = 0:1/fs:10e-5-1/fs;
t = (0:length(iq)-1)/fs;

beta1 = 0.656;
alpha1 = 25e11;
alpha2 = 15e11;
tau = 2e-5;
f_c = 5e6;
phi = pi/2;

%chirplet sginal kernel
single_sig = signal_creation(beta1,tau,f_c,alpha1,alpha2,phi,t);
with_noise = iq;%awgn(single_sig, 300);
%with_noise = awgn(single_sig, 30);

estimate_sig = zeros(1, length(iq));

pulse_energy = [];

for i=1:100
  N_avg = 64;
  [peak_value, max_index] = max(with_noise);

  if (max_index - floor(chirplet_len/2)) < 0
    start_index = 1;
  elseif (max_index + floor(chirplet_len/2)) > length(with_noise)
    start_index = length(with_noise) - chirplet_len;
  else
    start_index = max_index - floor(chirplet_len/2);
  end

  cut_sig = with_noise(start_index:start_index+chirplet_len-1);

  %beta_ = abs(peak_value);
  beta_ = 0.5;

  t = 0:1/fs:chirplet_len/fs-1/fs;
  [tau_,f_c_] = find_tauandfc(max_index-start_index,fs,t,beta_,cut_sig);

  alpha1_ = 24e10;
  alpha2_ = 0*14e12;
  phi_ = 1;
  estimated_sig = estimate(beta_,tau_,f_c_,alpha1_,alpha2_,phi_,t,cut_sig);

  estimate_sig(start_index:start_index+chirplet_len-1) = estimate_sig(start_index:start_index+chirplet_len-1) + estimated_sig;

  pulse_energy = [pulse_energy;sum(abs(with_noise).^2)];
  with_noise(start_index:start_index+chirplet_len-1) = with_noise(start_index:start_index+chirplet_len-1) - estimated_sig;

  %figure();hold on;
  %plot((real(cut_sig)));
  %plot((real(estimated_sig)));

  %todo:
  %make a plot of the energy of the residual signal
  %one with the old beta method and one with the new beta calculation
  %method

  %{
  clf;
  figure(1);
  plot((real(cut_sig)));
  plot(real(with_noise));
  ylim([-0.25 0.25])
  xlim([500 3500])
  pause(0.5);
  %}
end

figure();hold on;
plot(real(iq));
plot(real(estimate_sig));

figure();
plot(real(iq)-real(estimate_sig))

w = -1:2/length(iq):1-2/length(iq);
orig_fft = 20*log10(abs(fftshift(fft((iq)))));
est_fft = 20*log10(abs(fftshift(fft((estimate_sig)))));







