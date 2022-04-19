function sig = signal_gen(parameters,t,fs) %(beta,tau,f_c,alpha1,alpha2,phi,t)
alpha1=parameters(1);
alpha2=parameters(2);
tau=parameters(3);
f_c=parameters(4)*10;
phi=parameters(5);
beta=parameters(6);
t_line=linspace(0,t,t*fs);
sig = beta*exp(-1*alpha1*((t_line-tau).^2)+1i*2*pi*f_c*(t_line-tau)+1i*phi+1i*alpha2*((t_line-tau).^2));
end
%micro seconds, MHz, rad
