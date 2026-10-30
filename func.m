function [linsol,fval]=func(dem,Pg,P_buy,P_Sell,alpha,beta,Sl,S1_EV,Su,eta_ch,eta_dis,Nt,res,BatteryPlace,BatteryPlace2,S0,S0_EV,psip2p,Grid_cons)

Nh=length(dem(1,:));

%% defining variables
aa=size(dem);
G=optimvar('G',aa(1),aa(2),'LowerBound',0);
DG1_1=optimvar('DG1_1',aa(1),aa(2),'LowerBound',0,'UpperBound',2);
DG1_2=optimvar('DG1_2',aa(1),aa(2),'LowerBound',0,'UpperBound',2);
DG1_3=optimvar('DG1_3',aa(1),aa(2),'LowerBound',0,'UpperBound',2);
% DG1_4=optimvar('DG1_4',aa(1),aa(2),'LowerBound',0,'UpperBound',2);

BD=optimvar('BD',Nt,sum(BatteryPlace),'LowerBound',0,'UpperBound',0.5);
BC=optimvar('BC',Nt,sum(BatteryPlace),'LowerBound',0,'UpperBound',0.5); 

BD_EV=optimvar('BD_EV',Nt,sum(BatteryPlace2),'LowerBound',0,'UpperBound',0.5);
BC_EV=optimvar('BC_EV',Nt,sum(BatteryPlace2),'LowerBound',0,'UpperBound',0.5); 

% BD_EV_S=optimvar('BD_EV_S',Nt,sum(BatteryPlace3),'LowerBound',0,'UpperBound',7);
% BC_EV_S=optimvar('BC_EV_S',Nt,sum(BatteryPlace3),'LowerBound',0,'UpperBound',7); 

S=optimvar('S',Nt,sum(BatteryPlace),'LowerBound',0,'UpperBound',4); % Privet Batteries Storage
S_EV=optimvar('S_EV',Nt,sum(BatteryPlace2),'LowerBound',0,'UpperBound',6); % Privet Batteries Storage
% S_EV_S=optimvar('SE_V_S',Nt,sum(BatteryPlace3),'LowerBound',0,'UpperBound',80); % Privet Batteries Storage

% Ip2p=optimvar('Ip2p',Nt,Nh,Nh-1,'LowerBound',0,'UpperBound',5); % P  
% Xp2p=optimvar('Xp2p',Nt,Nh,Nh-1,'LowerBound',0,'UpperBound',5); % S 



% Objective function
   % Equation 1
    linprob=optimproblem('Objective',sum(Pg' *G(:,1))+ sum(0.4*Pg'*DG1_1(:,1))+ sum(0.4*Pg'*DG1_2(:,1))+ sum(0.9*Pg'*DG1_3(:,1)));
    linprob.Objective=linprob.Objective;

k=0;
Kb=10;
kEV=0;

