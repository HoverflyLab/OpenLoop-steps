function [ SubFolders ] = FindSubFolders( inputFolderPath , ErrorIfEmpty)
%FindSubFolders Returns the folders within the provided filepath via a table.
%The returned folders a provided in a table where the .name cell contains the filepath of the folder

SubFolders = [];

%Get initial directory list
FileList = dir(fullfile(inputFolderPath));

%Get number of items in directory
FileCount = size(FileList,1);

%As the dir function always returns . .. folders as the first 2 entries
if FileCount > 2
    
    %iterate through all Files 
    for i = 3:FileCount
        
        %If this file is a directory add it to the DirectoryList
        if FileList(i).isdir == 1
            
            %Add the folderpath to the struct
            FileList(i).filepath = strcat(inputFolderPath,'/',FileList(i).name);
            
            %Add to SubFolders
            SubFolders = [SubFolders;FileList(i)];
            
            %Move onto next file
        end

    end
else
    if ErrorIfEmpty == 1
        error('Chosen directory did not contain any files or folders')
    end
end


end

