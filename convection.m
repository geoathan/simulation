classdef convection
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        area % area for which the heat transfer takes place
        h    % convection coefficient
        L1   % length with respect to the top of where the heat transfer starts being applied in 1D simulation
        L2   % length with respect to the top of where the heat transfer stops being applied in 1D simulation
        L    % total lenfth where the convection is applied in 1D
        node_start % if we have 1D simulation this signifies the node where the convection starts
        nodes      % if we have 1D simulation this signifies on how many nodes the convection is applied
        node_end   % if we have 1D simulation this signifies the node where the convection stops being applied
    end
    
    methods
        function obj = convection( input_area, input_h, input_L1, input_L2)
            if ((input_L2-input_L1)<0)
                display ('L1 cannot be larger than L2')
            else
                obj.area=input_area;
                obj.h=input_h;
                obj.L1=input_L1;
                obj.L2=input_L2;
                obj.L = input_L2-input_L1;
            end
        end
        

        function obj = calc_nodes(obj,nodes,total_length)
            obj.node_start = round((obj.L1/total_length)*nodes);
            obj.nodes = round((obj.L/total_length)*nodes);
            obj.node_end = obj.node_start + obj.nodes;
            
        end
    end
    
end

