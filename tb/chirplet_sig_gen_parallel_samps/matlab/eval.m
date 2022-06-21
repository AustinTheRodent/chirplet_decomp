clear all;

fid = fopen("../hw_output/final_complex.bin", "rb");
final_interleaved = fread(fid, "int16");
fclose(fid);

final_complex = zeros(length(final_interleaved)/2, 1);
for i=0:length(final_complex)-1
  final_complex(i+1) = final_interleaved(i*2+2) + 1j*final_interleaved(i*2+1);
end

hw_data = final_complex/2^15;

time_step=0.00000001
tau=0.0000595
alpha1=10000000000
f_c=500000
alpha2=10000000000
phi=0.75
beta=0.25

len = length(hw_data);
%len = 100000;

t = ((0:len-1)*time_step)';
sw_data = beta*exp(-alpha1*(t-tau).^2 + 1i*2*pi*(phi + f_c*(t-tau) + alpha2*(t-tau).^2));

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
plot(t, imag(hw_data))
plot(t, imag(sw_data))

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

