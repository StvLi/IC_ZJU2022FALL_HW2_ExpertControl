function [sys,x0,str,ts,simStateCompliance] = EX2_plant(t,x,u,flag)
%SFUNTMPL General MATLAB S-Function Template
%   Copyright 1990-2010 The MathWorks, Inc.

%
% The following outlines the general structure of an S-function.
%
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes;

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes
%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;
sizes.NumContStates  = 6;   %   number of continuous state coordinates
sizes.NumDiscStates  = 0;   %   number of discrete state coordinates
sizes.NumOutputs     = 2;   %   number of Outputs
sizes.NumInputs      = 4;   %   number of Inputs
sizes.DirFeedthrough = 1;   %   throughout Feed (have no idea wtf it is)
sizes.NumSampleTimes = 1;   %   at least one sample time is needed
sys = simsizes(sizes);

% initialize the initial conditions
x0  = [ 0 0 0 0 0 0 ];

% str is always an empty matrix
str = [];

% initialize the array of sample times
ts  = [0 0];    %   continuous system

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';
% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)
    %   parameter
    l1 = 1.8 ;
    l2 = 1.4 ;
    m1 = 2.7 ;
    m2 = 2.1 ;
    g  = 9.8 ; 
    p1 = (m1+m2)*l1*l1  ;
    p2 = m2*l2*l2       ;
    p3 = m2*l1*l2       ;
    p4 = (m1+m2)*l1     ;
    p5 = m2*l2          ;
    
    %   x(1) - q1
    %   x(2) - dq1
    %   x(3) - ddq1
    %   x(4) - q2
    %   x(5) - dq2
    %   x(6) - ddq2
    M = [
            p1+p2+2*p3*cos(x(4)),   p2+p3*cos(x(4));
            p2+p3*cos(x(4))     ,   p2
        ];
    C = [
            -p3*x(5)*sin(x(4))  ,   -p3*(x(2)+x(5))*sin(x(4));
            p3*x(2)*sin(x(4))   ,   0
        ];
    G = [
            p4*g*cos(x(1))+p5*g*cos(x(1)+x(4));
            p5*g*cos(x(1)+x(4))
        ];

    Matrix1 = -inv(M)*C;
    Matrix2 = inv(M);
    A = [
            0 1             0 0 0               0;
            0 0             1 0 0               0;
            0 Matrix1(1,1)  0 0 Matrix1(1,2)    0;
            0 0             0 0 1               0;
            0 0             0 0 0               1;
            0 Matrix1(2,1)  0 0 Matrix1(2,2)    0;
        ];
    B = [
            0               0;
            0               0;
            Matrix2(1,1) Matrix2(1,2);
            0               0;
            0               0;
            Matrix2(2,1) Matrix2(2,2);
        ];
    %   x(1) - t1
    %   x(2) - t2
    %   x(3) - td1
    %   x(4) - td2
sys = A*x + B*([u(1);u(2)]-[u(3);u(4)]-G);

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)
C = [ 0 1 0 0 0 0 ; 0 0 0 0 1 0 ];
D = [0 0 0 0];
sys = C*x + D*u ;

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
