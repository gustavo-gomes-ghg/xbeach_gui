%Encontra valor e indice de um vetor mais proximo de um dado valor de
%entrada
%[valor_out ind_out]=findnearest(valor_in,vetor_in)
function [valor_out ind_out]=findnearest(valor_in,vetor_in)
[valor_out ind_out]=min(abs(vetor_in-valor_in));
valor_out=vetor_in(ind_out);