% The code is associated with the following paper:
% 
% P.Zhu, Q.Hu . Rule Extraction from Support Vector Machines based on
% Consistent Region Covering Reduction. 
% For further information, please contact: cspzhu@comp.polyu.edu.hk

% ----------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is here
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%----------------------------------------------------------------------
% For the usage of this package, please refer to the following instrctions:
%For LSVM
kernel='rbf';
load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'PCM',kernel)
load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'VM',kernel)

load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'PCM',kernel)
load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'VM',kernel)

%For RBFSVM
kernel='linear';
load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'PCM',kernel)
load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'VM',kernel)

load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'PCM',kernel)
load wine
[accu_mean,accu_std,num_rule]=accu_para(wine, 'CRCRT', 'VM',kernel)

