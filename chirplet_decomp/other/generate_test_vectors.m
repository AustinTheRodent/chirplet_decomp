clear all;
pkg load communications;

fid = fopen("ForAustin2_singel_channel.csv", "r");
data = fscanf(fid, "%f\n");
fclose(fid);

data = data*2;
data = resample(data, 1, 8);

b = remez(128, [0 0.45 0.5 1], [1 1 0 0]);

data_shift = data.*exp(-1i*pi*0.5*(0:length(data)-1)');
data_shift = filter(b, 1, data_shift);
data_shift = data_shift.*exp(1i*pi*0.5*(0:length(data_shift)-1)');

w = -1:2/length(data):1-2/length(data);

figure();hold on;
plot(w, 20*log10(abs(fftshift(fft(data_shift)))));
plot(w, 20*log10(abs(fftshift(fft(data)))));

%figure();hold on;
%plot(data);
%plot(real(data_shift(64:end)));

data_re = real(data_shift);
data_im = imag(data_shift);

data_re = round(data_re);
data_im = round(data_im);

%figure();
%plot(data_im);

data_ileved = zeros(2*length(data_re), 1);
for i=0:length(data_re)-1
  data_ileved(i*2+1) = data_re(i+1);
  data_ileved(i*2+2) = data_im(i+1);
end

reference_fname = "reference.bin";
fid = fopen(reference_fname, "w");

fwrite(fid, length(data_ileved)/2, "int16");
fwrite(fid, data_ileved, "int16");
fclose(fid);




return;
reference_fname = "reference.bin";
parameters_fname = "chirplet_parameters.bin";
%estimate_fname = "estimate_chirp.txt";


N_samps = 512*10;

fs = 100e6;
time_step=1/fs

beta = 0.665;
alpha1 = 28e11;
alpha2 = 14e11;
tau = 2e-5;
f_c = 5e6;
phi = pi/4;

len = N_samps;
%len = 100000;

t = ((0:len-1)*time_step)';

ref_samps = beta*exp(-alpha1*(t-tau).^2 + 1i*(phi + 2*pi*f_c*(t-tau) + alpha2*(t-tau).^2));
%ref_samps = awgn(ref_samps, 10, "measured");

ref_samps_interleaved = zeros(N_samps*2, 1);
for i=0:N_samps-1
  ref_samps_interleaved(i*2+1) = real(ref_samps(i+1));
  ref_samps_interleaved(i*2+2) = imag(ref_samps(i+1));
end

fid = fopen(reference_fname, "w");
fwrite(fid, N_samps, "int16");
fwrite(fid, round(ref_samps_interleaved*2^15), "int16");
%fprintf(fid, "%i\n", floor(ref_samps_interleaved*2^15));
fclose(fid);

fid = fopen(parameters_fname, "w");

for f_c=4500000:10000:5500000
  fwrite(fid, time_step, "float");
  fwrite(fid, tau, "float");
  fwrite(fid, alpha1, "float");
  fwrite(fid, f_c, "float");
  fwrite(fid, alpha2, "float");
  fwrite(fid, phi, "float");
  fwrite(fid, beta, "float");
end
fclose(fid);

figure();
plot(real(ref_samps));

return;

fid = fopen("output_estimate_re.txt", "r");
output_estimate_re = fscanf(fid, "%i\n");
fclose(fid);

fid = fopen("output_estimate_im.txt", "r");
output_estimate_im = fscanf(fid, "%i\n");
fclose(fid);

output_estimate = output_estimate_re + 1i*output_estimate_im;

ref_samps = floor(ref_samps*2^15);

sum(floor(ref_samps).*conj(output_estimate))/2^16

figure(); hold on;
plot(real(ref_samps));
plot(real(output_estimate));

%fid = fopen(estimate_fname, 'w');
%fprintf(fid, "%i\n", est_samps_interleaved);
%fclose(fid);

