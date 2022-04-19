function sig = signal_creation(beta,tau,f_c,alpha1,alpha2,phi,t)
sig = beta*exp(-1*alpha1*((t-tau).^2)+1i*2*pi*f_c*(t-tau)+1i*phi+1i*alpha2*((t-tau).^2));
end
