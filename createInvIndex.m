function invIdx = createInvIndex(words, noWrds)

invIdx=cell(1,noWrds);
count=zeros(1,noWrds);
for j =1:length(words)
    wrd = words(j);
    count(wrd)=count(wrd)+1;
    invIdx{wrd}(count(wrd))= j-1;
end