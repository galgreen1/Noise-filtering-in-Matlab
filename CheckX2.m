
function [Ak,k] = CheckX2()
N1 = 5;
n = -10*N1+1:10*N1;
x2 = zeros(1,20*N1);
x2(5*N1+1:15*N1) = 1;
[Ak,k] = FourierCoeffGen(x2,n,20*N1);
x = DiscreteFourierSeries (Ak,k,100)
stem(n,x);
xlabel('n') ;
ylabel('x2_restored');
title('X2');
legend('x2');

end