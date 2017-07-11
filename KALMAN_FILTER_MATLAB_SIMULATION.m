clc
clear all

file_input1='data_test.csv';
data=csvread(file_input1);
dim=size(data);

data_x=data(:,1);
data_y=data(:,2);
data_acc_x=data(:,7)/100;    % 1 milligal [mg] = 0.01 [mm/s^2]
data_acc_y=data(:,8)/100;


measnoise = 40; % position measurement noise   (es. 4CM=40MM)
accelnoise = 2; % acceleration noise  [es. 0.2 feet/s^2 = 61 mm/s^2)

T=0.5; %sampling time

A = [1 T 0 0; 0 1 0 0; 0 0 1 T; 0 0 0 1]; % transition matrix
B = [T^2/2 0; T 0; 0 T^2/2; 0 T]; % input matrix
C = [1 0 0 0; 0 0 1 0]; % measurement matrix
x = [data_x(1); 0; data_y(1); 0]; % initial state vector x(0)

Sz = [measnoise^2 0; 0 measnoise^2]; % measurement error covariance
Sw = accelnoise^2 * [(T^2/2)^2 (T^2/2)*T 0 0; (T^2/2)*T T^2 0 0; 0 0 (T^2/2)^2 (T^2/2)*T; 0 0 (T^2/2)*T T^2]; % process noise covariance


xhat = x; % initial state estimate
P = Sw; % initial estimation covariance

% Initialize arrays of points for plotting
poshat = []; % estimated position array


for t = 1 : 1: size(data_x)

    u =[data_acc_x(t); data_acc_y(t)];    % acceleration

    % Simulate the linear system.
   % ProcessNoise = accelnoise * [T^2/2*randn; T*randn; T^2/2*randn; T*randn];
   %x = A * x + B * u + ProcessNoise;

    % assign (noisy) measured data
    y=[data_x(t); data_y(t)];

    % Extrapolate the most recent state estimate to the present time.
    xhat = A * xhat + B * u;
    % Form the Innovation vector.
    Inn = y - C * xhat;
    % Compute the covariance of the Innovation.
    s = C * P * C' + Sz;
    % Form the Kalman Gain matrix.
    K = A * P * C' * inv(s);
    % Update the state estimate.
    xhat = xhat + K * Inn;
    % Compute the covariance of the estimation error.
    P = A * P * A' - A * P * C' * inv(s) * C * P * A' + Sw;
    % Save some parameters
    poshat = [poshat; xhat(1) xhat(3)];
end




figure;

%background image
img = imread('ufficio7.png');
min_x = 0;
max_x = 4170;
min_y = 0;
max_y = 4650;
imagesc([min_x max_x], [min_y max_y], flipud(img));
set(gca,'ydir','normal');
%rettangolo sfumatura bianco
p=patch([min_x min_x max_x max_x],[min_y max_y max_y min_y],'w');
set(p,'FaceAlpha',0.9);


hold on;
%grid;
xlabel('position X [mm]');
ylabel('position Y [mm]');
title('Position');

axis([min_x max_x min_y max_y]);

cross=plot(data_x, data_y,'+');
line=plot(poshat(:,1), poshat(:,2),'-','linewidth', 1, 'color',[1 0.5 0]);


leg=legend([cross line],'measured','estimated (kalman)');
set(leg,'Location','northwest');
