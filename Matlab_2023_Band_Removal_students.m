close all
clc
clear

%% Generation of noisy signal
% Enter your ID  (long int)
ID = 215357567;
fs = 11025;

noisySignal = Build_signal(ID);
soundsc(noisySignal,fs)

% Plot the signal
figure();
plot(0:length(noisySignal)-1,noisySignal);
xlabel('n','fontsize',16);
ylabel('signal','fontsize',16);
title('noisy signal - time domain')



% Save the noisy signal
audiowrite(['Input_' num2str(ID) '.wav'],noisySignal,fs)
[x, fs] = audioread('about_time.wav');
x       = x(1:length(noisySignal));
SNR_in  = 10*log10(mean(x.^2)/mean((noisySignal-x).^2))

%% Fourier coeffesions for the noisy signal - each frame with lengte =512
% We will compute the fourier coeffesions frame by frame and plot it as
% function of k (fourier coeffesions) and discrete time - n (for each frame). 
% that means that we will have a matrix. 
% our signal contain speech - in low k's values, and noise - in high k's
% values.
% we want to identify K - LPF cutoff value base on the fourier coeffesions of the
% noisy signal to filter the noise


figure()
N_frame  = 512;
Ak_matrix=[];
for n_frame=1:floor(length(noisySignal)/N_frame)
    [ak,k]   = FourierCoeffGen(noisySignal((n_frame-1)*N_frame+1:n_frame*N_frame)',((n_frame-1)*N_frame+1:n_frame*N_frame)',N_frame);
    Ak_matrix(:,n_frame)=ak;
end 
% 
T = 1:size(Ak_matrix,2)*fs;

imagesc(T,k(N_frame/2:end),20*log10(abs(Ak_matrix(N_frame/2:end,:)+eps)))
% we plot only half of the k's valus because xn is real signal so Ak will
% be symmetric.
axis xy
xlabel('Time[Sec]');
ylabel('K','fontsize',12);
text(0.05,937.5,'f =937.5')
set(gca,'fontsize',14);
colorbar
title('fourier coeff of unfiltered signal')



% FIR Low pass filtering (based on Term-A semester A linear systems 2023)

N = N_frame;
% what should K be? based you answer on the previous plot
K =  55;
k = -(K-1) :K-1;
h = 0;

% Generate the filter 
for n=1:N % times are at -(N-1)/2 : (N-1)/2
    terms = (1/N)*exp(1i*2*pi*(n-(N-1)/2)*k/N);
    h(n) = sum(terms);
end

% Plot the Filter Frequency response: 
n=1:N;
stem(n,h);
xlabel('n') ;
ylabel('filter Frequency');
title('filter Frequency response');
legend('h');


%TODO

% Signal filtering - time domain
% Note - you can use conv() function to filter the signal. 
% use the option 'same' to get the same output length.
% for example if you have: input-x filter-h:
% y = conv(x,h,'same') 
% y might be complex (because 'h' might be complex) - take only real part of the result

y = conv(noisySignal,h,'same');
y = real(y);


% Plot the filtered singnal (in time)
figure();
n=1:length(noisySignal);
stem(n,y);
xlabel('n') ;
ylabel('filtered signal');
title('filtered signal (in time)');
legend('y');


% Play the filtered signal
pause(3);
soundsc(y,fs)

% Save the filtered signal
audiowrite(['Output_I_' num2str(ID) '.wav'],y,fs)

% Plot Fourier coeffesions after time filtering

figure()
Ak_matrix_filtered=[];
for n_frame=1:floor(length(noisySignal)/N_frame)

    [ak_filtered_t, k_filtered_t]   = FourierCoeffGen(y((n_frame-1)*N_frame+1:n_frame*N_frame)',((n_frame-1)*N_frame+1:n_frame*N_frame)',N_frame);

    Ak_matrix_filtered(:,n_frame)=ak_filtered_t;