for i=2:Nh
    if BatteryPlace(i)==1 && BatteryPlace2(i)==0   %zone 2
          k=k+1;
          
          for j =1:Nt
              if j>11 && j<20
               linprob.Objective=[ linprob.Objective; sum(Pg(j) *G(j,i))+sum(0.9*Pg(j) * DG1_1(j,i))+sum(0.9*Pg(j) * DG1_2(j,i))+sum(0.4*Pg(j) * DG1_3(j,i)) + sum(15'  *(BC(j,k)))-sum(13 *(BD(j,k)))];
                else
                 linprob.Objective=[ linprob.Objective; sum(Pg(j) *G(j,i))  + sum(15'  *(BC(j,k)))-sum(13 *(BD(j,k)))];
   
              end
             
          end
     
     end
 
 
    if BatteryPlace(i)==1 && BatteryPlace2(i)==1  % Zone 3
                     kEV=kEV+1;
                     Kb=Kb+1;
                     for j=1:Nt
                         if j>11 && j<20
                        linprob.Objective=[ linprob.Objective; sum(Pg(j) *G(j,i))+sum(0.9*Pg(j) * DG1_1(j,i))+sum(0.9*Pg(j) * DG1_2(j,i))+sum(0.9*Pg(j) * DG1_3(j,i))  + sum(16'* BC_EV(j,kEV))+sum(15'  *(BC(j,Kb)))-sum(14 *BD_EV(j,kEV))-sum(13  *(BD(j,Kb)))];
                          else
                          linprob.Objective=[ linprob.Objective; sum(Pg(j) *G(j,i)) + sum(16'* BC_EV(j,kEV))+sum(15*(BC(j,Kb)))-sum(14 *BD_EV(j,kEV))-sum(13*(BD(j,Kb)))];

                          end
                     end                
    end
             

    if BatteryPlace2(i)==0 && BatteryPlace(i)==0  % Zone 1

                     for j=1:Nt
                         if j>11 && j<20
                          linprob.Objective=[linprob.Objective; sum(Pg(j) *G(j,i))+sum((0.4*Pg(j) *DG1_1(j,i)))+sum(0.4*Pg(j) * DG1_2(j,i))+sum(0.9*Pg(j) * DG1_3(j,i))] ;
                         else
                          linprob.Objective=[linprob.Objective; sum(Pg(j) *G(j,i))] ;
   
                          end
                         
                      end

    end

end


 linprob.Objective=sum(linprob.Objective);


%% Constraints
linprob.Constraints.eq11=[];
for j=1:Nt
linprob.Constraints.eq11=[linprob.Constraints.eq11;BD_EV(j,:)<=sum(BC_EV(1:j-1,:))-sum(BD_EV(1:j-1,:))];
end



linprob.Constraints.EVBC=[];


for j=1:Nt

linprob.Constraints.EVBC=[linprob.Constraints.EVBC;BD(j,:)<=sum(BC(1:j-1,:))-sum(BD(1:j-1,:))];


end
% 
% linprob.Constraints.EVBC_S=[];
% for j=1:Nt
% 
% linprob.Constraints.EVBC_S=[linprob.Constraints.EVBC_S;BD_EV_S(j,:)<=sum(BC_EV_S(1:j-1,:))-sum(BD_EV_S(1:j-1,:))];
% 
% 
% end


linprob.Constraints.EVBC=[]; % EV Battery Charge Constraints
for j=1:Nt
    if j<=7
      linprob.Constraints.EVBC=[linprob.Constraints.EVBC;BC_EV(j,:)==unifrnd(0.4,0.5,1,size(BC_EV,2))];
    end
     if j>7 && j<=8
      linprob.Constraints.EVBC=[linprob.Constraints.EVBC;BC_EV(j,:)==BC_EV(j,:)];
    end
    if (8<j) && (j<17)
      linprob.Constraints.EVBC=[linprob.Constraints.EVBC;BC_EV(j,:)==0];
    end
    if j>=18
         linprob.Constraints.EVBC=[linprob.Constraints.EVBC;BC_EV(j,:)==0];

    end
end

linprob.Constraints.EVBD=[]; % EV Battery Discharge Constraints

for j=1:Nt
    if j<=16

      linprob.Constraints.EVBD=[linprob.Constraints.EVBD;BD_EV(j,:)==0];
    

    else
         linprob.Constraints.EVBD=[linprob.Constraints.EVBD;BD_EV(j,:)==BD_EV(j,:)];

    end
end


linprob.Constraints.SOC = S(1,:)==S0+1*BC(1,:)-(1/eta_dis)*BD(1,:); % equation (10) BAttery SOC
for i=2:Nt
linprob.Constraints.SOC = [linprob.Constraints.SOC; S(i,:)==S(i-1,:)+1*BC(i,:)-(1/eta_dis)*BD(i,:)];
end

linprob.Constraints.SOE = S_EV(1,:)==(S0_EV+BC_EV(1,:)-(1/eta_dis)*BD_EV(1,:)); % equation (10) EV SOC
for i=2:Nt

   if i<8
linprob.Constraints.SOE = [linprob.Constraints.SOE; S_EV(i,:)==S_EV(i-1,:)+(1*BC_EV(i,:))-(1/eta_dis)*BD_EV(i,:)];
   end
    if (8<i) && (i<=17)
        linprob.Constraints.SOE = [linprob.Constraints.SOE; S_EV(i,:)==S_EV(i-1,:)+(1*BC_EV(i,:))];
    end
   if i>=18

    linprob.Constraints.SOE = [linprob.Constraints.SOE; S_EV(i,:)==S_EV(i-1,:)+(1*BC_EV(i,:))-(1/eta_dis)*BD_EV(i,:)];
  end

end

% for i=1:Nh
%     for j=1:Nt
%     I(j,i)=sum(Ip2p(j,i,:));    % Eq4  Trade Constraints
%     X(j,i)=sum(Xp2p(j,i,:));    % Eq2  Trade Constraints
%     end
% end


% IXpind=zeros(Nh-1,Nh);
% for i=1:length(IXpind(1,:))
%     for j=1:length(IXpind(:,1))
%         if i<=j
%             IXpind(j,i)=j+1;
%         else
%             IXpind(j,i)=j;
%         end
%     end
% end     

% linprob.Constraints.eq3 = [];   % equation 3
% for i=1:Nh
%     for j=1:Nt
%         in=IXpind(j,i);
%         jn=IXpind(:,in)==i;
% 
% 
%           linprob.Constraints.eq3 = [linprob.Constraints.eq3; Ip2p(:,i,j)==psip2p*Xp2p(:,in,jn)];
% 
%    end

% end


linprob.Constraints.eq1 = [];   % Equation 1

k3=0;
k4=0;
k5=10;

for i=1:Nh
    if BatteryPlace(i)==1 && BatteryPlace2(i)==0 %Zone 2
      k3=k3+1;

               for j=1:Nt
                   if j>11 && j<20
                      linprob.Constraints.eq1=[linprob.Constraints.eq1,res(j,i)+G(j,i)+DG1_1(j,i)+DG1_2(j,i)+DG1_3(j,i)+BD(j,k3)>=dem(j,i)+BC(j,k3)];
                   else
                       linprob.Constraints.eq1=[linprob.Constraints.eq1,res(j,i)+G(j,i)+BD(j,k3)>=dem(j,i)+BC(j,k3)];
                   end
                end     

    elseif BatteryPlace(i)==1 && BatteryPlace2(i)==1 % Zone 3
        k4=k4+1;
        k5=k5+1;

                      for j=1:Nt
                          if j>11 && j<20
                           linprob.Constraints.eq1=[linprob.Constraints.eq1,res(j,i)+BD_EV(j,k4)+G(j,i)+DG1_1(j,i)+DG1_2(j,i)+DG1_3(j,i)+BD(j,k5)+BD_EV(j,k4)>=dem(j,i)+BC(j,k5)+BC_EV(j,k4)];
                          else
                           linprob.Constraints.eq1=[linprob.Constraints.eq1,res(j,i)+BD_EV(j,k4)+G(j,i)+BD(j,k5)+BD_EV(j,k4)>=dem(j,i)+BC(j,k5)+BC_EV(j,k4)];
                           
                          end
                      end

    elseif BatteryPlace(i)==0 && BatteryPlace2(i)==0 % Zone 1
                       for j=1:Nt
                           if j>11 && j<21
                     linprob.Constraints.eq1=[linprob.Constraints.eq1,res(j,i)+G(j,i)+DG1_1(j,i)+DG1_2(j,i)+DG1_3(j,i)>=dem(j,i)];
                           else
                     linprob.Constraints.eq1=[linprob.Constraints.eq1,res(j,i)+G(j,i)>=dem(j,i)];

                           end
                       end
                    
     end
end
% linprob.Constraints.eq5 = psip2p*sum(X,2)==sum(I,2); % equation 5
%% Evaluation
[linsol,fval] = solve(linprob);

    end


