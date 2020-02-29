function   [accu_mean,accu_std,num_rule]=accu_para(data,method,type,kernel)
%Input:
% data: n*m matrix n samples and m featues the last column is the label
% method: CRCRT and CRCRE means rule pruning is done on the training set
% and test set respectively
% type:  the criterion for rule pruning

%Output:
% accu_mean: the accuracy
% accu_std : the variance of accuracy 
% num_rule : the number of rules
a(1:10)=0.1*[1:10];
a(11:19)=[2:10];
dell=2:3;

if strcmp(kernel, 'rbf')
for i=1:19
    for j=1:2
    para.gamma=a(i);
    para.dell=dell(j);
    [num(i,j),acc_mean(i,j),acc_std(i,j)]=crossvalidate(data,10,method,type,para,kernel);
    end
end
[value1,index1]=max(acc_mean);
[value2,index2]=max(value1);

accu_mean=acc_mean(index1(index2),index2);
accu_std=acc_std(index1(index2),index2);
num_rule=num(index1(index2),index2);
elseif strcmp(kernel, 'linear')
    for k=1:2
    para.gamma=a(1);
    para.dell=dell(k);
    [num(k),acc_mean(k),acc_std(k)]=crossvalidate(data,10,method,type,para,kernel);
    end
    [value,index]=max(acc_mean);
    accu_mean=acc_mean(index);
    accu_std=acc_std(index);
    num_rule=num(index);
    
end
