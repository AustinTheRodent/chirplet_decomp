clear all;

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

fid = fopen("../hw_output/final_mult_imag.bin", "rb");
final_mult_imag = fread(fid, "float");
fclose(fid);

fid = fopen("../hw_output/final_mult_real.bin", "rb");
final_mult_real = fread(fid, "float");
fclose(fid);

data = final_mult_real;

time_step=0.00000001
tau=0.00005
alpha1=1000000000
f_c=1000000
alpha2=10000000000
phi=0
beta=0.5

len = length(data);
%len = 100000;

t = ((0:len-1)*time_step)';
%sw_data = imag(beta*exp(-alpha1*(t-tau).^2 + 1i*2*pi*(alpha2*((t-tau).^2))));
sw_data = real(beta*exp(-alpha1*(t-tau).^2 + 1i*2*pi*(phi + f_c*(t-tau) + alpha2*(t-tau).^2)));
figure(1); hold on;
plot(sw_data)

plot(data)


err = zeros(length(data), 1);
err2 = zeros(length(data), 1);
for i=1:length(err)
  err(i) = (sw_data(i)-data(i))/sw_data(i);
  diff(i) = (sw_data(i)-data(i));
end

%figure(2); hold on;
plot(err, 'o')
plot(diff)

