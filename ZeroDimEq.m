

function dP = ZeroDimEq(t,P,rubber,ice,heat_transfer,options)
%setting all to zero to avoid error when commenting out one of the heat
%tranfer equations
Q1=0;
Q2=0;
Q3=0;
Q4=0;
Q5=0;
dP1=0; %Temperature rubber [C]
dP2=0; %Temperature ice [C]
dP3=0; %latent heat remaining ice [J]
dP4=0; %mass of ice [kg]

if (options.convection_nat)
    Q1=heat_transfer.convection2.h*heat_transfer.convection2.area*(heat_transfer.T_inf-P(1)); % heat transfer from rubber to air by natural convection
end

if (options.conduction_ver)
    if (options.ver_QorT)
        Q2=heat_transfer.Q_source;
    else
        Q2=heat_transfer.conduction1.area*rubber.k_conduction*(heat_transfer.T_source-P(1))/rubber.specific_length; % heat transfer from vertebrae to rubber
    end
end

if (options.convection_for)
    Q3=heat_transfer.convection1.h*heat_transfer.convection1.area*(heat_transfer.T_inf-P(1));% heat transfer from rubber to air by forced convection
end

if (options.conduction_windshield)
    Q4=heat_transfer.conduction2.area*rubber.k_conduction*(heat_transfer.T_windshield-P(1))/rubber.specific_length; % heat transfer from rubber to windshield
end

%ice script, can add dynamic mass as the ice is melting
if (ice.status==1) 
    Q5=ice.contact_area*rubber.k_conduction*(P(1)-P(2))/rubber.specific_length;% ice. Q direction from rubber to ice
    
    if (P(2) < 0) % if the ice is under melting temperature the temperature falls with respect to cp and if its at zero then the latent heat falls only and temp stays the same, also mass
        dP2= Q5/(ice.mass_init*ice.cp*1000); % change in temperature of ice
        dP3= 0 ;
        dP4=0;
    elseif (P(3)> 0) % if latent heat calories are not depleted , still ice has not melted, the heat going to ice is used to melt it always at 0 degrees. 
        dP3= -Q5;%/(ice.mass_init*ice.cp*1000); 
        dP2=0;
        dP4 = -(Q5/ice.latent_calories)*ice.mass_init;
    else % if the ice is melt the heat transfer stops
        Q5=0;
        dP2=0;
        dP3=0;
        dP4=0;
       % ice.status=false;
    end
end
    
        
        
sum = Q1+Q2+Q3+Q4-Q5;
dP1= sum/(rubber.mass*rubber.cp*1000) ; % delta T of rubber

% (Q1 +Q2 ... )1/(m*cp) *dt = dT

dP(1,1) = dP1; %dP1:rubber temperature 
dP(2,1) = dP2; %dP2, ice temperature 
dP(3,1) = dP3; %dP3, latent heat of fussion
dP(4,1) = dP4; %dP4, mass of ice

% m*cp*dT/dt = h*Aconv*(T-Tinf) + k*Acond*(Tsource-T)