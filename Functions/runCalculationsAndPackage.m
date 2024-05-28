% OL Step 3 - Creating the .mat file: Written by Raymond Aoukar : June 2023
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

function runCalculationsAndPackage(filePath)

% Let the user know what is going on
disp('We will now begin creating the VideoName_DLC_Analysis.mat file')

% NEEDS TO BE ACCURATE
VideoResolution = [320,240];        %#ok<NASGU> % Used to invert Y values by using the frame height, error supressed as value is used in an 'eval' statement later
videoType = '.mp4';                 % Used to identify video files
VideosAnalysed = 0;                 % Counter used to display progress to user

load(filePath, "videoList", "modelList", "modelListSize", ...
    "totalNumberOfCalculations", "totalNumberOfRawDataPoints", "inputFolderPath")

% Search each folder and locate all valid .csv files.
% For each valid video provided
for video = 1:size(videoList, 1)

    % Print a status message so the user knows what's going on internally
    message = sprintf('Analysing video %d out of %d\n',video, size(videoList, 1));
    disp(message);

    
    % Find all files within the folder
    TempFileList = dir(fullfile(videoList(video).folderpath));
    TempCSVFiles = [];
    
    % Seperate the name of the file from its file extension e.g. .mp4
    TempFileName = strsplit(videoList(video).name,videoType);
    TempFileName = TempFileName{1};
    
    % Search through each file in the directory and find the csv files
    % For each file remembering to skip the first two as they are . ..
    for j = 3:size(TempFileList)
        
        % If the file contains the name of the video (a convention followed by DLC)
        if not(isempty(strfind(TempFileList(j).name,TempFileName)))
            
            % If the file is a csv e.g. contains .csv
            if not(isempty(strfind(TempFileList(j).name,'.csv')))
                
                for k = 1:modelListSize
                    
                    % If the csv contains the keyword e.g. Wings, Head, Hindlegs, Frontlegs.
                    if not(isempty(strfind(TempFileList(j).name,modelList(k).keyword)))
                        TempCSVFiles(k).keyword = modelList(k).keyword;
                        TempCSVFiles(k).filepath = strcat(videoList(video).folderpath,'/',TempFileList(j).name);
                    end
                end
            end
        end
    end
    
    % Get size of CSVList (we are only interested in Y value)
    [~,CSVListSize] = size(TempCSVFiles);
    
    % Before we begin analysis
    % Check if we have the correct amount of CSV files (there should be one file for each model).
    if CSVListSize ~= modelListSize
        % Keywords are case sensitive e.g. a keyword value of 'HindLegs' will not find csv files that include 'Hindlegs'.
        warning('Warning - Could not find the expected CSV files for %s, are all keywords correct?', TempFileName);
        return
    end

    for model = 1:modelListSize
        eval("Temp" + modelList(model).name + "CSV = csvread(TempCSVFiles(" + model + ").filepath,3,0);");
    end

    % Initialise entire data set with arbitrary values, stops the script from continuously allocating memory later on.
    % All csv files should be the same size
    [Totalframes,~] = size(TempWingsCSV);
    DLC_RawData(Totalframes,1:totalNumberOfRawDataPoints) = zeros(1,totalNumberOfRawDataPoints); %#ok<AGROW>
    DLC_Calculations(Totalframes,1:totalNumberOfCalculations) = zeros(1,totalNumberOfCalculations); %#ok<AGROW>

    % For each row in the CSV files we run the following calculations
    for frame = 1:Totalframes
        % Process each CSV file using the relevant calculations
        RawData = [];
        Calculations = [];
        Axis_Angle = 0; %#ok<NASGU>
        for model = 1:modelListSize
            key = modelList(model).name;
            noCalcs = modelList(model).calculations; %#ok<NASGU>
            [Model_RawData, Model_Calculations, Axis_Angle, Column_Names] = ...
                eval("Process" + key + "Data(Temp" + key + "CSV, Row, VideoResolution(1,2), Axis_Angle, noCalcs);"); %#ok<ASGLU>
            % Append the different RawData and Calculations together, while maintaining the expected order.
            RawData = [RawData, Model_RawData];
            if Model_Calculations ~= 0
                Calculations = [Calculations, Model_Calculations];
            end

        end

        % Package the names of all columns into the first row
        if frame == 1

        end
        
        
        actualDataSize = size (RawData, 2);
        % Override current row with the processed data output.
        DLC_RawData(frame + 1,1:actualDataSize) = RawData;
        DLC_Calculations(frame + 1,1:length(Calculations)) = Calculations;

    end
    

    
    % Create data_block using raw data points e.g. x,y,conf.
    eval(sprintf('data_block%i = DLC_RawData;',video));
    
    % Create unit_block using calculated values e.g WBA-Right, Axis Angle.
    eval(sprintf('unit_block%i = DLC_Calculations;',video));
    
    % Get the date and time specified in the video name
    % and convert it to epoch time, save the result as ticktimes_block.

    % We use a function called 'regexp' to detect patterns in the filename
    % to find dates. Values found in expected formats will be assigned into
    % variables, so the filename can be anything as long as it has a valid
    % datetime format.

    format longG;
    FileDate = strsplit(TempFileName,{'_','.',' '});
    
    % Write down expected datetime formats
    patterns = [ ...
        '(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})_(?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})|'   ... % yyyyMMdd_HHmmss
        '(?<day>\d{2})-(?<month>\w+)-(?<year>\d{4}) (?<hours>\d{2})_(?<minutes>\d{2})_(?<seconds>\d{2})|' ... % dd-MMM-yyyy HH_mm_ss
        '(?<day>\d{2})-(?<month>\w+)-(?<year>\d{4})_(?<hours>\d{2})(?<minutes>\d{2})(?<seconds>\d{2})'        % dd-MMM-yyyy_HHmmss
    ];

    % Compare against the name of the file
    m = regexp(TempFileName, patterns,'names');

    if length(m.month) > 2
        monthNumber = convertMonth(m.month);
    end

    % Depending on the match, convert into epoch (posix) time
    t1 = datetime(str2double(m.year), monthNumber, str2double(m.day), str2double(m.hours)...
        , str2double(m.minutes), str2double(m.seconds));
    ticktime = posixtime(t1); %#ok<NASGU> Used in below eval
    
    eval(sprintf('ticktimes_block%i = ticktime;',video));
    
    clear DLC_Calculations; %Reset so that existing rows aren't just overridden but the entire structure is replaced. 
    clear DLC_RawData; %Reset so that existing rows aren't just overridden but the entire structure is replaced.
    VideosAnalysed = VideosAnalysed + 1;
    %Search next folder in the list 
    
    % Clear analysis video message for a clean command window 
    for character = 1 : length(message) + 1
        fprintf('\b')
    end
end

FileDate = strcat(m.day,'-', m.month,'-', m.year,'_', m.hours, m.minutes, m.seconds);
fprintf('%i videos were analysed, attempting to save .mat file\n',VideosAnalysed);
DLC_Data_Location = strcat(inputFolderPath,'/',FileDate,'_DLCAnalysis.mat');
save(DLC_Data_Location,'data_block*','unit_block*','ticktimes_block*');
disp('.mat file saved');


function month = convertMonth(month)
month = lower(month);
switch month
    case {'january', 'jan'}
        month = 1;
    case {'february', 'feb'}
        month = 2;
    case {'march', 'mar'}
        month = 3;
    case {'april', 'apr'}
        month = 4;
    case 'may'
        month = 5;
    case {'june', 'jun'}
        month = 6;
    case {'july', 'jul'}
        month = 7;
    case {'august', 'aug'}
        month = 8;
    case {'september', 'sep'}
        month = 9;
    case {'october', 'oct'}
        month = 10;
    case {'november', 'nov'}
        month = 11;
    case {'december', 'dec'}
        month = 12;
end




