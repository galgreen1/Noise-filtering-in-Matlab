function [Ak,k] = FourierCoeffGen(x,n,N)
k1 = ceil(-(N-1)/2):ceil((N-1)/2);
n1=reshape(n,1,numel(n));
x1=reshape(x,1,numel(x));
W=(1/N)*exp(-1i*2*pi*n1'*k1/N);
Ak=(x1)*W;
k=k1;

end

