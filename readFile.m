function data = readFile(ptr)
% read file
data = [];
tline = fgetl(ptr);

while ischar(tline)
    xx = strsplit(tline);
    if length(xx)>4
        te = zeros(1,length(xx));
        for j=1:length(xx)
            te(j)=str2double(cell2mat(xx(j)));
        end
        data = [data;te];
        
    end
    tline = fgetl(ptr);
end
fclose(ptr);