%-------------------------------------------------------------------------%
%---------------------------Import Documents------------------------------%
%-------------------------------------------------------------------------%
[DB1Num, DB1Str, DB1Dat] = xlsread('F:\Andrew\Documents\2020 University\ENGR9700 Masters Thesis\Review\Accelerometry\medline.xls');
[DB2Num, DB2Str, DB2Dat] = xlsread('F:\Andrew\Documents\2020 University\ENGR9700 Masters Thesis\Review\Accelerometry\scopus.csv');
[DB3Num, DB3Str, DB3Dat] = xlsread('F:\Andrew\Documents\2020 University\ENGR9700 Masters Thesis\Review\Accelerometry\pubmed.csv');
[DB4Num, DB4Str, DB4Dat] = xlsread('F:\Andrew\Documents\2020 University\ENGR9700 Masters Thesis\Review\Accelerometry\ieee.csv');
[DB5Num, DB5Str, DB5Dat] = xlsread('F:\Andrew\Documents\2020 University\ENGR9700 Masters Thesis\Review\Accelerometry\proquest.xls');
[DB6Num, DB6Str, DB6Dat] = xlsread('F:\Andrew\Documents\2020 University\ENGR9700 Masters Thesis\Review\Accelerometry\sciencedirect.csv');

%Which column of the datasheet are the Document Titles in?
ColumnDB1 = 5; %medline
ColumnDB2 = 3; %scopus
ColumnDB3 = 1; %pubmed
ColumnDB4 = 1; %ieee
ColumnDB5 = 1; %proquest
ColumnDB6 = 1; %sciencedirect

%Save titles
%Make title strings lowercase 
%Skip the header row ("Title, Author, Date etc.")
ArticleTitlesDB1 = lower(DB1Str(3:16,ColumnDB1));  
ArticleTitlesDB2 = lower(DB2Str(2:49,ColumnDB2));  
ArticleTitlesDB3 = lower(DB3Str(2:15,ColumnDB3));  
ArticleTitlesDB4 = lower(DB4Str(2:22,ColumnDB4));  
ArticleTitlesDB5 = lower(DB5Str(2:13,ColumnDB5));  
ArticleTitlesDB6 = lower(DB6Str(2:45,ColumnDB6));  

%Remove full-stops from article titles
ArticleTitlesDB1 = replace(ArticleTitlesDB1,".","");
ArticleTitlesDB2 = replace(ArticleTitlesDB2,".","");
ArticleTitlesDB3 = replace(ArticleTitlesDB3,".","");
ArticleTitlesDB4 = replace(ArticleTitlesDB4,".","");
ArticleTitlesDB5 = replace(ArticleTitlesDB5,".","");
ArticleTitlesDB6 = replace(ArticleTitlesDB6,".","");

%-------------------------------------------------------------------------%
%---------------------IDENTIFY UNIQUE DB1 ARTICLES---------------------%
%-------------------------------------------------------------------------%

AllUniqueTitles = ArticleTitlesDB1;

%-------------------------------------------------------------------------%
%---------------------IDENTIFY UNIQUE DB2 ARTICLES---------------------%
%-------------------------------------------------------------------------%
IdenticalDB2Articles = zeros(size(ArticleTitlesDB2));
UniqueDB2Articles = (1:size(ArticleTitlesDB2))';

%For every title in the first database...
for i = 1:size(ArticleTitlesDB2)
    
    %compare with every title in the second database
    for j = 1:size(AllUniqueTitles)
        
        tf = strcmp(ArticleTitlesDB2(i),AllUniqueTitles(j)); %true if strings are identical
        
        if tf
            IdenticalDB2Articles(i) = i; %these articles were found in both databases
        end
    end
    
    %this array indicates the unique articles
    UniqueDB2Articles(i) = UniqueDB2Articles(i) - IdenticalDB2Articles(i);
end

%Combine Unique Articles
for i = 1:size(UniqueDB2Articles)
    if UniqueDB2Articles(i) ~= 0
        AllUniqueTitles = [AllUniqueTitles;ArticleTitlesDB2(i)];
    end
end

%-------------------------------------------------------------------------%
%---------------------IDENTIFY UNIQUE DB3 ARTICLES---------------------%
%-------------------------------------------------------------------------%
IdenticalDB3Articles = zeros(size(ArticleTitlesDB3));
UniqueDB3Articles = (1:size(ArticleTitlesDB3))';

