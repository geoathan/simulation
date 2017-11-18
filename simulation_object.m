classdef simulation_object
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    %rubber material and geometric properties
    cp; % specific heat [kj/kg*K]
    k_conduction; % [W/mK]
    rho; % material density [kg/m^3]
    volume; % [m^3]
    specific_length ; %[m]
    length ; %[m]
    alpha;
    area; % [m^2]
    mass; %[kg]
    end
    
    methods
        function obj=simulation_object(cp,k_conduction,rho,volume,specific_length,length)
            obj.cp = cp;
            obj.k_conduction = k_conduction;
            obj.rho = rho;
            obj.volume = volume;
            obj.specific_length = specific_length;
            obj.length= length;
            obj.alpha=k_conduction/(cp*rho);
            obj.area=volume/length;
            obj.mass = volume*rho;
        end
    end
    
end

