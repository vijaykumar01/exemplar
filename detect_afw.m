clear all;
setenv('DYLD_LIBRARY_PATH', '');

params;
load_data;

noimgs=length(npts);
noWrds=size(vocab.words,2);
total_words = noWrds+length(vp);

% of = fopen('exemplar_afw.txt','w');
files = dir(fullfile('data/AFW/','*.*g'));

for fi=1:1 %length(files)

    main_im = readImg(['data/AFW/' files(fi).name]);    
    [main_im, parts, im_ratio] = imgtiles(main_im, tile_sz, tile_slide_sz);

    boxes = [];   
    for pid=1:length(parts.img)

        main_im2=parts.img{pid};
        for iter=1:length(iter_sc)

            scaled_im=imresize(main_im2,iter_sc(iter));
            gs = max(size(main_im2))/no_gs;    
            
            [fea,kpts] = computeFea(obj,scaled_im);
            kpts=kpts*(1/iter_sc(iter));
            
            idx=find(sum(fea,1)==0);
            kpts(:,idx)=[];fea(:,idx)=[];
            
            [words,dd] = vl_kdtreequery(vocab.kdtree, vocab.words, ...
                fea, 'MaxComparisons', 25);
            len_f = length(words);
                        
            [cws,cws_kp]=find_coccurrence(vp, words-1,kpts,histc(words,1:noWrds));
            cws=uint32(cws+noWrds);
            cws_kp=single(round(cws_kp)-1);
            words = [words cws];
            kpts = [kpts [cws_kp;ones(1,size(cws_kp,2))]];
            
            invIndexTest = createInvIndex(words, total_words);
            tsthist = single(histc(words,1:total_words));
            
            scores = initialRanking(uint32(cwt), uint32(tsthist), ...
                uint32(npts), len_f, 1, noimgs, allwords, alltrhist,csum_npts);
            [srt_sc,srt_id]=sort(scores,'descend');
                                  
            maps=vote(words-1,len_f,single(round(kpts)-1),invIndexTest,...
                uint32(cwt),uint32(tsthist),no_gs,no_gs,gs,gw1D,...
                uint32(npts),scales,trRowDist, trColDist, ...
                uint32(srt_id(1:noEx)),thresh,trkpt1,trkpt2,wt,fddb,...
                alpha, allwords, alltrhist, csum_npts, total_words);
            maps=maps./len_f;

            for sc=1:length(scales)
                len_b=length(boxes);
                thres = 1;
                boxes = giveBoxes_AFW(boxes,maps(:,:,sc),1,scales(sc)/gs,...
                    scales(sc)/gs,thres,len_b,0,gs,0,parts.loc{pid});
            end
        end
    end

    boxes_nms = nms_face(boxes,0.25,1);
    boxes_nms = prune_detections(size(main_im),boxes_nms);    
    show_boxes(main_im, boxes_nms);

%     for b=boxes_nms
%         b.xy=b.xy*(1/im_ratio);
%         fprintf(of,'%s %f %f %f %f %f\n',files(fi).name,b.xy(2),b.xy(1),...
%             b.xy(4)-b.xy(2),b.xy(3)-b.xy(1),b.s);
%     end
end
% fclose(of);
