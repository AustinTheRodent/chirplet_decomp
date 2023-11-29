function f_c_ = func_fc(beta_,tau_,alpha1_,alpha2_,phi_,t,single_sig)
max_value = 0;
steps =50;
nestedsteps=40;

max_val_list = [];
f_c_list = [];

fmin = 1e6;
fmax = 30e6;

indx=0;
for i = 1:steps
    f_c_ = fmin + i*((fmax-fmin)/(steps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    %figure(1);
    %plot(real(chirp_sig));
    CT1 = sum(chirp_sig.*conj(single_sig));

    max_val_list = [max_val_list ; abs(CT1)];
    f_c_list = [f_c_list ; f_c_];

    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end 

oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    f_c_ = fmin + i*((fmax-fmin)/(nestedsteps*steps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(chirp_sig.*conj(single_sig));

    max_val_list = [max_val_list ; abs(CT1)];
    f_c_list = [f_c_list ; f_c_];

    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end 

%figure();
%stem(f_c_list, max_val_list);

f_c_ = fmin + indx*((fmax-fmin)/(nestedsteps*steps));
end
