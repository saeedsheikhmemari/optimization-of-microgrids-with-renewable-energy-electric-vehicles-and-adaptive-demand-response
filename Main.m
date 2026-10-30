%% P2P Energy Community With Four Disel Distributed Generation

clc
clear
close all
%%

S_PV=xlsread('Sobhani_Data',1,'A1:A48');

Solar=S_PV(1:2:48)+S_PV(2:2:48);

dem      = xlsread('Saeid_Work1_Data',1,'A1:AN24');

dee      = xlsread('Saeid_Work1_Data',1,'A1:AN24');

dem=[dem(:,1:12)*1 dem(:,13:30) dem(:,31:36)/10 dem(:,37:end)] ; 

Pg       = xlsread('9',3,'B2:B49');

Pg=Pg(1:2:48)+Pg(2:2:48);

Pg=Pg';

Pg=[Pg(1:6)-10  Pg(7:end)];

Pg=Pg';

Solar   = xlsread('Saeid_Work1_Data',2,'A1:AN24');

Solar=Solar/3;

Wind    = xlsread('Saeid_Work1_Data',3,'A1:AN24');
Wind=Wind;
res     = Wind+Solar;
res=res/1;

alpha   = xlsread('9',6,'B4');
beta    = xlsread('9',6,'B5');
Sl      = xlsread('9',6,'B3');
S1_EV   = xlsread('9',6,'B3');
Su      = xlsread('9',6,'B2');

eta_ch  = xlsread('9',6,'B6');
eta_dis = xlsread('9',6,'B7');

Nt      = length(dem(:,1));
Nh      = length(dem(1,:));
psip2p  = 1-0.1;

BatteryPlace      =[0 0 0 0 0 0 0 0 0 0    1 1 1 1 1 1 1 1 1 1    1 1 1 1 1 1 1 1 1 1    0 0 0 0 0 0  0 0 0 0 ];          % Battery location
BatteryPlace2     =[0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0    1 1 1 1 1 1 1 1 1 1    0 0 0 0 0 0  0 0 0 0 ];          % houses Ev's Location
% BatteryPlace3   =[0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0    0 0 0 0 0 0 0 0 0 0    0 1 1 1 1 1 ];          % Ev  Station 

Sp0         =0*ones(1,numel(BatteryPlace)) ;           % Initial battery state
Spp0        =BatteryPlace.*Sp0;
S0          =Spp0(1,BatteryPlace==1);

Sp0_EV      =0*ones(1,numel(BatteryPlace2));          % Initial battery state
Spp0_EV     =BatteryPlace2.*Sp0_EV;
S0_EV       =Spp0_EV(1,BatteryPlace2==1);


% Sp0_EV_S      =0*ones(1,numel(BatteryPlace3));         % Initial battery state
% Spp0_EV_S     =BatteryPlace3.*Sp0_EV_S;
% S0_EV_S       =Spp0_EV_S(1,BatteryPlace3==1);

%%

Grid_cons=dem-(res);

 alpha=(dem(:,11)-res(:,11))./(dem(:,11)+res(:,11));

beta=0.04./(0.04+(Pg/20));

t=linspace(1,size(dem,1),size(dem,1));

%% Buying Price

for i=1:length(t)

if alpha(i)>=0
P_buy(i)=((Pg(i)-15)/2)*((2-beta(i))*exp(2*alpha(i))+beta(i)*exp(-2*alpha(i)))/(2*(exp(2*alpha(i))+exp(-alpha(i))))+13;

elseif  alpha(i)<0

P_buy(i)=((Pg(i)-15)/2)*(1+(beta(i))*exp(2*alpha(i))+(1-beta(i))*exp(-2*alpha(i)))/((exp(2*alpha(i))+exp(-2*alpha(i))))+13;
end

end

% Sell Price
for i=1:length(t)

if alpha(i)>=0
P_Sell(i)=((Pg(i)-12)/2)*(1+(beta(i))*exp(2*alpha(i))+(1-beta(i))*exp(-2*alpha(i)))/((exp(2*alpha(i))+exp(-2*alpha(i))))+12;

elseif  alpha(i)<0

P_Sell(i)=((Pg(i)-12)/2)*((2-beta(i))*exp(2*alpha(i))+beta(i)*exp(-2*alpha(i)))/(2*(exp(2*alpha(i))+exp(-alpha(i))))+12;
end

end

%% Solving The Problem
[linsol,fval]=func(dem,Pg,P_buy,P_Sell,alpha,beta,Sl,S1_EV,Su,eta_ch,eta_dis,Nt,res,BatteryPlace,BatteryPlace2,S0,S0_EV,psip2p,Grid_cons) 

t=linspace(1,Nt,Nt);

