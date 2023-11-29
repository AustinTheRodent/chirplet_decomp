function alpha1_ = func_alpha1(beta_,f_c_,tau_,alpha2_,phi_,t,single_sig);
steps = 50;
nestedsteps=40;
indx =0;
max_value = 0;

a1_list = [];
ct_list = [];

a1min = 1e12;
a1max = 1e15;

for i = 1:steps
    alpha1_ = a1min + i*((a1max-a1min)/steps);
    %chirp_sig = beta_*((2*pi*alpha1_)^0.25)*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    chirp_sig = 4e-4*((2*pi*alpha1_)^0.25)*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(abs(chirp_sig).*abs(conj(single_sig)));

    a1_list = [a1_list;alpha1_];
    ct_list = [ct_list;CT1];

    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i*nestedsteps;
    end
end 

oldindx=indx;
for i = oldindx-nestedsteps+1:oldindx+nestedsteps-1
    alpha1_ = a1min + i*((a1max-a1min)/(steps*nestedsteps));
    %chirp_sig = beta_*((2*pi*alpha1_)^0.25)*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    chirp_sig = 4e-4*((2*pi*alpha1_)^0.25)*exp(-1*alpha1_*((t-tau_).^2)+1i*2*pi*f_c_*(t-tau_)+1i*phi_+1i*alpha2_*((t-tau_).^2));
    CT1 = sum(abs(chirp_sig).*abs(conj(single_sig)));

    a1_list = [a1_list;alpha1_];
    ct_list = [ct_list;CT1];

    if abs(CT1)>max_value
        max_value = abs(CT1);
        indx = i;
    end
end

%figure();
%stem(a1_list, abs(ct_list));

alpha1_ = a1min + indx*((a1max-a1min)/(steps*nestedsteps));
end
