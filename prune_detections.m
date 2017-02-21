function boxes2 = prune_detections(size_im, boxes)

    removeid = [];
    for i=1:length(boxes)
        
        b = boxes(i);
        
        x1 = b.xy(2);
        y1 = b.xy(1);
        x2 = b.xy(4);
        y2 = b.xy(3);
        
        % if the box is totally within the image boundaries, no 
        % need to do anything
        if x1>1 && y1> 1 && x2 < size_im(2) && y2 < size_im(1)
            continue;
        end
        
        new_x1 = max(x1, 1);
        new_y1 = max(y1, 1);
        new_x2 = min(x2, size_im(2));
        new_y2 = min(y2, size_im(1));
        
        newbox = [new_x1 new_y1 new_x2 new_y2];
        oldbox = [x1 y1 x2 y2];
        overlap = getosmatrix_bb(newbox,oldbox);
        
        
        % if the box has atleast 50% face inside the image, consider it
        % else reject it
        if overlap > 0.5 %constraint box to image boundaries
            boxes(i).xy = [new_y1 new_x1 new_y2 new_x2];           
        else
            removeid = [removeid i]; 
        end
    end
    boxes(removeid)=[];
    boxes2=boxes;
end