% for i=1:Nh
%     for j=1:Nt
% 
%     I(j,i)=sum(linsol.Ip2p(j,i,:));    % Eq4  Trade Constraints
%     X(j,i)=sum(linsol.Xp2p(j,i,:));    % Eq2  Trade Constraints
% 
%     end
% end
%% Results

BC_BD_demand=[linsol.BC(:,1) linsol.BD(:,1)  dem(:,11) res(:,11) linsol.DG1_1(:,11)]
EVC_EVD_demand=[linsol.BC(:,6) linsol.BD(:,6) linsol.BC_EV(:,2) linsol.BD_EV(:,2) Grid_cons(:,22) linsol.DG1_2(:,4)]
BC_BD__EVC_EVD_demand=[linsol.BC(:,5) linsol.BD(:,5) linsol.BC_EV(:,1) linsol.BD_EV(:,1) dem(:,21) res(:,21) linsol.DG1_2(:,3)] 
% EVCs_EVDs_demand=[linsol.BC_EV_S(:,1) linsol.BD_EV_S(:,1) I(:,32) X(:,32) dem(:,32) res(:,32) linsol.G(:,32)]


%% Total Demand and RES
Demand=sum(sum(dem))
RES=sum(sum(res))

%% Plots
Total_Solar=sum(Solar);
Total_Wind=sum(Wind);
Total_Grid_Consumption_G1=sum(linsol.DG1_1);
Total_Grid_Consumption_G2=sum(linsol.DG1_2);
Total_EVC=sum(linsol.BC_EV);
Total_EVD=sum(linsol.BD_EV);
Total_BD=sum(linsol.BD);
Total_BC=sum(linsol.BC);
% Total_Traid=Total_Traid_Buy+Total_Traid_Sell;

% Demand_Response=sum(Total_EVD+Total_BD+Total_Grid_Consumption+sum(res)+Total_Traid_Buy)-(sum(Total_Demand)+sum(Total_Traid_Sell))
% Total_Response=(Total_EVD+Total_BD+Total_Grid_Consumption+sum(res,2)+Total_Traid_Buy);


%% Numarical Rresults
 %[sum(Total_BC) sum(Total_BD) sum(Total_Traid_Buy)  sum(Total_Traid_Sell) sum(Total_Demand)  sum(Total_Grid_Consumption) ]

 % Numarical_Result=([sum(sum(Grid_cons,2)) sum(sum(linsol.BC,2)) sum(sum(linsol.BD,2)) sum(sum(linsol.BC_EV,2)) sum(sum(linsol.BD_EV,2)) sum(sum(I,2)) sum(sum(X,2)) sum(sum(linsol.G,2))]);




dataa_BD=(sum(linsol.BD));

dataa_BC=(sum(linsol.BC));

dataa_BC1=[ 0 0 0 0 0 0 0 0 0 0  dataa_BC(1) dataa_BC(2)  dataa_BC(3) dataa_BC(4)  dataa_BC(5) dataa_BC(6) dataa_BC(7)   dataa_BC(8) dataa_BC(9) dataa_BC(10)...
    dataa_BC(11) dataa_BC(12) dataa_BC(13) dataa_BC(14) dataa_BC(15) dataa_BC(16) dataa_BC(17) dataa_BC(18) dataa_BC(19) dataa_BC(20)  0 0 0 0 0 0  0 0 0 0 ];
dataa_BD1=[ 0 0 0 0 0 0 0 0 0 0  dataa_BD(1) dataa_BD(2)  dataa_BD(3) dataa_BD(4)  dataa_BD(5) dataa_BD(6) dataa_BD(7)   dataa_BD(8) dataa_BD(9) dataa_BD(10)...
    dataa_BD(11) dataa_BD(12) dataa_BD(13) dataa_BD(14) dataa_BD(15) dataa_BD(16) dataa_BD(17) dataa_BD(18) dataa_BD(19) dataa_BD(20)  0 0 0 0 0 0  0 0 0 0 ];



dataa_BD_EV=(sum(linsol.BD_EV));

dataa_BC_EV=(sum(linsol.BC_EV));

dataa_BC_EV1=[0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0    dataa_BC_EV(1) dataa_BC_EV(2) dataa_BC_EV(3) dataa_BC_EV(4) dataa_BC_EV(5) dataa_BC_EV(6) dataa_BC_EV(7) dataa_BC_EV(8) dataa_BC_EV(9) dataa_BC_EV(10)  0 0 0 0 0 0  0 0 0 0];
dataa_BD_EV1=[0 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0    dataa_BD_EV(1) dataa_BD_EV(2) dataa_BD_EV(3) dataa_BD_EV(4) dataa_BD_EV(5) dataa_BD_EV(6) dataa_BD_EV(7) dataa_BD_EV(8) dataa_BD_EV(9) dataa_BD_EV(10)  0 0 0 0 0 0  0 0 0 0];



