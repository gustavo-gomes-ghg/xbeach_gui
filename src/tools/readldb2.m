% read .ldb files (land boundaries)
%[output]=readldb2(dir)

function [output]=readldb2(dir)

[a,b]=textread(dir,'%s %s','whitespace','\b');
if isempty(b{1,1})
    [a,b]=textread(dir,'%s %s','delimiter','\t');
    for k=1:length(a(:,1))
        a{k,1}=[a{k,1} ' ' b{k,1} ' ' num2str(0)];
    end
end

z=1;
for g=1:length(a)
    aux=strfind(a{g,1},' ');
    if isempty(aux)~=1
        if size(aux,2)~=1
            if aux(2)>15
                output(z,1)=str2num(a{g,1}(1:aux(1)-1));
                output(z,2)=str2num(a{g,1}(aux(1)+1 : aux(2)-1));
                z=z+1;
            else
                output(z,1)=nan; output(z,2)=nan;
                z=z+1;
            end
        else
            output(z,1)=nan; output(z,2)=nan;
            z=z+1;
        end
    else
        output(z,1)=nan; output(z,2)=nan;
        z=z+1;
    end
    clear aux
end
    