%For every title in the first database...
for i = 1:size(ArticleTitlesDB3)
    
    %compare with every title in the second database
    for j = 1:size(AllUniqueTitles)
        
        tf = strcmp(ArticleTitlesDB3(i),AllUniqueTitles(j)); %true if strings are identical
        
        if tf
            IdenticalDB3Articles(i) = i; %these articles were found in both databases
        end
    end
    
    %this array indicates the unique articles
    UniqueDB3Articles(i) = UniqueDB3Articles(i) - IdenticalDB3Articles(i);
end

%Combine Unique Articles
for i = 1:size(UniqueDB3Articles)
    if UniqueDB3Articles(i) ~= 0
        AllUniqueTitles = [AllUniqueTitles;ArticleTitlesDB3(i)];
    end
end

%-------------------------------------------------------------------------%
%----------------------IDENTIFY UNIQUE DB4 ARTICLES----------------------%
%-------------------------------------------------------------------------%
IdenticalDB4Articles = zeros(size(ArticleTitlesDB4));
UniqueDB4Articles = (1:size(ArticleTitlesDB4))';

%For every title in the first database...
for i = 1:size(ArticleTitlesDB4)
    
    %compare with every title in the second database
    for j = 1:size(AllUniqueTitles)
        
        tf = strcmp(ArticleTitlesDB4(i),AllUniqueTitles(j)); %true if strings are identical
        
        if tf
            IdenticalDB4Articles(i) = i; %these articles were found in both databases
        end
    end
    
    %this array indicates the unique articles
    UniqueDB4Articles(i) = UniqueDB4Articles(i) - IdenticalDB4Articles(i);
end

%Combine Unique Articles
for i = 1:size(UniqueDB4Articles)
    if UniqueDB4Articles(i) ~= 0
        AllUniqueTitles = [AllUniqueTitles;ArticleTitlesDB4(i)];
    end
end

%-------------------------------------------------------------------------%
%----------------------IDENTIFY UNIQUE DB5 ARTICLES------------------%
%-------------------------------------------------------------------------%
IdenticalDB5Articles = zeros(size(ArticleTitlesDB5));
UniqueDB5Articles = (1:size(ArticleTitlesDB5))';

%For every title in the first database...
for i = 1:size(ArticleTitlesDB5)
    
    %compare with every title in the second database
    for j = 1:size(AllUniqueTitles)
        
        tf = strcmp(ArticleTitlesDB5(i),AllUniqueTitles(j)); %true if strings are identical
        
        if tf
            IdenticalDB5Articles(i) = i; %these articles were found in both databases
        end
    end
    
    %this array indicates the unique articles
    UniqueDB5Articles(i) = UniqueDB5Articles(i) - IdenticalDB5Articles(i);
end

%Combine Unique Articles
for i = 1:size(UniqueDB5Articles)
    if UniqueDB5Articles(i) ~= 0
        AllUniqueTitles = [AllUniqueTitles;ArticleTitlesDB5(i)];
    end
end

%-------------------------------------------------------------------------%
%----------------------IDENTIFY UNIQUE DB6 ARTICLES------------------%
%-------------------------------------------------------------------------%
IdenticalDB6Articles = zeros(size(ArticleTitlesDB6));
UniqueDB6Articles = (1:size(ArticleTitlesDB6))';

%For every title in the first database...
for i = 1:size(ArticleTitlesDB6)
    
    %compare with every title in the second database
    for j = 1:size(AllUniqueTitles)
        
        tf = strcmp(ArticleTitlesDB6(i),AllUniqueTitles(j)); %true if strings are identical
        
        if tf
            IdenticalDB6Articles(i) = i; %these articles were found in both databases
        end
    end
    
    %this array indicates the unique articles
    UniqueDB6Articles(i) = UniqueDB6Articles(i) - IdenticalDB6Articles(i);
end

%Combine Unique Articles
for i = 1:size(UniqueDB6Articles)
    if UniqueDB6Articles(i) ~= 0
        AllUniqueTitles = [AllUniqueTitles;ArticleTitlesDB6(i)];
    end
end

AllUniqueTitles_AtoZ = sort(AllUniqueTitles);

AllSearchResults = ...
size(ArticleTitlesDB1)+ ...
size(ArticleTitlesDB2)+ ...
size(ArticleTitlesDB3)+ ...
size(ArticleTitlesDB4)+ ...
size(ArticleTitlesDB5)+ ...
size(ArticleTitlesDB6);
