function tau_ = func_tau(beta_,f_c_,alpha1_,alpha2_,phi_,t,single_sig)
max_value = 0;
steps =50;
nestedsteps=40;
for i = 1:steps
    tau_ = 1.5e-6 + i*((2e-6)/steps);
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end 

oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    tau_ = 1.5e-6 + i*((2e-6)/(nestedsteps*steps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end 
tau_ = 1.5e-6 + indx*((2e-6)/(nestedsteps*steps));
end
