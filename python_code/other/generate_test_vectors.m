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

data_shift = data_shift(1:8192);

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

fid = fopen("reference_re.bin", "w");
fwrite(fid, data_re, "int16");
fclose(fid);

fid = fopen("reference_im.bin", "w");
fwrite(fid, data_im, "int16");
fclose(fid);

return;



