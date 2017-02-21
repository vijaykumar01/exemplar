fddb=0;
alpha= 0.8;
no_gs = 64;
noEx=3000;
iter_sc = [1 0.5 0.3];
tile_sz = 640;
tile_slide_sz = 140;
spread2=2;
wt = single(ones(80,80));
scales = floor(80*((2^(1/4)).^[0:15]));
gw1D = single(exp(-[spread2:-1:1 0 1:spread2]./2.5));

%dense sift features
obj.scale_factor = 2^(1/2);
obj.num_scales = 12;
obj.step = 3;
obj.patch_size = 24;
obj.aug_frames = false;
obj.sqrt_map = true;
obj.l2hys = false;