figure
bar(sum(linsol.G)+sum(linsol.DG1_1) +sum(linsol.DG1_2)+sum(linsol.DG1_3)+dataa_BD_EV1+dataa_BD1+sum(Solar)+sum(Wind),'LineWidth',2)
 hold on
bar(sum(linsol.G)+sum(linsol.DG1_1) +sum(linsol.DG1_2)+sum(linsol.DG1_3)+dataa_BD_EV1+dataa_BD1+sum(Solar)+sum(Wind))
bar(sum(linsol.G)+sum(linsol.DG1_1) +sum(linsol.DG1_2)+sum(linsol.DG1_3)+dataa_BD_EV1+dataa_BD1+sum(Solar))
bar(sum(linsol.G)+sum(linsol.DG1_1) +sum(linsol.DG1_2)+sum(linsol.DG1_3)+dataa_BD_EV1+dataa_BD1)
bar(sum(linsol.G)+sum(linsol.DG1_1) +sum(linsol.DG1_2)+sum(linsol.DG1_3)+dataa_BD_EV1)
bar(sum(linsol.G)+sum(linsol.DG1_1) +sum(linsol.DG1_2)+sum(linsol.DG1_3))
bar(sum(linsol.G)+sum(linsol.DG1_1) +sum(linsol.DG1_2))
bar(sum(linsol.G)+sum(linsol.DG1_1))
bar(sum(linsol.G),'k')
legend('Demand','Wind','Solar','BESS','EV Discharge','DG3','DG2','DG1','Main Utility')
title('Homes')
xlabel ('Homes')
ylabel('KWh')
propedit

figure
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2) +sum(linsol.DG1_2,2)+sum(linsol.DG1_3,2)+sum(linsol.BD_EV,2)+sum(linsol.BD,2)+sum(Solar,2)+sum(Wind,2),'LineWidth',3)
  hold on
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2) +sum(linsol.DG1_2,2)+sum(linsol.DG1_3,2)+sum(linsol.BD_EV,2)+sum(linsol.BD,2)+sum(Solar,2)+sum(Wind,2))
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2) +sum(linsol.DG1_2,2)+sum(linsol.DG1_3,2)+sum(linsol.BD_EV,2)+sum(linsol.BD,2)+sum(Solar,2))
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2) +sum(linsol.DG1_2,2)+sum(linsol.DG1_3,2)+sum(linsol.BD_EV,2)+sum(linsol.BD,2))
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2) +sum(linsol.DG1_2,2)+sum(linsol.DG1_3,2)+sum(linsol.BD_EV,2))
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2) +sum(linsol.DG1_2,2)+sum(linsol.DG1_3,2))
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2) +sum(linsol.DG1_2,2))
bar(sum(linsol.G,2)+sum(linsol.DG1_1,2))
bar(sum(linsol.G,2),'k')
legend('demand','Wind','Solar','BESS','EV','DG3','DG2','DG1','Main Utility')
xlabel ('Time (h)')
ylabel('KWh')
propedit

for i=1:length(t)
if alpha(i)>=0
f1(i)=exp(-2*alpha(i));
else
    f1(i)=Pg(i);
end
end

figure
bar(sum(linsol.BC_EV,2))
hold on
bar(sum(linsol.BD_EV,2))
legend('EV charge','EV discharge')

%% Numerical Results

BCC=(linsol.BC);
SOC_BESS=linsol.S;
SOC_EV=linsol.S_EV;

Particip11=[linsol.BC(:,1) linsol.BD(:,1) linsol.G(:,11) linsol.DG1_1(:,11) linsol.DG1_2(:,11) linsol.DG1_3(:,11) res(:,11) dem(:,11)]

Particip21=[linsol.BC(:,11) linsol.BD(:,11) linsol.BD_EV(:,1) linsol.G(:,21) linsol.DG1_1(:,21) linsol.DG1_2(:,21) linsol.DG1_3(:,21) res(:,21) dem(:,21)]

Total_demand=sum(sum(dem))+173+2.6490
Grid_Cons=sum(sum(linsol.G))
Wind_1=sum(sum(Wind))
Solar_1=sum(sum(Solar))
BESS=sum(sum(linsol.BD))
EV=sum(sum(linsol.BD_EV))
Disel_1=sum(sum(linsol.DG1_1))
Disel_2=sum(sum(linsol.DG1_2))
Disel_3=sum(sum(linsol.DG1_3))

sum(Grid_Cons+Wind_1+Solar_1+BESS+EV+Disel_1+Disel_2+Disel_3)




