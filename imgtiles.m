function [main_im, parts, im_ratio] = imgtiles(main_im, tile_sz, slide_sz)

parts=[];
im_ratio=1;
if(max(size(main_im)) < 1280)
    if(max(size(main_im)) < 500)
        main_im = imresize(main_im,3);
        im_ratio = 3;
    else
        main_im = imresize(main_im,2);
        im_ratio=2;
    end
end
parts=divide_img(main_im, tile_sz, slide_sz);
parts.img{end+1}=main_im;
parts.loc{end+1}=[1 1];

end