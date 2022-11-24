clc
clear all
close all

N = 20;
n = N^2;
%% Two group of Observation (x1,y1,z1) , (x2,y2,z2)
[X,Y] = meshgrid(linspace(0,2,N));
XYZ_2 = [X(:) Y(:) 2*ones([n, 1])];

noise1 = normrnd(0, 0.1, [n/2, 1]);
noise2 = normrnd(0, 0.02, [n/2, 1]);

x1 = XYZ_2(1:n/2 , 1) + noise1;
x2 = XYZ_2(n/2 + 1:end , 1) + noise2;

y1 = XYZ_2(1:n/2,2) + noise1;
y2 = XYZ_2(n/2 + 1:end , 2) + noise2;

z1 = XYZ_2(1:n/2,3) + noise1;
z2 = XYZ_2(n/2 + 1:end , 3) + noise2;

figure;
scatter3(x1, y1, z1, 25, 'b', '*'); hold on
scatter3(x2, y2, z2, 25, 'r', 'o'); grid on; axis equal
% scatter3(XYZ_2(:,1), XYZ_2(:,2), XYZ_2(:,3), 25, 'g', 'o'); grid on; axis equal

%% LS
% z = ax + by + c
L = [z1 ; z2];
A = [x1 , y1 , ones([n/2 , 1]) ; x2 , y2, ones([n/2 , 1])];
X = A\L

%% VCE
% initial
sigma_1 = 100;
sigma_2 = 0.001;
Q1 = zeros(n);
Q2 = zeros(n);
Q1(1:n/2 , 1:n/2) = eye(n/2);
Q2(n/2+1 : n , n/2+1 : n) = eye(n/2);
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
L = [z1 ; z2];
A = [x1 , y1 , ones([n/2 , 1]) ; x2 , y2, ones([n/2 , 1])];
X = (A'*Qy_1*A)\(A'*Qy_1*L)



