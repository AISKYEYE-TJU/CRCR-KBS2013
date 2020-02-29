function [patterns,labels]=click_data5(patterns,labels);



global kernel;
global C;
global deg;

%clf
%hold on
%axis([-1 1 -1 1])
%axis('off')


num = size(patterns,2);

pos_num = num/2 + sum(labels)/2;
neg_num = num - pos_num;

%text([-0.7 -0.7 -0.7],[0.1 -0.2 -0.4],['Click Data (Left Mouse / Right Mouse)'; 'Press Middle Mouse when done         '; 'Delete Points with d                 ']);
%pause(0.3);
%
clf
hold on
axis([-1.3 1 -1 1])
axis('off')
for i = 1:num,
  if labels(i) == 1
    p(i) = plot(patterns(1,i), patterns(2,i), 'b.') ;
    set(p(i), 'MarkerSize', 20);
  else
    p(i) = plot(patterns(1,i), patterns(2,i), 'ro') ;
    set(p(i),'LineWidth',2);
  end
end



slider_deg = uicontrol('style','slider','units','normal','pos',[0.03 0.82 0.15 0.07], 'value', log(20*deg)/log(100), 'string', 'sigma');
slider_C = uicontrol('style','slider','units','normal','pos',[0.03 0.72 0.15 0.07], 'value', log(C)/log(10000), 'string', 'C');

text_deg = uicontrol('style','text','units','normal','pos',[0.03 0.89 0.15 0.03],'string','sigma');
text_C = uicontrol('style','text','units','normal','pos',[0.03 0.79 0.15 0.03],'string','C');

train_button = uicontrol('style','pushbutton','units','normal','pos',[0.03 0.5 0.15 0.15],'string','train');
clear_button = uicontrol('style','pushbutton','units','normal','pos',[0.03 0.306 0.15 0.15],'string','clear');

% box around the allowed field for the patterns
l = line([-1 1 1 -1 -1],[-1 -1 1 1 -1]); % [x1 x2],[y1 y2]
set(l,'color',[1 1 1],'linestyle',':')

while 1
  [x(1),x(2),button]=ginput(1);
  in_range = (x(1)>-1 & x(1)<1 & x(2)>-1 & x(2)<1);
  in_train = (x(1)>-1.6 & x(1)<-1.16 & x(2)>-0.05 & x(2)<0.33);
  in_clear = (x(1)>-1.6 & x(1)<-1.16 & x(2)>-0.52 & x(2)<-0.15);
  if button == 2 & in_range
    [min_dist min_ind] = min(dist(patterns',x'));
    patterns = patterns(:,[1:(min_ind-1) (min_ind+1):num]);
    if labels(min_ind) == 1
      pos_num = pos_num - 1;
    else
      neg_num = neg_num - 1;
    end
    labels = labels(:,[1:(min_ind-1) (min_ind+1):num]);
    delete(p(min_ind));
    p = p(:,[1:(min_ind-1) (min_ind+1):num]);
  elseif button == 1 & in_range
    patterns=[patterns x'];
    p(num+1) = plot(x(1), x(2), 'b.');
    set(p(num+1), 'MarkerSize', 20);
    pos_num = pos_num+1;
    labels=[labels 1];
  elseif button == 3 & in_range
    patterns=[patterns x'];
    p(num+1) = plot(x(1), x(2), 'ro');
    set(p(num+1),'LineWidth',2);
    neg_num = neg_num+1;
    labels=[labels -1];
  elseif button == 114 | in_train
    if pos_num*neg_num>0 % run it!
      C = 10000^get(slider_C,'value');
      deg = 100^get(slider_deg,'value')/20;
      break
    else
      pos_num
      neg_num
      disp('one class is empty - enter a pattern')
      in_train = 0;
    end
  elseif in_clear
    for i=1:num,
      delete(p(i));
    end
    num = 0;
    pos_num = 0;
    neg_num = 0;
    patterns = [];
    labels = [];
  end
  num = pos_num + neg_num;
end

for i=1:num,
  delete(p(i));
end

set(slider_deg,'visible','off')
set(slider_C,'visible','off')
set(text_deg,'visible','off')
set(text_C,'visible','off')
set(train_button,'visible','off')
set(clear_button,'visible','off')








