function  [proto,cover,nLabel]=extraction_coveringrule(patterns,labels,deg,C,dell,delta)

%% SVM training
deta=delta;
label_train=labels;
label_train(labels==-1)=2;
training=[patterns',label_train'];
[row,column]=size(training);
% run the support vector algorithm
[dim,ell] = size(patterns);
G=rbf_dot_self(patterns,deg);
H=(labels'*labels).*G;
c = -ones(ell,1);         % linear term
A = labels;               % lhs of equality constraint
b = 0;                    % rhs of equality constraint
bl = zeros(ell,1);        % lower bound
bu = C*ones(ell,1);       % upper bound
alpha = pr_loqo2(c, H, A, b, bl, bu);
SVs1=patterns(:,intersect(find(abs(alpha)>deta),find(labels==1)));
SVs2=patterns(:,intersect(find(abs(alpha)>deta),find(labels==-1)));
SVs=[SVs1,SVs2];
nSV(1)=size(SVs1,2);
nSV(2)=size(SVs2,2);
[column1,row1]=size(SVs);
for i=1:row
distance(i,:)=sqrt(sum((repmat(training(i,1:(column-1)),row,1)-training(:,1:(column-1))).^2, 2));
distance1(i,:)=sqrt(sum((repmat(training(i,1:(column-1)),row1,1)-SVs').^2, 2));            
end
distance4=distance;
%% find the cover radius of any sample
nLabel=[1 2];
    [row2,column2]=size(nLabel);
    num_SVs(1)=1;
    for i=1:column2
    num_SVs(i+1)=sum(nSV(1:i))+1;
    end
    pp=2*max(max(distance));
    distance=distance+pp*eye(size(distance));    
    
%% covering generation      
    [row2,column2]=size(nLabel);
    num_SVs(1)=1;
    for i=1:column2
        num_SVs(i+1)=sum(nSV(1:i))+1;
    end  
    for i=1:row
        [m1,n1]=sort(distance1(i,num_SVs(training(i,column)):(num_SVs(training(i,column)+1)-1)));
        RADIUS(i)=m1(1);
    end
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
num(core~=0)=0;
RADIUS((core~=0))=0;
num1=num;
num(num1<dell)=0;
RADIUS(num1<dell)=0;
if ~isempty(num)  
    num2=num;
else
     num2=num3;
end

type='VM';
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
%% show all the covering regions
pos_pats = find(labels==+1);
neg_pats = find(labels==-1);
[dim,ell] = size(patterns);
G=rbf_dot_self(patterns,deg);
H=(labels'*labels).*G;

% create test patterns on a grid 
test_num=30 ;
%mins=min(patterns') ;
%maxs=max(patterns') ;
mins=[-1,-1];
maxs=[1,1];
x_range = mins(1):((maxs(1)-mins(1))/(test_num - 1)):maxs(1) ;
y_range = mins(2):((maxs(2)-mins(2))/(test_num - 1)):maxs(2) ;
[xs, ys] = meshgrid(x_range, y_range);	% two matrices
grid_patterns = [xs(:)' ; ys(:)'] ;

% run the support vector algorithm
c = -ones(ell,1);         % linear term
A = labels;               % lhs of equality constraint
b = 0;                    % rhs of equality constraint
bl = zeros(ell,1);        % lower bound
bu = C*ones(ell,1);       % upper bound
alpha = pr_loqo2(c, H, A, b, bl, bu);
% use the two central multipliers to compute the threshold:
[tmp,ind1] = min(abs(alpha(pos_pats)-C/2));
[tmp,ind2] = min(abs(alpha(neg_pats)-C/2));
b = (H(pos_pats(ind1),:)*alpha - H(neg_pats(ind2),:)*alpha)/2;
%  [alpha,b]=kredloqo_qp(patterns, labels', deg, 1/C); 
alpha=alpha.*labels'

% compute the output on the training patterns
RD=rbf_dot(patterns, patterns, deg) ;
plabels = sign((RD*alpha - b)') ;  
Train_Errors = (plabels ~= labels);
Train_Error = sum(Train_Errors)/length(labels);

% compute the output on grid_patterns
RD=rbf_dot(grid_patterns, patterns, deg) ;
pgrid_output = (RD*alpha - b)' ;

% plot the output contours
imag = - reshape(pgrid_output, test_num, test_num);
FeatureLines = [0 -100000 100000]';  %cheap hack to only get the decision boundary

%% 
f4=figure(4); 
set(f4,'Position',[50 300 300 300],'Name','covering rules');
colormap('cool')
pcolor(x_range, y_range, imag) ;
[c,h] = contour(x_range, y_range, imag, FeatureLines,'k') ;

set(h(1),'LineWidth',2);
i=1;
while length(h)>i
  set(h(i+1),'LineWidth',2);
  i = i+1;
end

FeatureLines=[-1 1]' ;  % now the SV lines
[c,h] = contour(x_range, y_range, imag, FeatureLines,'k') ;
set(h(1),'LineWidth',2,'LineStyle',':');
i=1;
while length(h)>i
  set(h(i+1),'LineWidth',2,'LineStyle',':');
  i = i+1;
end

shading interp
hold on
p = plot(patterns(1,find(labels==-1)), patterns(2,find(labels==-1)), 'ro') ;
set(p,'MarkerSize',6,'linewidth',[2]);
hold on
p = plot(patterns(1,find(labels==1)), patterns(2,find(labels==1)), 'b.') ;
set(p,'MarkerSize',15);
hold on
row1=length(labels);
for i=1:row1
k=i;
r=RADIUS(k);
if r>0 && labels(k)==1
circle(r,training(k,1),training(k,2),'b');    
% rectangle('position',[(training(k,1)-r) (training(k,2)-r) 2*r 2*r] );
axis equal;
end

if r>0 && labels(k)==-1
circle(r,training(k,1),training(k,2),'r');    
% rectangle('position',[(training(k,1)-r) (training(k,2)-r) 2*r 2*r] );
axis equal;
end

end


%%  show the reducted rules
f5=figure(5); 
set(f5,'Position',[1000 300 300 300],'Name','covering rules');
title('learned rules by CRCR')
%clf
colormap('cool')
pcolor(x_range, y_range, imag) ;
[c,h] = contour(x_range, y_range, imag, FeatureLines,'k') ;

set(h(1),'LineWidth',2);
i=1;
while length(h)>i
  set(h(i+1),'LineWidth',2);
  i = i+1;
end

FeatureLines=[-1 1]' ;  % now the SV lines
[c,h] = contour(x_range, y_range, imag, FeatureLines,'k') ;
set(h(1),'LineWidth',2,'LineStyle',':');
i=1;
while length(h)>i
  set(h(i+1),'LineWidth',2,'LineStyle',':');
  i = i+1;
end

shading interp

p = plot(patterns(1,find(labels==-1)), patterns(2,find(labels==-1)), 'ro') ;
set(p,'MarkerSize',8,'linewidth',[2]);
hold on
p = plot(patterns(1,find(labels==1)), patterns(2,find(labels==1)), 'b.') ;
set(p,'MarkerSize',15);
hold on
row1=length(lab);
for i=1:row1
k=lab(i);
r=RADIUS(k);
if r>0 && labels(k)==1
circle(r,training(k,1),training(k,2),'b');    
axis equal;
end

if r>0 && labels(k)==-1
circle(r,training(k,1),training(k,2),'r');    
axis equal;
end

end



