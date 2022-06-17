function alpha1_ = func_alpha1(beta_,f_c_,tau_,alpha2_,phi_,t,single_sig);
steps = 50;
nestedsteps=40;
indx =0;
max_value = 0;
for i = 1:steps
    alpha1_ = 2e12 + i*((1e12)/steps);
    chirp_sig = beta_*((2*pi*alpha1_)^0.25)*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end 

oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    alpha1_ = 2e12 + i*((1e12)/(steps*nestedsteps));
    chirp_sig = beta_*((2*pi*alpha1_)^0.25)*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end 
alpha1_ = 2e12 + indx*((1e12)/(steps*nestedsteps));
end
