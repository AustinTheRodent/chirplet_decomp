function phi_ = func_phi(beta_,f_c_,alpha1_,alpha2_,tau_,t,single_sig)

chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*alpha2_*((t-tau_).^2));
phi_ = angle(sum(single_sig.*conj(chirp_sig)));

%{
indx =0;
max_value = 0;
steps = 50;
nestedsteps=40;
for i = 1:steps
    phi_ = 1 + i*((1)/(steps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end 

oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    phi_ = 1 + i*((1)/(steps*nestedsteps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));
    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end 

phi_ = 1 + indx*((1)/(steps*nestedsteps));
%}
end
