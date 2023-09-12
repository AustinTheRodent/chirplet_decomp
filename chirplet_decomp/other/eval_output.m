clear all;
close all;

fid = fopen("estimate_output_re.bin", "r");
estimate_re = fread(fid, "int16");
fclose(fid);

fid = fopen("residual_re.bin", "r");
residual_re = fread(fid, "int16");
fclose(fid);

fid = fopen("cut_sig_re.bin", "r");
cut_sig_re = fread(fid, "int16");
fclose(fid);

fid = fopen("current_chirp_re.bin", "r");
current_chirp_re = fread(fid, "int16");
fclose(fid);

fid = fopen("reference.bin", "r");
data = fread(fid, "int16");
data = data(2:end);
fclose(fid);

reference = zeros(length(data)/2, 1);
for i=0:length(reference)-1
  reference(i+1) = data(i*2+1) + 1i*data(i*2+2);
end

figure();hold on;
plot(estimate_re);
plot(real(reference));
xlim([1 1000]);
grid on;

figure();
plot(real(reference) - estimate_re)

figure();hold on;
plot(cut_sig_re);
plot(current_chirp_re);
xlim([1 1000]);
grid on;





