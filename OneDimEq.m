function T_dot = OneDimEq(t,P,rubber,heat_transfer,options,sim)
%ONEDIMEQ function for one dimensional analysis
%   All the heat transfers Q between the nodes and from the enviroment to
%   the nodes are calculated. First the differential heat transfer via
%   conduction in the material is calculated. Then the differential heat
%   transfer for convection conduction etc. The outside heat transfers
%   should be applied to the correct nodes. The rubber is modeled as a one
%   dimensional wall.

% dT/dt=(1/a)* d^2T/dX^2 Fourrier
% for each node: T_dot= ( T_i-1 + T_i+1 - 2*T_i ) * a/(delta_x^2)
% a=alpha=diffusivity 
% T_dot = dT/dt
% Q_dot = dQ/dt
% Q=m*cp*?T <=> Q_dot = m*cp*??_dot
T_dot=zeros(sim.nodes,1); %initialize output table size by defining a zero table
T_dot(1,1)=((P(2)-P(1))*rubber.alpha)/(sim.delta_x^2);
    for i = 2 : sim.nodes-1
        T_dot(i,1)=((P(i+1)+P(i-1)-2*P(i))*rubber.alpha)/(sim.delta_x^2); % derived from Fourrier eq. the differential for each node is proportional to the difeerence of temperature with it's neighbouring nodes times difussivity divided by delta_x
    end
T_dot(sim.nodes,1)=((P(sim.nodes-1)-P(sim.nodes))*rubber.alpha)/(sim.delta_x^2);

if (options.convection_nat)
    conv_tabl=zeros(sim.nodes,1);
    %Q1=heat_transfer.convection(2,2)*heat_transfer.convection(2,1)*(heat_t
    %ransfer.T_inf-P(1)); % heat transfer from rubber to air by natural convection
    for i = heat_transfer.convection2.node_start : (heat_transfer.convection2.node_start + heat_transfer.convection2.nodes)
        q_dot_node=heat_transfer.convection2.h*(heat_transfer.convection2.area/heat_transfer.convection2.nodes)*(heat_transfer.T_inf-P(i));%q_dot_node= h * A_node * (T-Tinf) => q_dot_node = h * A_node * (T-Tinf)*T_dot
        conv_tabl(i,1)= q_dot_node/(rubber.cp*(rubber.mass/heat_transfer.convection2.nodes)); %q_dot_node = m_node*cp*deltaT -> deltaT=q_dot_node/(m_node*cp)
    end
    T_dot=T_dot+conv_tabl;
end

if (options.convection_for)
    conv_tabl=zeros(sim.nodes,1);
    for i = heat_transfer.convection1.node_start : (heat_transfer.convection1.node_start + heat_transfer.convection1.nodes)
        q_dot_node=heat_transfer.convection1.h*(heat_transfer.convection1.area/heat_transfer.convection1.nodes)*(heat_transfer.T_inf-P(i));%q_dot_node = h * A_node * (T-Tinf)
        conv_tabl(i,1)= q_dot_node/(rubber.cp*(rubber.mass/heat_transfer.convection1.nodes)); %q_dot_node = m_node*cp*deltaT
    end
    T_dot=T_dot+conv_tabl;
end

%if (options.conduction_ver)
%    cond_tabl=zeros(sim.nodes,1);
%    for i = heat_transfer.node_start1 : (heat_transfer.node_start1 + heat_transfer.nodes_cond1)
%        if (options.ver_QorT)
%            cond_tabl(i,1)=heat_transfer.Q_source/heat_transfer.nodes_cond1;
%        else
%            cond_tabl(i,1)= heat_transfer.T_source-P(i);
%            %Q2=heat_transfer.conduction(1,1)*rubber.k_conduction*(heat_transfer.T_source-P(1))/rubber.specific_length; % heat transfer from vertebrae to rubber
%        end
%    end
%    T_dot=T_dot+cond_tabl;
%end

%if (options.conduction_ver)
%    cond_tabl=zeros(sim.nodes,1);
%    for i = heat_transfer.conduction1.node_start : (heat_transfer.conduction1.node_start + heat_transfer.conduction1.nodes)
%        if (options.ver_QorT)
%            cond_tabl(i,1)=heat_transfer.Q_source/heat_transfer.conduction1.nodes;
%        else
%            cond_tabl(i,1)= heat_transfer.T_source-P(i); %!!! WRONG we cannot fix temperature in this way, the output of the table is T_dot/T_dot=Q, so what we would need to fix the temperature would be as much Q is needed to bring it at T, probably Q/T_dot ??
%            %Q2=heat_transfer.conduction(1,1)*rubber.k_conduction*(heat_transfer.T_source-P(1))/rubber.specific_length; % heat transfer from vertebrae to rubber
%        end
%    end
%    T_dot=T_dot+cond_tabl;
%end

%if (options.conduction_windshield)
%    cond_tabl=zeros(sim.nodes,1);
%    for i = heat_transfer.conduction2.node_start : (heat_transfer.conduction2.node_start + heat_transfer.conduction2.nodes)
%        
%        cond_tabl(i,1)= heat_transfer.T_windshield-P(i);%WRONG we cannot fix temperature in this way, the output of the table is T_dot/T_dot=Q, so what we would need to fix the temperature would be as much Q is needed to bring it at T, probably Q/T_dot (because the program multiplies by T_dot) ??
%        %Q2=heat_transfer.conduction(1,1)*rubber.k_conduction*(heat_transfer.T_source-P(1))/rubber.specific_length; % heat transfer from vertebrae to rubber
%        %Q=kA(T1-T2)/deltaX   for inside the boT_dot
%        %Q=hA(T1-T2)          convection
%        %T_dot=Ttarget-Tprevious to keep temp constant at a node
%    end
%    T_dot=T_dot+cond_tabl;
%end



if (options.conduction_ver) 
    if (heat_transfer.conduction1.mode) %fixing temperatures for vertebrae if we have constant temperature boundary
%condition
        for i = heat_transfer.conduction1.node_start : heat_transfer.conduction1.node_end
           T_dot(i,1)=0;
        end
    else
        for i = heat_transfer.conduction1.node_start : heat_transfer.conduction1.node_end
           q_dot_node = heat_transfer.conduction1.Q/heat_transfer.conduction1.nodes;
           T_dot(i,1)= q_dot_node/((rubber.mass/conduction1.nodes)*rubber.cp);
        end
    end
end
    
if (options.conduction_windshield) 
    if (heat_transfer.conduction2.mode) %fixing temperatures for vertebrae if we have constant temperature boundary
%condition
        for i = heat_transfer.conduction2.node_start : heat_transfer.conduction2.node_end
           T_dot(i,1)=0;
        end
    else % constant Q
        for i = heat_transfer.conduction2.node_start : heat_transfer.conduction2.node_end
           q_dot_node = heat_transfer.conduction2.Q/heat_transfer.conduction2.nodes; %%% !!! ERROR Q/T_dot=h A (T1-Tinf) and NOT Q =h A (T1-Tinf)
           T_dot(i,1)= q_dot_node/((rubber.mass/conduction2.nodes)*rubber.cp);
        end
    end
end



end

