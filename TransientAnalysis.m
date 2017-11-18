
clear all
clc
%PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set true or false to activate or deactivate heat transfer modes
options.dimensions = 1; % set to 0 for zero dimensional set 1 for one dimensional analysis
options.convection_nat = false; % set true for natural convection
options.convection_for = false; % set true for forced convection
options.conduction_ver = true; % set true for vertebrae conduction
options.ver_QorT = true; % if true the vertebrae has a constant Q else constant T
options.conduction_windshield = true; % set true for windshied conduction
options.conduction_ice= false; % set true for ice (currently only used on 0D)

if (options.dimensions ~= 0) && (options.dimensions ~= 1)
    display('invalid number of dimensions');
end

%temperatures
heat_transfer.T_inf = 0; % [C] ambient temperature
heat_transfer.T_source = 80; % [C] assuming stady temperature (deprecate)
heat_transfer.Q_source = 100 ; % [W] assuming steady heat flux
heat_transfer.T_rubber_init = -1 ; % [C] initial temperature of rubber
heat_transfer.T_windshield=4; % [C] temperature of the windshield

rubber=simulation_object(2.1,0.16,1.1*10^3,0.0000155194,0.00739,0.010);

sim.time=20; % [s] 
sim.delta_x = 0.001; % [m]
sim.nodes=round(rubber.length/sim.delta_x);
sim.node_sur=(rubber.area/sim.nodes); % this is the area for each node using the 1 Dimensional model, in the 1 Dimensional model, the rubber surface is given directly bu the number of rubber nodes and the area defined in the table is irrelevant. The body is considered as a one dimensional wall 

%ice.status = options.conduction_ice;
%ice.mass_init = 0.002; %[kg]
%ice.temp_init = 0;
%ice.contact_area = 0.002;
%ice.cp = 2; % kj/kg K
%ice.quality_init = 1;
%ice.latent_heat = 334000; % j/kg
%ice.latent_calories=ice.latent_heat*ice.mass_init; %j

%convection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   convection1 = forced convection    
%   convection2 = natural convection
%
%   CONSTRUCTOR:
%   object = convection(Area2[m^2]  h_coef2[W/m^2K] L1[m] L2[m])
%   
% L1 -> where the heat transfer starts being applied with respect to the top
% L2 -> where the heat transfer stops being applied with respect to the top
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

heat_transfer.convection1 = convection(0.0192,30,0.001,0.002); % constructor for convection1
heat_transfer.convection2 = convection(0.0192,11,0.001,0.002);
heat_transfer.convection1 = heat_transfer.convection1.calc_nodes(sim.nodes,rubber.length); % method to calculate nodes, used for 1D simulation only
heat_transfer.convection2 = heat_transfer.convection2.calc_nodes(sim.nodes,rubber.length);

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
%   object = convection(Area2[m^2] L1[m] L2[m])
%   
% L1 -> where the heat transfer starts being applied with respect to the top
% L2 -> where the heat transfer stops being applied with respect to the top
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

heat_transfer.conduction1 = conduction(0.00496,0.001,0.003,true,heat_transfer.T_source); % constructor for conduction1
heat_transfer.conduction2 = conduction(0.003,0.008,0.01,true,heat_transfer.T_windshield);
heat_transfer.conduction1 = heat_transfer.conduction1.calc_nodes(sim.nodes,rubber.length); % method to calculate nodes, used for 1D simulation only
heat_transfer.conduction2 = heat_transfer.conduction2.calc_nodes(sim.nodes,rubber.length);

%ODE45
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (options.dimensions == 1)
    
    % initialize node temperatures
    init=ones(1,sim.nodes)*heat_transfer.T_rubber_init; 
    
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
    [t,output]=ode45(@(t,P)OneDimEq(t,P,rubber,heat_transfer,options,sim),[0 sim.time],[init]);
    
    
    %ONE DIMENSION PLOTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:sim.nodes
       plot(t,output(:,i)) 
       hold on
    end
    title('Temperature Development');
    xlabel('Time [s]');
    ylabel('Node Temperature');
    hold off
    
    sum = zeros(size(output,1),1);
    for i=1:sim.nodes
        sum = sum + output(:,i);
    end
    sum=sum/sim.nodes;
    figure;
    plot(t,sum);   
    title('Average Temperature Development');
    xlabel('Time [s]');
    ylabel('Average Node Temperature');
end


%ZERO DIMENSION PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (options.dimensions == 0)
    [t,output]=ode45(@(t,P)ZeroDimEq(t,P,rubber,ice,heat_transfer,options),[0 sim.time],[heat_transfer.T_rubber_init,ice.temp_init,ice.latent_calories,ice.mass_init]);
    
    % assinging output to different variables for clarity
    rubber_temp = output(:,1);
    ice_temp = output(:,2);
    ice_energy_until_melt = output(:,3);
    ice_mass =  output(:,4);

    % plot script 0D
    if (ice.status)
         plot(t,ice_temp,t,rubber_temp);
         xlabel('Time [s]');
         ylabel('Temperature [C]');
         xlim([0 sim.time]);
         legend('ice','rubber');
         hold on;
         figure;
         plot(t,ice_energy_until_melt);
         xlabel('Time [s]');
         ylabel('Ice Latent Heat Energy [J]');
         hold on;
         figure;
         plot(t,ice_mass);
         xlabel('Time [s]');
         ylabel('mass [kg]');
        title('ice mass remaining');
        hold off;
    else
        plot(t,rubber_temp);
        xlabel('Time [s]');
        ylabel('Temperature [C]');
        xlim([0 sim.time]);
        title('Rubber temperature vs time');
    end    
end
