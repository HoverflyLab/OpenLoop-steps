% Video_DLCBodyAngleAnalysis Script : Written by Raymond Aoukar : June 2023
%
% This script finds all video files in the selected folder and its sub folders that do
% not include the word 'labeled' (just incase labeled videos also exist in
% the directory). Videos are identified by the VideoType variable which the
% user should set, e.g. .mp4, .avi
%
% After the video files have been found each video will then be analysed by
% the specified DEEPLABCUT models contained within the ModelList structure.
% Ipythoncommands.py script is necessary to run this analysis and its filepath needs to be correctly set.
% The user should also ensure the ModelList contains the correct information.
% e.g. the filepath variable contains the full filepath leading to the config.yaml file.
% nooflabels, labels and calculations also must be accurate.
%
% After the videos have been analyzed the CSV files containing the data will be located.
% This process works by checking for the keyword (Case sensitive) associated with each model.
% e.g Wings, Head, Backlegs, Frontlegs.
%
% This allows us to grab the relevant CSV files if they exist and make some
% assumptions about the point data that they contain e.g. we know that the
% CSV files created by the wings model should contain the following points in order
% Wings_Hinge_Right, Wings_Distal_Right, Wings_Hinge_Left, Wings_Distal_Left, Wings_Thorax_Upper, Wings_Thorax_Lower 
%
% After we have found each CSV file we then read in and calculate the required values one row at a time.
% Making sure to keep the Raw data seperate from our calculations.
% Once we have read in each row we then package the raw data into the data_block and calculations into the unit_block.
%
% The resulting .mat file will contain data_blocks, unit_blocks and ticktime_blocks.
% data_blocks contain the raw data e.g. x,y,confidence for each label.
% unit_blocks contain calculated data e.g. WBA_Right, WBA_Right_Confidence, Axis_Angle, Axis_Angle_Confidence.
% Note: Confidence values for calculations are obtained by multiplying the relevant confidence values together.
% ticktime_blocks are equal to the trial start time since epoch 

%% Hard Coded Variables (must be accurate)
VideoResolution = [320,240];        % Used to invert Y values by using the frame height
AnacondaEnvironment = 'DLC2';       % Name of the Anaconda Environment that houses the version of DLC we wish to use.
VideoType = '.mp4';                 % Used to identify video files
MaximumSubFolderDepth = 8;          % Safety to stop this script grabbing too many video files
MaximumFolderCount = 500;           % Safety to stop this script grabbing too many video files
IpythoncommandsFilePath = '/home/hoverfly/Desktop/MatlabScripts/OpenLoop/Ipythoncommands.py'; % This script is essential for DLC Analysis to run

