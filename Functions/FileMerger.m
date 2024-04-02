% OL Step 3 - Creating the .mat file
% This script is to be used after step 2, where the .csv files have been
% made after analysing them using Deep Lab Cut (DLC). This script will
% package both the raw data and calculated data into a single file

%Let the user know what is going on
disp('We will now begin creating the VideoName_DLC_Analysis.mat file')

disp('Please select the .mat file representing your video files')

% NEEDS TO BE ACCURATE
VideoResolution = [320,240];        % Used to invert Y values by using the frame height

[file, path] = uigetfile(strcat('', '*.mat'));
filePath = fullfile(path, file);
load(filePath)

%Search each folder and locate all valid .csv files.
%For each valid video provided
for i = 1:size(VideoList)
    
    %Find all files within the folder
    TempFileList = dir(fullfile(VideoList(i).folderpath));
    TempCSVFiles = [];
    
    %Seperate the name of the file from its file extension e.g. .mp4
    TempFileName = strsplit(VideoList(i).name,VideoType);
    TempFileName = TempFileName{1};
    
    %Search through each file in the directory and find the csv files
    %For each file remembering to skip the first two as they are . ..
    for j = 3:size(TempFileList)
        
        %If the file contains the name of the video (a convention followed by DLC)
        if not(isempty(strfind(TempFileList(j).name,TempFileName)))
            
            %If the file is a csv e.g. contains .csv
            if not(isempty(strfind(TempFileList(j).name,'.csv')))
                
                for k = 1:ModelListSize
                    
                    %If the csv contains the keyword e.g. Wings, Head, Hindlegs, Frontlegs.
                    if not(isempty(strfind(TempFileList(j).name,ModelList(k).keyword)))
                        TempCSVFiles(k).keyword = ModelList(k).keyword;
                        TempCSVFiles(k).filepath = strcat(VideoList(i).folderpath,'/',TempFileList(j).name);   
                    end
                end
            end
        end
    end
    
    %Get size of CSVList (we are only interested in Y value)
    [~,CSVListSize] = size(TempCSVFiles);
    
    %Before we begin analysis
    %Check if we have the correct amount of CSV files (there should be one file for each model).
    if CSVListSize == ModelListSize
        
        %Read in CSV data leaving out header text, we are assuming labels are in the correct order.
        TempWingsCSV = csvread(TempCSVFiles(1).filepath,3,0);
        TempHeadCSV = csvread(TempCSVFiles(2).filepath,3,0);
        TempHindlegsCSV = csvread(TempCSVFiles(3).filepath,3,0);
        TempFrontlegsCSV = csvread(TempCSVFiles(4).filepath,3,0);
        
        %initialise entire data set with arbitrary values, stops the script from continuously allocating memory later on.
        %All csv files should be the same size
        [Totalframes,~] = size(TempWingsCSV);
        DLC_RawData(Totalframes,1:Totalnumberofrawdatapoints) = zeros(1,Totalnumberofrawdatapoints);
        DLC_Calculations(Totalframes,1:Totalnumberofcalculations) = zeros(1,Totalnumberofcalculations);
        
        %For each row in the CSV files we run the following calculations
        for Row = 1:Totalframes
            
            %Process each CSV file using the relevant calculations
            [Wings_RawData, Wings_Calculations, Axis_Angle] = ProcessWingData(TempWingsCSV, Row, VideoResolution(1,2));
            [Head_RawData, Head_Calculations] = ProcessHeadData(TempHeadCSV, Row, VideoResolution(1,2), Axis_Angle);
            [Hindlegs_RawData, Hindlegs_Calculations] = ProcessHindlegsData(TempHindlegsCSV, Row, VideoResolution(1,2), Axis_Angle);
            [Frontlegs_RawData, Frontlegs_Calculations] = ProcessFrontlegsData(TempFrontlegsCSV, Row, VideoResolution(1,2), Axis_Angle);
            
            %Append the different RawData and Calculations together, while maintaining the expected order.
            RawData = [Wings_RawData, Head_RawData, Hindlegs_RawData, Frontlegs_RawData];
            Calculations = [Wings_Calculations, Head_Calculations, Hindlegs_Calculations, Frontlegs_Calculations];
            
            %override current row with the processed data output.
            DLC_RawData(Row,1:Totalnumberofrawdatapoints) = RawData;
            DLC_Calculations(Row,1:Totalnumberofcalculations) =  Calculations;

        end
        
        %Create data_block using raw data points e.g. x,y,conf.
        eval(sprintf('data_block%i = DLC_RawData;',i));
        
        %Create unit_block using calculated values e.g WBA-Right, Axis Angle.
        eval(sprintf('unit_block%i = DLC_Calculations;',i));
        
        %Get the date and time specified in the video name
        %and convert it to epoch time, save the result as ticktimes_block.
        %When analyzing closedloop Expects TempFileName to have the format 
        %WingsControl_Latency_240_10_20230615_104139.640942_20230615_104314.966523_1_VIDEO
        %Or User_Specified_Name_240_10_20230615_104139.640942_20230615_104314.966523_1_VIDEO
        %This is why we use (tempsize-7) e.g. count from the back as that
        %part of the filename is more stable and less likely to change.
        %When analyzing openloop file names of RE-Video_15-Jun-2023 16_17_25.mp4 are expected.
        %tempsize is the number of strings in the name seperated by '_' '.' and ' '
        format longG;
        FileDate = strsplit(TempFileName,{'_','.',' '});
        Tempsize = size(FileDate);
        Tempsize = Tempsize(1,2);
        
        %Work out which video type (TimeMatched, ClosedLoop, OpenLoop) Error prone and needs work.
        if not(isempty(strfind(TempFileList(j).name,'TM_')))
            dateformat = 'yyyyMMdd_HHmmss';
            FileDate = sprintf('%s_%s',FileDate{2},FileDate{3});
        elseif (Tempsize > 8)
            dateformat = 'yyyyMMdd_HHmmss.SSSSSS';
            FileDate = sprintf('%s_%s.%s',FileDate{Tempsize-6},FileDate{Tempsize-5},FileDate{Tempsize-4});
        else
            dateformat = 'dd-MMM-yyyy_HHmmss';
            FileDate = sprintf('%s_%s%s%s',FileDate{Tempsize-3},FileDate{Tempsize-2},FileDate{Tempsize-1},FileDate{Tempsize});
        end

        t1 = datetime(FileDate,'InputFormat',dateformat);
        ticktime = posixtime(t1);
        
        eval(sprintf('ticktimes_block%i = ticktime;',i));
        
        clear DLC_Calculations; %Reset so that existing rows aren't just overridden but the entire structure is replaced. 
        clear DLC_RawData; %Reset so that existing rows aren't just overridden but the entire structure is replaced.
        VideosAnalysed = VideosAnalysed + 1;
    else
        
        % Keywords are case sensitive e.g. a keyword value of 'HindLegs' will not find csv files that include 'Hindlegs'.
        warning('Warning - Could not find the expected CSV files for %s, are all keywords correct?', TempFileName);

    end  
    %Search next folder in the list 
end

fprintf('%i videos were analysed, attempting to save .mat file\n',VideosAnalysed);
DLC_Data_Location = strcat(inputFolderPath,'/',FileDate,'_DLCAnalysis.mat');
save(DLC_Data_Location,'data_block*','unit_block*','ticktimes_block*');
disp('.mat file saved');