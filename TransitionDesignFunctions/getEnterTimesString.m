function textString=getEnterTimesString(vec)
%%this function takes a vector and spits out the text string that is
%%inserted in enter times. 

textString=strjoin(strsplit( num2str(vec), ' '),',');

end