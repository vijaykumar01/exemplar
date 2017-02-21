function show_boxes(im, box)

h=figure;
for ij = 1:length(box)
    score=box(ij).s;
    im = insertText(im,[box(ij).xy(2),box(ij).xy(1)],num2str(score));    
end
imshow(im,'Border','tight');
for b=box
    hold on;
    line([b.xy(2) b.xy(4) b.xy(4) b.xy(2) b.xy(2)]',...
        [b.xy(1) b.xy(1) b.xy(3) b.xy(3) b.xy(1)]', 'color', ...
        'b', 'linewidth', 4);
end
end