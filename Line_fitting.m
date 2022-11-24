clc
clear all
close all

n = 300;

%% Two group of Observation (y1 , y2) with diffrent sigma
x = 1:n;
y1 = x(1 : 100) + normrnd(3, 0.1, [1, 100]);
y2 = x(101 : n) + normrnd(3, 1.5, [1, 200]);

figure;
scatter(x(1 : 100), y1, 25, 'b', '*'); hold on
scatter(x(101 : n), y2, 25, 'r', 'o'); grid on; axis equal

%% LS
% y = ax + b
L = [y1 , y2]';
A = [x' , ones([n , 1])];
X = A\L;
P = polyfit(x,L',1);

%% VCE
% initial
sigma_1 = 1;
sigma_2 = 1;
Q1 = zeros(n);
Q2 = zeros(n);
Q1(1:100 , 1:100) = eye(100);
Q2(101 : n , 101 : n) = eye(200);
Qy = sigma_1*Q1 + sigma_2*Q2;

disp(['iter     sigma2_1     sigma2_2     diff_1      diff_2'])
disp('-------------------------------------------------------')
for i=1:100
    Qy_1 = inv(Qy);
    PA = eye(n) - (A*inv(A'*Qy_1*A)*A'*Qy_1);
    e = PA*L;
    n11 = 0.5 * trace(Q1*Qy_1*PA * Q1*Qy_1*PA);
    n12 = 0.5 * trace(Q1*Qy_1*PA * Q2*Qy_1*PA);
    n21 = 0.5 * trace(Q2*Qy_1*PA * Q1*Qy_1*PA);
    n22 = 0.5 * trace(Q2*Qy_1*PA * Q2*Qy_1*PA);
    N = [n11, n12 ; n21, n22];

    l1 = 0.5 * (e'*Qy_1*Q1*Qy_1*e);
    l2 = 0.5 * (e'*Qy_1*Q2*Qy_1*e);
    l = [l1 ; l2];

    sigma = N\l;
    str1 = [' ', num2str(i),'       ', num2str(sigma(1)), '     ' ,  num2str(sigma(2)), '    '];
    str2 = [num2str(abs(sigma(1) - sigma_1)), '     ', num2str(abs(sigma(2) - sigma_2))];
    disp([str1, str2]);
    
    if abs(sigma(1) - sigma_1)<1e-6 & abs(sigma(2) - sigma_2)<1e-6
        sigma_1 = sigma(1);
        sigma_2 = sigma(2);
        Qy = sigma_1*Q1 + sigma_2*Q2;
        break
    end
    sigma_1 = sigma(1);
    sigma_2 = sigma(2);
    Qy = sigma_1*Q1 + sigma_2*Q2;
end

Sig_1 = sqrt(sigma(1));
Sig_2 = sqrt(sigma(2));
fprintf('\n')
disp(['Sigma_1 : ', num2str(Sig_1), '    ', 'Sigma_2 : ', num2str(Sig_2)])

%% NEW LS
% y = ax + b
L = [y1 , y2]';
A = [x' , ones([n , 1])];
X = inv(A'*Qy_1*A) * (A'*Qy_1*L);