%Skippause can be used to toggle pauses on or off allowing you to more easily follow along with the output.
Skippause = 1; % 0 for false (pause) : 1 for true (don't pause)

%% Model Information (must be accurate)
%A list of the DLC models each video should be analysed by
%keyword refers to a Unique ID that can be used to identify each model's .csv files
ModelList = [];
ModelList(1).keyword = 'Wings';
ModelList(1).filepath = '/home/hoverfly/Desktop/DLC2_Projects/AllModelsTrained_2023-04-24/TetheredFlight_Wings-HoverTeam-2023-04-24/config.yaml';
ModelList(1).nooflabels = 6; %number of body parts being tracked by this model.
ModelList(1).labels = ['Wings_Hinge_Right,','Wings_Distal_Right,','Wings_Hinge_Left,','Wings_Distal_Left,','Wings_Thorax_Upper,','Wings_Thorax_Lower'];
ModelList(1).calculations = 6; %Number of variables being calculated : WBA Right and Left, + confidence for each, + LongitudinalAxis (Theta_Angle) and its confidence

ModelList(2).keyword = 'Head';
ModelList(2).filepath = '/home/hoverfly/Desktop/DLC2_Projects/AllModelsTrained_2023-04-24/TetheredFlight_Head-HoverTeam-2023-04-24/config.yaml';
ModelList(2).nooflabels = 6; %number of body parts being tracked by this model.
ModelList(2).labels = ['Head_Midline_Anterior_1,','Head_Midline_2,','Head_Midline_3,','Head_Midline_4,','Head_Midline_5,','Head_Midline_Posterior_1'];
ModelList(2).calculations = 2; %Number of variables being calculated : Slope + confidence

ModelList(3).keyword = 'BackLegs';
ModelList(3).filepath = '/home/hoverfly/Desktop/DLC2_Projects/AllModelsTrained_2023-04-24/TetheredFlight_BackLegs-HoverTeam-2023-04-24/config.yaml';
ModelList(3).nooflabels = 8; %number of body parts being tracked by this model.
ModelList(3).labels = ['Hindlegs_Proximal_Right,','Hindlegs_Knee_Right,','Hindlegs_Distal_Right,','Hindlegs_Abdomen_Right,','Hindlegs_Proximal_Left,','Hindlegs_Knee_Left,','Hindlegs_Distal_Left,','Hindlegs_Abdomen_Left'];
ModelList(3).calculations = 16; %Number of variables being calculated : ProximalKnee Angle and Distance, KneeDistal Angle and Distance, + confidence for each, Right and Left

ModelList(4).keyword = 'FrontLegs';
ModelList(4).filepath = '/home/hoverfly/Desktop/DLC2_Projects/AllModelsTrained_2023-04-24/TetheredFlight_FrontLegs-HoverTeam-2023-04-24/config.yaml';
ModelList(4).nooflabels = 4; %number of body parts being tracked by this model.
ModelList(4).labels = ['Frontlegs_Hinge_Right,','Frontlegs_Distal_Right,','Frontlegs_Hinge_Left,','Frontlegs_Distal_Left'];
ModelList(4).calculations = 8; %Number of variables being calculated : Hinge-Distal Angle and Distance, + confidence, Right and Left

%% Variables
DirectoryList = [];
VideoList = [];
Results = [];
VideosAnalysed = 0;

%Get size of ModelList (we are only interested in Y value)
[Temp,ModelListSize] = size(ModelList);
Totalnumberofcalculations = 0;
Totalnumberofrawdatapoints = 0;

if ~isfile(IpythoncommandsFilePath)
    warning('IpythoncommandsFilePath is not valid')
    return;
end

for i = 1:ModelListSize
    
    if ~isfile(ModelList(i).filepath)
        warning('%s model does not have a valid filepath',ModelList(i).keyword)
        return;
    end

    %Let the user know about the expected data points and their order
    fprintf('This script expects the %s model to have %i labels, identically named and ordered as follows\n',ModelList(i).keyword,ModelList(i).nooflabels);
    disp(strrep(ModelList(i).labels,',',', '));
    disp(' ');
    
    %Get the total number of calculations that will be required
    Totalnumberofcalculations = Totalnumberofcalculations + ModelList(i).calculations;
    Totalnumberofrawdatapoints = Totalnumberofrawdatapoints + (ModelList(i).nooflabels * 3); %each label has a value for (x,y,confidence)
    
    %Get a list of all the labels
    if i == 1
        DLC_Field_Names = ModelList(1).labels;
    else
        DLC_Field_Names = strcat(DLC_Field_Names,',',ModelList(i).labels);
    end 
    pause(1);
end

if(Skippause == 0)
    pause(3)
end

% Ask user to locate the inputFolderPath where the videos they wish to analyse should be located
inputFolderPath = uigetdir('/home/hoverfly/Desktop/', 'Location of Videos to analyse');

% Check to make sure the file path is valid before continuing
if(length(inputFolderPath) <= 1)
    disp('Chosen file path is invalid');
    return;
end

Temp = strsplit(inputFolderPath,'/');

%Add only the Initial Directory to list
DirectoryList = dir(fullfile(inputFolderPath));
DirectoryList = DirectoryList(2);
DirectoryList(1).name = Temp{end};
DirectoryList(1).filepath = inputFolderPath;

%Set initial DirectoryCount
PrevDirectoryCount = 0;

%Find all valid Folders upto the MaximumSubFolderDepth
for i = 1:MaximumSubFolderDepth
    
    %Set NewDirectoryCount which is the current number of valid Directories
    NewDirectoryCount = size(DirectoryList,1);
    
    %Safety Check to make sure we don't accidently add every folder on the system by selecting a folder that is too high up the hierarchy.
    if(NewDirectoryCount > MaximumFolderCount)
        warning('Warning - Tried to search %i folders when the Maximum is %i. If you selected the right folder, remove this check or increase MaximumFolderCount',NewDirectoryCount,MaximumFolderCount);
        return;
    end
    
    %For each of the new directories we have not already searched
    for j = PrevDirectoryCount+1:NewDirectoryCount
        %Locate valid directories within the provided folder and add them to the DirectoryList.
        DirectoryList = [DirectoryList;FindSubFolders(DirectoryList(j).filepath,0)];
    end
    
    %Update PrevDirectoryCount so we know which folders have been searched.
    PrevDirectoryCount = NewDirectoryCount;  
    %Move on to next loop in order to search the new folders that were added this loop
end

fprintf('Total number of directories being searched is %i\n',size(DirectoryList,1));

%Search each folder and locate all valid video files.
%For each valid folder provided
for i = 1:size(DirectoryList)
    
    %Find all files within the folder
    TempFileList = dir(fullfile(DirectoryList(i).filepath));
    
    %For each file remembering to skip the first two as they are . ..
    for j = 3:size(TempFileList)
        
        %If the file contains a valid video type e.g. filename contains .mp4
        if not(isempty(strfind(TempFileList(j).name,VideoType)))
            
            %If the video is not a labeled video e.g. filename contains labeled
            if isempty(strfind(TempFileList(j).name,'labeled'))
                
                %Add folderpath to structure
                TempFileList(j).folderpath = DirectoryList(i).filepath;
                
                %Add filepath to structure
                TempFileList(j).filepath = strcat(DirectoryList(i).filepath,'/',TempFileList(j).name);
                
                %Add to VideoList
                VideoList = [VideoList;TempFileList(j)];

            end
        end
    end

    %Search next folder in the list

end

fprintf('Total number of videos being processed is %i\n',size(VideoList,1));

if size(VideoList) < 1
    warning('Warning - There are no videos to analyse');
    return;
end

%In order to pass several commands to the same (terminal / shell) we need to collate them into a single string.
AnalysisCommand = ['source /home/hoverfly/anaconda3/bin/activate' ' ' AnacondaEnvironment]; %conda activate DLC2 equivalent (for some reason "conda activate DLC2" doesn't work in this context so we use this alternative)
AnalysisCommand = strcat(AnalysisCommand,';ipython'); % Add the start of the next command 
AnalysisCommand = [AnalysisCommand ' ' '''' IpythoncommandsFilePath '''']; % Add a space and then the path to python file encapsulated in '
AnalysisCommand = [AnalysisCommand ' ' '''']; % Adds a space and begins encapsulation of the argument being passed to the python file in ' as '''' converts to a single '

for i = 1:size(VideoList)
     
    TempVideoPath = VideoList(i).filepath;
    
    for j = 1:ModelListSize
        
        TempModelPath = ModelList(j).filepath;    
        %Create the command deeplabcut required to analyze a video
        TempCommand = ['deeplabcut.analyze_videos(',34,TempModelPath,34,',[',34,TempVideoPath,34,'],save_as_csv=True)'];

        %Passes through command responsible for Analysing each video 
        unix(strcat(AnalysisCommand,TempCommand,''''),'-echo'); % concatenate analysis command and temp command then encapsulation the argument in '

    end 

    disp('---------');
    fprintf('%i out of %i videos have been analyzed by deeplabcut\n',i,(size(VideoList,1)));
    disp('---------');

end

if Skippause == 0
    pause(2); %This is here only so you can see how many videos are about to be analysed
end

if Skippause == 0
    pause(1);
end

%Let the user know what is going on
disp('We will now begin creating the VideoName_DLC_Analysis.mat file')

if Skippause == 0
    pause(1);
end

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
    [Temp,CSVListSize] = size(TempCSVFiles);
    
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
        [Totalframes,Temp] = size(TempWingsCSV);
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