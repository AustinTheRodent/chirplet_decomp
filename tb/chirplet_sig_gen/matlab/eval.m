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
tau=0.00005
alpha1=10000000000
f_c=1000000
alpha2=10000000000
phi=0.75
beta=0.5

len = length(data);
%len = 100000;

t = ((0:len-1)*time_step)';
sw_data = beta*exp(-alpha1*(t-tau).^2 + 1i*2*pi*(phi + f_c*(t-tau) + alpha2*(t-tau).^2));
hw_data = final_mult_real + 1j*final_mult_imag;

abs((length(sw_data)*sum(sw_data.*hw_data) - sum(sw_data)*sum(hw_data))/...
sqrt((length(sw_data)*sum(sw_data.^2) - sum(hw_data)^2)*(length(hw_data)*sum(hw_data.^2) - sum(hw_data)^2)))




figure(1); hold on;
plot(real(hw_data))
plot(real(sw_data))


err = zeros(length(data), 1);
err2 = zeros(length(data), 1);
for i=1:length(err)
  err(i) = 100*(real(sw_data(i))-data(i))/real(sw_data(i));
  if err(i) > 10
    err(i) = 10;
  elseif err(i) < -10
    err(i) = -10;
  end
  diff(i) = (real(sw_data(i))-data(i));
end

figure(2); hold on;
%plot(err, 'o')
plot(diff)

