function alpha2_ = func_alpha2(beta_,f_c_,alpha1_,tau_,phi_,t,single_sig)
steps= 50;
nestedsteps=40;
indx =0;
max_value = 0;

a2min = -2e13;
a2max = 2e13;

for i = 1:steps
    alpha2_ = a2min + i*((a2max-a2min)/steps);
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end 

oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    alpha2_ = a2min + i*((a2max-a2min)/(steps*nestedsteps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end 

alpha2_ = a2min + indx*((a2max-a2min)/(steps*nestedsteps));
end
