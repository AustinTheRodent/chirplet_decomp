pkg load signal;

fin = fopen("hw_out.txt", "r");
din1 = fscanf(fin, "%f\n");
fclose(fin);

fin = fopen("sw_out.txt", "r");
din2 = fscanf(fin, "%f\n");
fclose(fin);

figure(1); hold on;
plot(din1)
plot(din2)

%figure(2);
%omega = -pi:2*pi/length(din):pi-2*pi/length(din);
%plot(omega/pi, 20*log10(abs(fftshift(fft(din)))))

return;
[b, a] = cheby1(4, 1, 0.1);
b'
a'
x = zeros(4096, 1);
x(1) = 1;
y = filter(b, a, x);
omega = -pi:2*pi/length(y):pi-2*pi/length(y);

figure(3);
plot(y)

figure(4);
plot(omega/pi, 20*log10(abs(fftshift(fft(y)))))
