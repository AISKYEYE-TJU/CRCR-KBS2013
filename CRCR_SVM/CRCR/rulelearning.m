function  [ClassRate,num1,label]=rulelearning(training,testS,Gamma,testL,dell,type,kernel)
% This function is used for rule extraction from SVM. 
% The number of rules is not given.

% Inputs:
% training: trainig samples 
% testS:test samples 
% testL:label of test set
% number:the number of seleted rules 

% Outputs:
% ClassRate: the classification accuracy on the test set
% num1: the number of selected rules 
% label:the ouput of the test samples  

%% rule extraction 
[proto,cover,numb]=extraction_coveringrule(training,Gamma,dell,type,kernel);
%% classfication 
if strcmp(type,'VM')
[m,n]=sort(1-cover);
elseif strcmp(type,'PCM')
[m,n]=sort(1-numb);
end
[row, column]=size(proto);
[row1, column1]=size(testS);
for h=1:row

    data=proto(n(1:h),:);
    cover1=cover(n(1:h));
 for i=1:row1
               distance(i,:)=sqrt(sum(abs(repmat(testS(i,1:(column-1)),h,1)-data(:,1:(column-1))), 2));
 end

 label1=[];
 for i=1:row1
     k=0;
     index=[];
     for j=1:h
      if distance(i,j)<=cover1(j)
          k=k+1;
          index(k)=data(j,column);
      end
     end

     if k==1
          label1(i)=index(1);
     else
         [indd,in]=min(distance(i,:));
         label1(i)=data(in,column);
     end

 end
      LABELS(h,:)=label1;
      data=[];
      cover1=[];
      distance=[];
      ClassRate1(h)=length(find((label1'-testL)==0))/length(testL);
end
[m1,n1]=max(ClassRate1);
ClassRate=m1;
num1=n1;
label=LABELS(n1,:);
