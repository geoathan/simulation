classdef convection
    %UNTITLED Summary of this class goes here
    %convection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %   
    % L1 -> where the heat transfer starts being applied with respect to the top
    % L2 -> where the heat transfer stops being applied with respect to the top
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        h    % convection coefficient
        L1   % length with respect to the top of where the heat transfer starts being applied in 1D simulation
        L2   % length with respect to the top of where the heat transfer stops being applied in 1D simulation
        L    % total lenfth where the convection is applied in 1D
        node_start % if we have 1D simulation this signifies the node where the convection starts
        nodes      % if we have 1D simulation this signifies on how many nodes the convection is applied
        node_end   % if we have 1D simulation this signifies the node where the convection stops being applied
    end
    
    methods
        function obj = convection(  input_h, input_L1, input_L2, nodes,total_length)
            if ((input_L2-input_L1)<0)
                display ('L1 cannot be larger than L2')
            else
                
                obj.h=input_h;
                obj.L1=input_L1;
                obj.L2=input_L2;
                obj.L = input_L2-input_L1;
                obj.node_start = round((input_L1/total_length)*nodes);
                obj.node_end = round((input_L2/total_length)*nodes);
                obj.nodes = round((input_L2/total_length)*nodes) - round((input_L1/total_length)*nodes)+1;
            end
        end
        
    end
    
end

