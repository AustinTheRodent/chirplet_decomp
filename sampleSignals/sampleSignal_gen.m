parameters1=   [19.70 1 1.91 4.86 3.91 1.01;
                16.18 1 2.54 6.92 9.09 0.97;
                27.00 1 3.02 4.65 0.73 0.88;
                7.13 1 1.10 4.06 2.69 0.65;
                41.11 1 2.69 3.95 5.67 0.39;
                3.44 1 1.97 7.31 -2.57 0.34;
                65.66 1 3.31 5.73 4.47 0.27;
                36.10 1 1.58 3.66 -2.85 0.26;
                4.22 1 0.86 2.68 -3.10 0.23;
                1.84 1 1.82 5.87 6.63 0.18;
                10.08 1 2.72 8.82 -1.84 0.11;];

parameters2=[16.86 7.53 2.54 6.86 8.88 0.99;
13.13 16.71 1.97 5.04 5.24 0.96;
11.73 16.82 3.00 4.51 0.02 0.78;
4.36 8.44 1.09 3.95 2.07 0.64;
6.28 4.32 1.67 6.89 1.95 0.34;];



parameters3=[ 25    15  2   5   pi/2    1;
              25    15  2.5 7 pi/2    -0.7;
              25    15  2.8 9 0.8*pi/2    1.5;]
 
t=5;%microsecond
fs=200;%MHz
signal=zeros(5,t*fs);
for i=1:3
signal(i,:)=signal_gen(parameters3(i,:),t,fs);
end
signal1=sum(signal);
figure(1);
plot(real(signal1));
figure(2);
stft(signal1,fs*1e6,'Window',kaiser(101,5),'OverlapLength',100,'FFTLength',500);
figure(3);
for k=1:5
subplot(5,1,k)
plot(real(signal(k,:)))
end
figure(4);
spectrogram(signal1,256,250,[],200e6,'yaxis')
ax = gca;
ax.YDir = 'reverse';
csvwrite('test_Signal_200M_3chirps_easier.csv',signal1)