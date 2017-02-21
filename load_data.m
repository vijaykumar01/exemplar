load data/vocab.mat
load data/thresh.mat;
load data/trdata.mat;

csum_npts = [0 cumsum(npts)];
csum_npts(end)=[];

fptrWrds = fopen('data/trw.txt','rb');
fptrHist = fopen('data/trhst.txt','rb');
allwords = fread(fptrWrds,'integer*4');fclose(fptrWrds);
alltrhist = fread(fptrHist,'integer*4');fclose(fptrHist);
allwords=uint32(allwords);
alltrhist=uint32(alltrhist);
trkpt1 = uint32(max(0,round(trkpt1-1)));
trkpt2 = uint32(max(0,round(trkpt2-1)));

trRowDist=80*ones(1,length(npts));
trColDist=80*ones(1,length(npts));