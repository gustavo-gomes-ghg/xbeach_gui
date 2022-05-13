% read .ldb files (land boundaries)
%[output]=readldb(dir)

function [output]=readldb(dir)

[a b]=textread(dir,'%s %s');
output=zeros(length(a),2);
complete=0;
i=1;

while complete==0
    
    if i==length(a)
        complete=1;
    end
    
    if isempty(b{i,1})==1
        output(i:i+1,1)=nan;
        output(i:i+1,2)=nan;
        i=i+2;
    else
        output(i,1)=str2num(a{i,1});
        output(i,2)=str2num(b{i,1});
        i=i+1;
    end
       
end

end