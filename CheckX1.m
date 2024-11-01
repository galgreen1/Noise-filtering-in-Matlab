function [Ak,k] = CheckX1()
C = 7;
n = (-(C-1)/2:(C-1)/2);
x1 = cos(2*pi*n/C);
[Ak,k] = FourierCoeffGen(x1,n,C);
x = DiscreteFourierSeries (Ak,k,C)
stem(n,x);
xlabel('n') ;
ylabel('x1_restored');
title('Fourier Transform of X1');
legend('x1');


end