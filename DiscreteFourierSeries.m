function x = DiscreteFourierSeries (Ak,k,N_per)
W=exp(1i*2*pi*k'*k/N_per);
%disp(W);
Value = Ak*W;
x=Value;

end