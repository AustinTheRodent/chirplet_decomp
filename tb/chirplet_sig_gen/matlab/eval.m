clear all;

fid = fopen("../hw_output/output.bin", "rb");
data = fread(fid, "float");
fclose(fid);

time_step=0.00000001
tau=0.0005
alpha1=20000000

%data = zeros(100000, 1);
sw_data = zeros(length(data), 1);
err = zeros(length(data), 1);
for count=0:length(data)-1
  sw_data(count+1) = exp(-alpha1*(-tau + (count)*time_step)^2);
  time = time + time_step;
  err(count+1) = 100*(sw_data(count+1)-data(count+1))/sw_data(count+1);
  if err(count+1) > 100
    err(count+1) = 100;
  elseif err(count+1) < -100
    err(count+1) = -100;
  end
end

figure(1); hold on;
plot(data);
plot(sw_data);


figure(2);
plot(err)
