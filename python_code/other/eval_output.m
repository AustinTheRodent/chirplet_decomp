clear all;
close all;

fid = fopen("estimate_sig_re.txt", "r");
estimate_re = fscanf(fid, "%f\n");
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
plot(real(reference));
plot(real(estimate_re));
xlim([1 1000]);
grid on;


figure();
plot(real(reference) - estimate_re)