end 
% 
T = 1:size(Ak_matrix_filtered,2)*fs;
imagesc(T,k_filtered_t(N_frame/2:end),20*log10(abs(Ak_matrix_filtered(N_frame/2:end,:)+eps)))

axis xy
xlabel('Time[Sec]');
ylabel('K','fontsize',12);
text(0.05,937.5,'f =937.5')
set(gca,'fontsize',14);
colorbar
title('Fourier coeffesions - time filtered signal')

% Calculate the SNR's
SNR_out         = 10*log10(mean(x.^2)/mean((y-x).^2))
SNR_improvement = SNR_out - SNR_in

%% Filter frame by frame -  frequency domain

 Zk=zeros(1,N_frame);
z = zeros(size(noisySignal));
n1=1:length(h);
[Hk,k]   = FourierCoeffGen(h,n1,N_frame);
for n=1:floor(length(noisySignal)/N_frame) % Frame based operation , Add as many lines as needed 
    n_frame = (n-1)*N_frame+1 : n*N_frame;
    y_frame = noisySignal(n_frame);
    [Yk,k] = FourierCoeffGen(y_frame.',(n_frame).',N_frame);
    Zk = Hk.*Yk*N_frame;
    z(n_frame) = DiscreteFourierSeries (Zk,k,N_frame);
end
z = real(z);
figure();
stem(k,Hk);
xlabel('k') ;
ylabel('Hk');
title('fourier series of the filter');
legend('Hk');

pause(3);
soundsc(z,fs)



% z = zeros(size(noisySignal));
% for n=1:floor(length(noisySignal)/N_frame) % Frame based operation , Add as many lines as needed 
%     n_frame = (n-1)*N_frame+1 : n*N_frame;
%     y_frame          = noisySignal(n_frame);
%     n_h=1:N
%     [Hk,k_h]=FourierCoeffGen(h,n_h,N_frame);  %fourier coeff of the filter
%     [Yk,k_y]=FourierCoeffGen(y_frame,n_h,N_frame);  %fourier coeff of the noisy signal 
%     Zk=Yk.*Hk;   
% 
% 
%     z(n_frame)= DiscreteFourierSeries (Zk,k_y,N_frame)
%     =FourierSum(Zk,k_y,N_frame);
% end
% 
% %if needed, add z = real(z);
% z=real(z);
% pause(3);
% soundsc(z,fs)

% Plot the filtered singnal (in time)
figure();
n=1:length(z);
stem(n,z);
xlabel('n') ;
ylabel('filtered signal');
title('filtered signal (in time)');
legend('z');


%TODO
h=DiscreteFourierSeries(Hk,n1,N_frame);
h=real(h);
n=1:length(h);
figure();
stem(n,h);
xlabel('n') ;
ylabel('filter');
title('filter restored ');
legend('h');


% Plot Fourier coeffesions after freq' filtering


figure()
Ak_matrix_filtered=[];
for n_frame=1:floor(length(noisySignal)/N_frame)

    [ak_filtered_f, k_filtered_f]   = FourierCoeffGen(z((n_frame-1)*N_frame+1:n_frame*N_frame)',((n_frame-1)*N_frame+1:n_frame*N_frame)',N_frame);

    Ak_matrix_filtered(:,n_frame)=ak_filtered_f;
end 
% 
T = 1:size(Ak_matrix_filtered,2)*fs;
imagesc(T,k_filtered_f(N_frame/2:end),20*log10(abs(Ak_matrix_filtered(N_frame/2:end,:)+eps)))


axis xy
xlabel('Time[Sec]');
ylabel('K','fontsize',12);
text(0.05,937.5,'f =937.5')
set(gca,'fontsize',14);
colorbar
title('Fourier coeffesions - freq filtered signal')

% Calculater SNR's
SNR_out         = 10*log10(mean(x.^2)/mean((z-x).^2))
SNR_improvement = SNR_out - SNR_in

%% Performace evaluation:

[Grade, SNR_out_ref]= GradeMyOutput(ID,y);
[Grade, SNR_out_ref]= GradeMyOutput(ID,z);