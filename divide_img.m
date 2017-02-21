function parts = divide_img(im, tile_sz, sl_sz)

[rows,cols] = size(im);
newimgS = tile_sz;

 if(rows<=newimgS || cols<=newimgS)
     parts.img{1}=im;
     parts.loc{1}=[1;1];
     sprintf('Image size is smaller  than newimgS');
     return;
 end

k=0;
shiftS = newimgS-sl_sz;


for i=1:shiftS:rows
    for j=1:shiftS:cols
        xid_e = min(i+newimgS-1,rows);
        yid_e = min(j+newimgS-1,cols);
        main_im2 = im(i:xid_e,j:yid_e);
        %figure;imshow(main_im2);
               
        if size(main_im2,1) == newimgS && size(main_im2,2) == newimgS
            k=k+1;
            parts.img{k} = main_im2;
            parts.loc{k} = [i;j];
        %    title('consider');           
        else
%             % for boundary chunks, if it is smaller, add it to previous
%             % part
%              
%              if(size(main_im2,2)) < newimgS && (size(main_im2,1)) < newimgS
%                  xid_e = min(i+newimgS-1-280,rows);
%                  yid_e = min(j+newimgS-1-280,cols);
%                  lastchunk = im(i:xid_e,j:yid_e);
%                  parts.img{k} = [parts.img{k} lastchunk];
%                  continue;
%              end
%             
%             
%              if(size(main_im2,2)) < newimgS
%                  xid_e = min(i+newimgS-1,rows);
%                  yid_e = min(j+newimgS-1-280,cols);
%                  lastchunk = im(i:xid_e,j:yid_e);
%                  parts.img{k} = [parts.img{k} lastchunk];
%                  continue;
%              end
%              
%              if(size(main_im2,1)) < newimgS
%                  xid_e = min(i+newimgS-1-280,rows);
%                  yid_e = min(j+newimgS-1,cols);
%                  lastchunk = im(i:xid_e,j:yid_e);
%                  parts.img{k} = [parts.img{k}; lastchunk];
%                  continue;
%              end

               if(size(main_im2,1)) < newimgS && (size(main_im2,2)) < newimgS
                  k=k+1;                 
                  lastchunk = im(rows-newimgS+1:rows,cols-newimgS+1:cols);
                  parts.img{k} = lastchunk;
                  parts.loc{k} = [rows-newimgS+1; cols-newimgS+1];
                  continue;
               end 
               
               if(size(main_im2,2)) < newimgS
                  k=k+1;
                  lastchunk = im(i:xid_e,cols-newimgS+1:cols);
                  parts.img{k} = lastchunk;
                  parts.loc{k} = [i; cols-newimgS+1];
                  continue;
               end
               
               if(size(main_im2,1)) < newimgS
                  k=k+1;                 
                  lastchunk = im(rows-newimgS+1:rows,j:yid_e);
                  parts.img{k} = lastchunk;
                  parts.loc{k} = [rows-newimgS+1; j];
                  continue;
               end
        end
    end
end


end