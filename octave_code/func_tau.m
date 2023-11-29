function tau_ = func_tau(beta_,f_c_,alpha1_,alpha2_,phi_,t,single_sig)
max_value = 0;
steps = 32;
nestedsteps = 32;
indx = 0;

tau_max = t(end)

max_val_list = [];
tau_list = [];



for i = 1:steps
    tau_ = i*((tau_max)/steps);
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum((chirp_sig).*(conj(single_sig)));

    %figure(1);
    %plot(real(chirp_sig));

    
    

    %figure(20);
    %plot(real(chirp_sig));

    %figure(21);
    %plot(real(single_sig));
    %pause(0.5);

    max_val_list = [max_val_list ; abs(CT1)];
    tau_list = [tau_list ; tau_];

    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end

%
oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    tau_ = i*((tau_max)/(nestedsteps*steps));
    chirp_sig = beta_*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum((chirp_sig).*(conj(single_sig)));

    max_val_list = [max_val_list ; abs(CT1)];
    tau_list = [tau_list ; tau_];

    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end
%}

%figure();
%stem(tau_list, max_val_list);


tau_ = indx*((tau_max)/(nestedsteps*steps));
end
