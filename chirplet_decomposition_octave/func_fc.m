function f_c_ = func_fc(beta_,tau_,alpha1_,alpha2_,phi_,t,single_sig)
max_value = 0;
steps =50;
nestedsteps=40;
for i = 1:steps
    f_c_ = 4e6 + i*((2e6)/(steps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end 

oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    f_c_ = 4e6 + i*((2e6)/(nestedsteps*steps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end 

f_c_ = 4e6 + indx*((2e6)/(nestedsteps*steps));
end
