function plotRoadNetwork(nodes, edges, w, titleStr, colorBarLabel)

n = nodes;
e = edges;
levels = unique(w);
maxNumPass = max(w);
c = cool(maxNumPass+1);
F = find(w == 0);
for j = 1:length(F)
    line([n(e(F(j),1),1) n(e(F(j),2),1)], [n(e(F(j),1),2) n(e(F(j),2),2)], 'Color',[0.8, 0.8, 0.8],'LineWidth',1);
%         x1 = n(e(F(j),1),1);
%         y1 = n(e(F(j),1),2);
%         x2 = n(e(F(j),2),1);
%         y2 = n(e(F(j),2),2);
%         
%         x = min(x1,x2)+abs(x1-x2)/2;
%         y = min(y1,y2)+abs(y1-y2)/2;
%         text(x,y,num2str(F(j)),'VerticalAlignment','bottom','HorizontalAlignment','left');
end

if levels(1)==0
    startPos = 2;
else
    startPos = 1;
end

for i = startPos:length(levels)
    F = find(w == levels(i));
    for j = 1:length(F)
        try
        line([n(e(F(j),1),1) n(e(F(j),2),1)], [n(e(F(j),1),2) n(e(F(j),2),2)], 'Color',c(i,:),'LineWidth',2);
        catch
            disp 'error';
        end
%         x1 = n(e(F(j),1),1);
%         y1 = n(e(F(j),1),2);
%         x2 = n(e(F(j),2),1);
%         y2 = n(e(F(j),2),2);
%         
%         x = min(x1,x2)+abs(x1-x2)/2;
%         y = min(y1,y2)+abs(y1-y2)/2;
%         text(x,y,num2str(F(j)),'VerticalAlignment','bottom','HorizontalAlignment','left');
    end
end

% Add color bar
maxW = max(w);
colormap(c);
caxis([1,maxW]);
colB = colorbar;
ylabel(colB,colorBarLabel);
% Make background white
set(gcf, 'color', 'w');

% Automatic zoom
minx = min(nodes(:,1))-1;
maxx = max(nodes(:,1))+1;
miny = min(nodes(:,2))-1;
maxy = max(nodes(:,2))+1;

xlim([minx maxx]);
ylim([miny maxy]);

% Set title of figure
title(titleStr,'fontsize',14);
end
