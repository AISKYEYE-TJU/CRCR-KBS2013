function     [proto,cover,numb]=extraction_coveringrule(training,Gamma,dell,type,kernel)
% This function is the consistent region covering reduction (CRCR)
% In this function, given the training set, a set of rules is extracted
% from the SVM.
% Inputs:
% training: n*m matrix n samples and m features ;
% Gamma:    kernel parameter
% dell: if number of samples covered by a rule is less than dell, then deleted it;
% Outputs:
% proto: the center of the learned rules
% cover: the size of the learned rules 
% number:the number of covered samples in the consistent region

%% svm training
    [row,column]=size(training);
    if strcmp(kernel, 'linear')
    [AlphaY, SVs, Bias, Parameters, nSV, nLabel] = LinearSVC(training(:,[1:(column-1)])',training(:,column)');
    elseif strcmp(kernel, 'rbf')
    [AlphaY, SVs, Bias, Parameters, nSV, nLabel] = RbfSVC(training(:,[1:(column-1)])',training(:,column)', Gamma);% learnig support vectors 
    end
    [column1,row1]=size(SVs);
    for i=1:row
            %compute the distance between arbitary samples in the training set
            distance(i,:)=sqrt(sum((repmat(training(i,1:(column-1)),row,1)-training(:,1:(column-1))).^2, 2));
            %compute the distance between samples and SVs
            distance1(i,:)=sqrt(sum((repmat(training(i,1:(column-1)),row1,1)-SVs').^2, 2));
    end
    distance4=distance;   
%% covering generation      
    [row2,column2]=size(nLabel);
    num_SVs(1)=1;
    for i=1:column2
        num_SVs(i+1)=sum(nSV(1:i))+1;
    end  
    for i=1:row
        [m1,n1]=min(distance1(i,num_SVs(training(i,column)):(num_SVs(training(i,column)+1)-1)));
        RADIUS(i)=m1;
    end
%==========================================================================
    ruleset=cell(row,1);
    for i=1:row
        index4=find(distance4(i,:)<=RADIUS(i));
        ruleset{i,1}=index4;
        num(i)=length(index4);
        index44=find(training(index4,column)==training(i,column));
        core(i)=length(index4)-length(index44);
    end
    
%% covering reduction
k=0;

num3=num;
num(find(core~=0))=0;

num1=num;
num(find(num1<dell))=0;

if ~isempty(num)  
    num2=num;
else
     num2=num3;
end


ra=RADIUS;
lab=[];
if strcmp(type,'VM')         % volume maximization  is used
           while(max(ra)~=0)
             [m,n]=sort(-ra);
             temp=ruleset{n(1),1};
             ra(temp)=0;
             k=k+1;
             lab(k)=n(1);
             numb(k)=length(temp);
           end
elseif strcmp(type,'PCM') % point coverage  maximization  is used
          while(max(num2)~=0)
             [m,n]=sort(-num2);
             temp=ruleset{n(1),1};
             num2(temp)=0;
             k=k+1;
             lab(k)=n(1);
             numb(k)=length(temp);
          end
end
% to avoid the case that the rule set is empty  
if isempty(lab)
    proto=training;
    cover=RADIUS;     
    numb=cover;
else
proto=training(lab,:);
cover=RADIUS(lab);      
end