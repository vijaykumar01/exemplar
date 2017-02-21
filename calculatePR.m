function calculatePR()

clc;

loadPRParams;

addpath('~/Data/Personal/CODE/toolbox/vlfeat-0.9.20/toolbox/');vl_setup

overlap_thres = 0.5;

for kkk=1:length(ft_files)   
       
    gt_data=[]; 
    ft_data=[];    
    
    % read ground truth locations
    gt_p = fopen(gt_files{1},'r');
    ft_p = fopen(ft_files{kkk},'r');
    gt_data = readFile(gt_p);
    
    A = fscanf(ft_p, '%f %f %f %f %f %f\n');
    ft_data = reshape(A,6,size(A,1)/6)';     
    
    ft_o = fopen(ot_files{kkk},'w');
    
    dt_labels_scores = zeros(size(ft_data,1),2);
    miss=0;
    for box_no = 1:size(gt_data,1)
        idx = find(ft_data(:,1)==gt_data(box_no,1));
        if length(idx)>0
            [scores,bbla] = getosmatrix_bb([ft_data(idx,2) ft_data(idx,3) ...
                ft_data(idx,2)+ft_data(idx,4) ft_data(idx,3)+ft_data(idx,5)]...
                ,[gt_data(box_no,2) gt_data(box_no,3) gt_data(box_no,2)+gt_data(box_no,4) gt_data(box_no,3)+gt_data(box_no,5)]);
            if max(scores) > overlap_thres
                det_id = idx(find(scores==max(scores)));
                dt_labels_scores(det_id(1) ,2) = 1;
                fprintf(ft_o,'%f %f %f %f %f %f\n',gt_data(box_no,1),...
                    ft_data(det_id(1),2),ft_data(det_id(1),3),ft_data(det_id(1),4),...
                    ft_data(det_id(1),5),ft_data(det_id(1),6));                  
            else
                fprintf(ft_o,'%f %f %f %f %f %f\n',gt_data(box_no,1),0,0,0,0,0);              
                miss=miss+1;
            end
            dt_labels_scores(idx ,1) = ft_data(idx,6);
        else
            fprintf(ft_o,'%f %f %f %f %f %f\n',gt_data(box_no,1),0,0,0,0,0);
            miss=miss+1;
        end
        
    end   
    
    xxx=dt_labels_scores(:,2);
    xxx(xxx==0)=-1;
    [re{kkk},pr{kkk},info]=vl_pr([xxx ;ones(miss,1)],[dt_labels_scores(:,1); -inf.*ones(miss,1)]);
    auc{kkk}=info.auc;
    ap{kkk}=info.ap;    
end

figure(1);
for kkk=1:length(ft_files)
    hold on;
    plot(re{kkk},pr{kkk},'LineWidth', 4, 'Color', colorS(kkk,:));    
    leg{kkk} = sprintf('%s - AP: %0.3f', legendS{kkk},ap{kkk});
end
xlabel( 'Recall','FontName','Times','FontSize',25);
ylabel( 'Precision','FontName','Times','FontSize',25);
legend(leg);
xlim([0.5 1]);
ylim([0.5 1]);
grid on;