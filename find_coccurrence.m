function [allcowords_ex,allcowords_kp]=find_coccurrence(assoc,ww,kpts,hst)
        
        allcowords_ex = [];
        allcowords_kp = [];
        
        for k=1:length(assoc)
            cowords=assoc{k};
            cowords=cowords+1; %1-indexing, matlab
            
            %check if coword exists
            if sum(hst(cowords)>0)<length(cowords)
                continue;
            end
                
            fnd_idx=cell(1,length(cowords));                        
            for cw=1:length(cowords)
                fnd_idx{cw} = find(ww==cowords(cw));
            end
            combs = cartprod(fnd_idx);
            
            if size(combs,1) > 25
                continue;
            end           
            
            for ic=1:size(combs,1)
                
                avgkpt=mean(kpts(1:2,combs(ic,:)),2);
                
                % mean distance to centroid
                distToMean = norm(kpts(1:2,combs(ic,:)) - ...
                    repmat(avgkpt(1:2),1,size(combs,2)));
                
                % if words exist nearby
                if distToMean < (sqrt(2)*80)
                    avgkpt=max(round(avgkpt),0);                
                    allcowords_ex=[allcowords_ex k-1]; % ruleno-1
                    allcowords_kp=[allcowords_kp avgkpt];
                end
            end                                   
        end
end