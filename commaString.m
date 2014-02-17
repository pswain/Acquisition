function commaS=commaString(vector)
%Returns a string containing the numbers in the input numeric vector
%separated by commas
if size(vector,1)>1
   vector=vector'; 
end

a=num2str(vector,'%g,');     
b=strfind(a,' ');
a(b)=[];
if strcmp(a(end),',')
    a(end)=[];
end
commaS=a;