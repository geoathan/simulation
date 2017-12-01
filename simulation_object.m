classdef simulation_object
    %In this class a one dimensional wall simulation object is defined
    %   The simulation object includes geometrical and material properties
    %   of the object. The object is assumed to be a wall.
    %
    % exposed area marked with x, and also from the oposite side, the front
    % and back area are not exposed because the material continues in that
    % direction. The exposed area is used for convection boundary
    % conditions. The edje of the wall that defines the exposed area could
    % be of any height, then the area corresponding to one node would grow,
    % but the mass corresponding to the node would also grow
    % proportionally. 
    % as a result the cross section of the object is a rectangle of edge
    % height L and t and each node coresponds to a cuboid of dimensions
    % L*dx*t. t is the thickness of the wall and should be defined 
    % according to the thickness or the average thickness of the wall
    %In this case, the totax exposed surface would be 2*?x*L
    %            ______            _             _______ 
    % -->      /      /| <--        |           /      /|
    % -->     /_____ /x| <--        |          /      / |  Delta_x
    % -->    |   0  |xx| <--        |         /    0 / /  <- volume for 1 node
    % -->    |   |  |xx| <--        |        /______/ / L 
    % -->    |   0  |xx| <--        | height|_______|/  
    % -->    |   |  |xx| <--        |           t
    % -->    |   0  |xx| <--        |
    % -->    |   |  |xx| <--        |
    % -->    |   0  |x/  <--       _|    
    % -->    |______|/ L               
    %            t
    properties
    
    %geometric properties
    height;  %[m] height from top to bottom of the profile (1D dimension)
    length; % [m] total length in the logitudinal direction. direction where the profile has constant shape
    exposed_area; % [m^2] area of the simulated 1D object that is in contact with (see figure)
    thickness; % [m] thickness of the cross-section
    delta_x; % [m] height of th cross section.
    volume; % [m^3]
    mass; %[kg]
    
    %material properties
    cp; % specific heat [j/kg*K] !!!!
    k_conduction; % [W/mK]
    rho; % material density [kg/m^3]
    alpha; % alpha = k_conduction/(cp*rho)
    
    %mesh
    nodes; 
    node_mass;  %[kg]
    node_volume; %[m^3]
    node_exposed_area; %[m^2]
    end
    
    methods
        function obj=simulation_object(height,length,t,delta_x,cp,k_conduction,rho)
            obj.cp = cp;
            obj.k_conduction = k_conduction;
            obj.rho = rho;
            obj.alpha=k_conduction/(cp*rho);
            obj.thickness=t;
            obj.height=height;
            obj.length=length;
            obj.exposed_area= 2*height*length;
            obj.delta_x=delta_x;
            obj.volume=length*t*height;
            obj.mass = length*t*height*rho;
            obj.nodes= height/delta_x;
            obj.node_mass= length*delta_x*t*rho;
            obj.node_volume=length*delta_x*t;
            obj.node_exposed_area= 2*length*delta_x;
        end
    end
    
end


