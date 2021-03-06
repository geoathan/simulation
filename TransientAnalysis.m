%the area is causing the prolem the simulation object has a different area
%we can put the actual area to check it this is the case. (instead of
%generating the area by itself from the rectangle geometry we input the
%surface area)
%clear all   %caused breakpoint problems
clc
%PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set true or false to activate or deactivate heat transfer modes
options.convection_nat = false; % set true for natural convection
options.convection_for = true; % set true for forced convection
options.conduction_ver = true; % set true for vertebrae conduction
options.conduction_windshield = false; % set true for windshied conduction
options.custom_area = true; % overrides the area of the simulation object with a custom area that can approximate better shapes that are not close to the wall model used for the simulation object.

%temperatures
heat_transfer.T_inf = 0; % [C] ambient temperature
heat_transfer.T_source = 80; % [C] assuming stady temperature 
heat_transfer.Q_source = 14 ; % [W] assuming steady heat flux
heat_transfer.T_rubber_init = -1 ; % [C] initial temperature of rubber
heat_transfer.T_windshield=4; % [C] temperature of the windshield

%simulation_object(height,length,t,delta_x,cp,k_conduction,rho)
rubber = simulation_object(0.01,0.635,0.005,0.001,2100,0.35,1100);

if (options.custom_area)
    profile_area = 0.02525 ;%[m^2]
    rubber.exposed_area = profile_area ;
    rubber.node_exposed_area = profile_area/rubber.nodes;
end

sim_time=3000; % [s] 

heat_transfer.convection1 = convection(11.76,0.001,0.01,rubber.nodes,rubber.height);%   convection1 = forced convection    
%heat_transfer.convection2 = convection(11.76,0.001,0.01,rubber.nodes,rubber.height);%   convection2 = natural convection 

heat_transfer.conduction1 = conduction(0.001,0.002,false,heat_transfer.Q_source,rubber.nodes,rubber.height); % conduction from vertebrae
%heat_transfer.conduction2 = conduction(0.009,0.01,true,heat_transfer.T_windshield,rubber.nodes,rubber.height); % conduction from windshield


%ODE45
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    
% initialize node temperatures
init=ones(1,rubber.nodes)*heat_transfer.T_rubber_init; 
    
% set temperature fixed boundaries here, the values are inputed as init
% conditions in ode 45 and the dT for these nodes is set to zero, the
% the output for these fixed nodes should be zero from the 
    
%Initialization of nodes with fixed temperatures for vertebrae
if (options.conduction_ver) && (heat_transfer.conduction1.mode)
    for i = heat_transfer.conduction1.node_start : heat_transfer.conduction1.node_end
        init(1,i) = heat_transfer.T_source;  
    end
end

%Initialization of nodes with fixed temperatures for windshield
if (options.conduction_windshield) && (heat_transfer.conduction2.mode)
    for i = heat_transfer.conduction2.node_start : heat_transfer.conduction2.node_end
        init(1,i) = heat_transfer.T_windshield;  
    end
end

%ode45
[t,output]=ode45(@(t,P)OneDimEq(t,P,rubber,heat_transfer,options),[0 sim_time],[init]);
    
    
% PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
    for i=1:rubber.nodes
       plot(t,output(:,i)) 
       hold on
    end
    title('Temperature Development');
    xlabel('Time [s]');
    ylabel('Node Temperature');
    hold off

figure(2)
    avg = zeros(size(output,1),1);
    for i=1:rubber.nodes
        avg = avg + output(:,i);
    end
    avg=avg/rubber.nodes;
    figure(2);
    plot(t,avg);   
    title('Average Temperature Development');
    xlabel('Time [s]');
    ylabel('Average Node Temperature');
figure(3)
    mesh(output);
    
    
   

