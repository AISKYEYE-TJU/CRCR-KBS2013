function [rulenum,acc_mean,acc_std]=crossvalidate(data,fold,method,type,para,kernel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%data is all data with decision
%fold is the number of folds in cross validation
%method is the flag to specify the classification algorithm. 
%type is the criterion for rule pruning(VM or PCM)
%kernel is the kernel type(linear or rbf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%addpath 'D:\Program Files\MATLAB\R2008a\work\osu_svm3.00'
Gamma=para.gamma;
dell=para.dell;
[row column]=size(data);
for i=1:column-1
data(:,i)=(data(:,i)-min(data(:,i)))/(max(data(:,i))-min(data(:,i)));
end

label=data(:,column);
classnum=max(label);
start1=1;
for i=1:classnum
    [a,b]=find(label==i);
    datai=data(a,:);      %select the i class data 
    [rr1,cc1]=size(datai);
    start1=1;
    %%%%%%%%%part the i class in (fold)%%%%%%%%%%%%%%%%%%%%%
    for j=1:fold-1
        a1=round(length(a)/fold);
        a2=a1-1;
        %fun1=strcat('x*',num2str(a1),'+y*',num2str(a2),'=',num2str(rr1)); 
        %fun2=strcat('x+y=',num2str(fold)); 
        %[x,y]=solve(fun1,fun2) 
        %[x,y] = solve('x*a1+a2*y=rr1','x+y=fold')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        A=[a1 a2;1 1];
        b=[rr1 fold]';
        x=A\b;
        if (j<x(1)+1)
            everynum=a1;
        else
            everynum=a2;
        end
        start2=start1+everynum-1;       
        eval(['data' num2str(i) num2str(j) '=datai([start1:start2],:);']);
        start1=start2+1;
    end
    eval(['data' num2str(i) num2str(fold) '=datai([start1:length(a)],:);']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:fold
    eval(['part' num2str(j) '=[];']);
    for i=1:classnum
      eval(['part' num2str(j) '=[part' num2str(j) ';data' num2str(i) num2str(j) '];']);
    end   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:fold
    Samples=[];
     Labels=[];
     testS=[];
     testL=[];
    for i=1:fold
        
        if (i~=j)
            eval(['Samples=[Samples;part' num2str(i) '(:,1:column-1)];'])
            eval(['Labels=[Labels;part' num2str(i) '(:,column)];'])
        end
    end
    eval(['testS=part' num2str(j) '(:,1:column-1);'])
    eval(['testL=part' num2str(j) '(:,column);'])
    switch method
        case 'CRCRT'
            training=[Samples,Labels];
            [~,num1]=rulelearning(training,training,Gamma,Labels,dell,type,kernel);
            [ClassRate,number,]=rulelearning_test(training,testS,Gamma,testL,dell,num1,type,kernel);
        case 'CRCRE'
            training=[Samples,Labels];
            [ClassRate,number]=rulelearning(training,testS,Gamma,testL,dell,type,kernel);
        case 'RBFSVM'
            [AlphaY, SVs, Bias, Parameters, nSV, nLabel] =RbfSVC(Samples', Labels', Gamma);        
            [ClassRate1, DecisionValue, Ns, ConfMatrix, PreLabels]= SVMTest(testS', testL', AlphaY, SVs, Bias,Parameters, nSV, nLabel);  
             number=0;
        case 'LSVM'
             [AlphaY, SVs, Bias, Parameters, nSV, nLabel] =LinearSVC(Samples', Labels');
             [ClassRate, DecisionValue, Ns, ConfMatrix, PreLabels]= SVMTest(testS', testL', AlphaY, SVs, Bias,Parameters, nSV, nLabel);     
             number=0;
    end
    accu_m(j)=ClassRate;  
    numrule(j)=number;
end
acc_mean=mean(accu_m);
acc_std=std(accu_m);
rulenum=mean(numrule);