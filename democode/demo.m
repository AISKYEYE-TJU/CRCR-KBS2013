%We use the code from Schoelkopf to show the learning process of our method. 

% (c) B. Schoelkopf 1998
% you may use this in your courses, or to produce images for publications,
% provided that you cite:
%@Book{SchSmo02,
%  author    = {B. Sch{\"o}lkopf and A. Smola},
%  title     = {Learning with Kernels},
%  publisher = {MIT Press},
%  year      = {2002},
%  address   = {Cambridge, MA}
%}

close all;
f3 = figure(3);
close(f3);
f3 = figure(3);
set(f3,'Position',[450 300 500 400],'Name','Support Vector Classifier'); 
%set(f,'Position',[0 300 567 467]); 
clf;
clear;

global C;
global kernel;
global deg;

kernel = 'rbf';
deg = 0.5;  % the constant in exp(|x-y|^2/deg) or (x.y)^deg
C=100 ;        % upper bound (regularization)
% load demo.mat
patterns=[];
labels=[];

while 1

[patterns,labels]=click_data5(patterns,labels);

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
alpha=alpha.*labels';

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
hold on
% plot the training patterns
p = plot(patterns(1,find(labels==-1)), patterns(2,find(labels==-1)), 'ro') ;
set(p,'MarkerSize',8,'linewidth',[2]);
p = plot(patterns(1,find(labels==1)), patterns(2,find(labels==1)), 'b.') ;
set(p,'MarkerSize',15);
% mark the SVs
delta=0.001;
p = plot(patterns(1,find(abs(alpha)>delta)), patterns(2,find(abs(alpha)>delta)), 'gs');
set(p,'MarkerSize',8,'linewidth',[2]);

[proto,cover,nLabel]=extraction_coveringrule(patterns,labels,deg,C,1,delta);
cont_button = uicontrol('style','pushbutton','units','normal','pos',[0.03 0.11 0.15 0.15],'string','Click to Continue');

x=ginput(1) ;
close all
end % while 1



clear


