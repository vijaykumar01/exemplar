function main_im = readImg(imgpath)

main_im=imread(imgpath);
if size(main_im,3)==3
    main_im=rgb2gray(main_im);
end

main_im = im2single(main_im);