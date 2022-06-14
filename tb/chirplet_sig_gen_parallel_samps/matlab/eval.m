clear all;

%{
fid = fopen("../hw_output/alpha2_times_gauss_imag.bin", "rb");
alpha2_times_gauss_imag = fread(fid, "float");
fclose(fid);

fid = fopen("../hw_output/alpha2_times_gauss_real.bin", "rb");
alpha2_times_gauss_real = fread(fid, "float");
fclose(fid);

fid = fopen("../hw_output/fc_times_phi_imag.bin", "rb");
fc_times_phi_imag = fread(fid, "float");
fclose(fid);

fid = fopen("../hw_output/fc_times_phi_real.bin", "rb");
fc_times_phi_real = fread(fid, "float");
fclose(fid);
%}

fid = fopen("../hw_output/final_mult_imag.bin", "rb");
final_mult_imag = fread(fid, "float");
fclose(fid);

fid = fopen("../hw_output/final_mult_real.bin", "rb");
final_mult_real = fread(fid, "float");
fclose(fid);

data = final_mult_real;

time_step=0.00000001
tau=0.0000595
alpha1=10000000000
f_c=500000
alpha2=10000000000
phi=0.75
beta=0.25

len = length(data);
%len = 100000;

t = ((0:len-1)*time_step)';
sw_data = beta*exp(-alpha1*(t-tau).^2 + 1i*2*pi*(phi + f_c*(t-tau) + alpha2*(t-tau).^2));
hw_data = final_mult_real + 1j*final_mult_imag;

sw_data_exact = ...
  beta*exp(-alpha1*(t-tau).^2 + 1i*2*pi*(...
  round(phi*2^16)/2^16 + ...
  round(f_c*(t-tau)*2^16)/2^16 + ...
  round(alpha2*((t-tau).^2)*2^16)/2^16));

%hw_data = final_mult_old_real + 1j*final_mult_old_imag;
%hw_data = sw_data_exact;

sw_sig_energy = abs(sum(sw_data.*conj(sw_data)));
hw_sig_energy = abs(sum(hw_data.*conj(hw_data)));
energy_diff = abs(sw_sig_energy - hw_sig_energy);
snr_db = 10*log10(sw_sig_energy/energy_diff)

figure(1); hold on;
plot(t, real(hw_data))
plot(t, real(sw_data))

err = zeros(length(hw_data), 1);
err2 = zeros(length(hw_data), 1);
for i=1:length(err)
  err(i) = 100*(real(sw_data(i))-real(hw_data(i)))/real(sw_data(i));
  if err(i) > 10
    err(i) = 10;
  elseif err(i) < -10
    err(i) = -10;
  end
  diff(i) = (real(sw_data(i))-real(hw_data(i)));
end

figure(2); hold on;
%plot(err, 'o')
plot(diff)

