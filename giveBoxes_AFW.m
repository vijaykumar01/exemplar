function boxes = giveBoxes_AFW(boxes, scores,sc,row,col,thres,count,padd,gs,padd2,imgStartloc)
padd2=0;

I = find(scores > thres);
I = I(:);
num = length(I);
if num > 0,
    [y,x] = ind2sub(size(scores),I);
    for kk=1:num
        count = count+1;
        boxes(count).xy(1) = ((gs*y(kk)-padd-padd2*gs-1)*(1/sc)) + (imgStartloc(1)-1);
        boxes(count).xy(2) = (gs*x(kk)-padd-padd2*gs-1)*(1/sc) + (imgStartloc(2)-1);
        boxes(count).xy(3) = boxes(count).xy(1) + (gs*col*(1/sc)-1) ;
        boxes(count).xy(4) = boxes(count).xy(2)+ (gs*row*(1/sc)-1);
        
        %old
%         % expand the box
%         expand_v=0.3;
%         if  boxes(count).xy(3)- boxes(count).xy(1) > 150
%             expand_v = 0.35;
%         end
%         boxes(count).xy(1) = boxes(count).xy(1) - 80*expand_v*(1/sc);
%         boxes(count).xy(2) = boxes(count).xy(2) - 80*0.05*(1/sc);
%         boxes(count).xy(3) = boxes(count).xy(3) + 80*0.1*(1/sc);
%         boxes(count).xy(4) = boxes(count).xy(4) + 80*0.05*(1/sc);
     
         boxes(count).xy(1) = boxes(count).xy(1) - 80*0.15*(1/sc);
         boxes(count).xy(2) = boxes(count).xy(2) - 80*0.15*(1/sc);
         boxes(count).xy(3) = boxes(count).xy(3) + 80*0.15*(1/sc);
         boxes(count).xy(4) = boxes(count).xy(4) + 80*0.15*(1/sc);
         
        boxes(count).s  = scores(I(kk));
    end
end