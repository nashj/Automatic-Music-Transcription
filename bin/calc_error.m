function [Acc, E_tot, E_sub, E_miss, E_fa] = calc_error( true_pr, observed_pr, subset )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  TP=0;
  FP=0;
  FN=0;
  ETOT=0;
  ESUB=0;
  EMISS=0;
  EFA=0;
  for j =1:subset
    for i =1:size(true_pr,1)
      
          tl = true_pr(i,j);
          ol = observed_pr(i,j);
          
          if (tl==1 && ol==1)
              TP=TP+1;              
          elseif (tl==0 && ol ==1)
              FP=FP+1;
          elseif (tl==1 && ol ==0)
              FN=FN+1;
          end
    end      
    %2nd error measure
    N_ref = sum(true_pr(:,j)==1);
      
    N_sys = sum(observed_pr(:,j)==1);
    N_corr =   sum((true_pr(:,j)==1)+ (observed_pr(:,j)==1)==2);
    ETOT = ETOT+max(N_ref,N_sys)-N_corr; 
    ESUB = ESUB+min(N_ref,N_sys)-N_corr;
    EMISS = EMISS+max(0,(N_ref-N_sys));
    EFA = EFA+max(0,(N_sys-N_ref));
  end
  Norm = sum(sum(true_pr(:,1:subset)==1));
  Acc=(TP)/(TP+FP+FN); %0.4689 for 50, .54 for 100
  E_tot = ETOT/Norm; % number of frames that are actually on
  E_sub = ESUB/Norm;
  E_miss = EMISS/Norm;
  E_fa = EFA/Norm;

end

