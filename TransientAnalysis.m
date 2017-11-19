
clear all
clc
%PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set true or false to activate or deactivate heat transfer modes
options.convection_nat = false; % set true for natural convection
options.convection_for = false; % set true for forced convection
options.conduction_ver = true; % set true for vertebrae conduction
options.conduction_windshield = false; % set true for windshied conduction

%temperatures
heat_transfer.T_inf = 0; % [C] ambient temperature
heat_transfer.T_source = 80; % [C] assuming stady temperature (deprecate)
heat_transfer.Q_source = 100 ; % [W] assuming steady heat flux
heat_transfer.T_rubber_init = -1 ; % [C] initial temperature of rubber
heat_transfer.T_windshield=4; % [C] temperature of the windshield

%simulation_object(length,t,delta_x,cp,k_conduction,rho)
rubber = simulation_object(0.01,0.005,0.002,2.1,0.14,1100);

sim_time=1000; % [s] 

%convection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   convection1 = forced convection    
%   convection2 = natural convection
%
%   CONSTRUCTOR:
%   object = convection(h_coef2[W/m^2K] L1[m] L2[m])
%   
% L1 -> where the heat transfer starts being applied with respect to the top
% L2 -> where the heat transfer stops being applied with respect to the top
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

heat_transfer.convection1 = convection(30,0.001,0.002); % constructor for convection1
heat_transfer.convection2 = convection(11,0.001,0.002);
heat_transfer.convection1 = heat_transfer.convection1.calc_nodes(rubber.nodes,rubber.length); % method to calculate nodes, used for 1D simulation only
heat_transfer.convection2 = heat_transfer.convection2.calc_nodes(rubber.nodes,rubber.length);

%conduction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% when we take conduction we make one simplification: that the hcontact
% between the touching surfaces is infinite. To avoid this simplification
% we should aproximate an h contact for each contact.
%
%   conduction1 = vertebrae conduction    
%   convection2 = windshield conduction
%
%   CONSTRUCTOR:
%   object = conduction(L1[m] L2[m])
%   
% L1 -> where the heat transfer starts being applied with respect to the top
% L2 -> where the heat transfer stops being applied with respect to the top
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

heat_transfer.conduction1 = conduction(0.001,0.003,true,heat_transfer.T_source); % constructor for conduction1
heat_transfer.conduction2 = conduction(0.008,0.01,true,heat_transfer.T_windshield);
heat_transfer.conduction1 = heat_transfer.conduction1.calc_nodes(rubber.nodes,rubber.length); % method to calculate nodes, used for 1D simulation only
heat_transfer.conduction2 = heat_transfer.conduction2.calc_nodes(rubber.nodes,rubber.length);

%ODE45
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    
% initialize node temperatures
init=ones(1,rubber.nodes)*heat_transfer.T_rubber_init; 
    
% set temperature fixed boundaries here, the values are inputed as init
% conditions in ode 45 and the dT for these nodes is set to zero, the
% the output for these fixed nodes should be zero from the 
    
%fixed temperatures for vertebrae
if (options.conduction_ver)
    for i = heat_transfer.conduction1.node_start : heat_transfer.conduction1.node_end
        init(1,i) = heat_transfer.T_source;  
    end
end

%fixed temperatures for windshield
if (options.conduction_windshield)
    for i = heat_transfer.conduction2.node_start : heat_transfer.conduction2.node_end
        init(1,i) = heat_transfer.T_windshield;  
    end
end

%ode45
[t,output]=ode45(@(t,P)OneDimEq(t,P,rubber,heat_transfer,options),[0 sim_time],[init]);
    
    
%ONE DIMENSION PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:rubber.nodes
       plot(t,output(:,i)) 
       hold on
    end
    title('Temperature Development');
    xlabel('Time [s]');
    ylabel('Node Temperature');
    hold off
    
    sum = zeros(size(output,1),1);
    for i=1:rubber.nodes
        sum = sum + output(:,i);
    end
    sum=sum/rubber.nodes;
    figure;
    plot(t,sum);   
    title('Average Temperature Development');
    xlabel('Time [s]');
    ylabel('Average Node Temperature');

