%   Intelligent Control ZJU 2022-FALL HW2
%   Expert System
%   created by StvLi LiPZ 20221202
clear;
clc;
%   Part0 Initiation
%       run in 1 time
%   simulation time
Tt  = 1.5;

%   sample time
Ts  = 0.01;

%   initial state
%   x1 - angle y
%   x2 - angular velocity dy
%   x3 - force u_
x   = [179*pi/180 0 0]';

%   allocate recording space
stepToRun   = Tt/Ts; 
precStep    = 0;
ur  = zeros( 1 , stepToRun );
y   = zeros( 2 , stepToRun );
sr  = zeros( 1 , stepToRun );

while ( precStep*Ts<Tt )   %   run in loop
    %   Classifier
    ContState = myExpeContClassifier( x );
    sr(precStep+1) = ContState;

    %   Controller
    u   = myExpeContController( x , ContState );

    %   Plant
    x = myPlantDyna( x , u , Ts );

    %   Recorder
    precStep = precStep+1;
    
    y(1,precStep)   = x(1);
    y(2,precStep)   = x(2);
    ur(1,precStep)  = u;
    t(1,precStep)   = precStep * Ts;
end
disp('Simulation DONE');

%   plot
%       time domain
subplot(4,1,1);
plot(t,sr);
legend('Control State');

subplot(4,1,2);
plot(t,ur);
legend('Controller Output / N');

subplot(4,1,3);
plot(t,y(1,:)*180/pi);
legend('Angle / °');

subplot(4,1,4);
plot(t,y(2,:)*180/pi);
legend('Angular Velocity / °/s');

% %       state space
% plot(abs(y(1,:)*180/pi),abs(y(2,:)*180/pi))
% hold on
% plot(30*ones(700,1),1:700)
% hold on
% plot(90*ones(700,1),1:700)
% hold on
% plot(90:180,180*ones(91,1))
% hold on
% plot(1:30,60*ones(30,1))
% legend('State Trajectory');
