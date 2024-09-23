function reencodeImage(inputFolderPath, outputFolderPath, inputParameterPath, systemLatency)

% Check to make sure both file paths are valid before continuing
if(length(inputFolderPath) <= 1 || length(outputFolderPath) <= 1)
    disp('Atleast one file path is invalid');
    return;
end

% Find all mp4 files and add them to an array, then calculate the size of the array
MAT_Array = dir(fullfile(inputParameterPath, '*.mat')); 
% Length of stimuli to loop over
[m,~] = size(MAT_Array);
% Get the names of the .mat files themselves
MAT_FileArray = struct2cell(MAT_Array);
MAT_FileArray = MAT_FileArray(1,:);

% Get list of all images
videoType = inputdlg('Enter image type:', ...
    'Choose video extension', [1 45], ".jpg"); 
imageList = dir(fullfile(inputFolderPath, ['*' videoType]));

% Get all picture names and paths into an array
imageNames = arrayfun(@(x) x.name, imageList, 'UniformOutput', false);
imagePaths = arrayfun(@(x) x.folder, imageList, 'UniformOutput', false);

% Get number of items in directory
imageCount = size(imageList,1);

% Get handle to all image files
for imageNo = 1:imageCount
    imagePaths{imageNo} = string(imagePaths{imageNo}) + '/' + string(imageNames{imageNo});
end

% Get all file times as a string
timeStamps = cellfun(@(x) strrep(strrep(x, '_', ''), '.bmp', ''), imageNames, 'UniformOutput', false);

% Loop over each .mat file to make videos
for filenum = 1:m
    matInput = string(inputParameterPath) + "/" + string(cell2mat(MAT_FileArray(filenum)));

    % Load start and stop times for stimuli and format them nicely
    load(matInput, "timeStartPrecision", "timeEndPrecision");
    timeStartPrecision = strsplit(timeStartPrecision, " ");
    timeEndPrecision = strsplit(timeEndPrecision, " ");
    startTime = str2double(strrep(timeStartPrecision{2}, ':', '')) + systemLatency;
    endTime = str2double(strrep(timeEndPrecision{2}, ':', ''));
    
    % Allocate space for speed
    startConditionMet = zeros(imageCount,1);
    stopConditionMet = zeros(imageCount,1);
    
    % Create boolean array for triggers
    for imageNo = 1:imageCount
        % Logical array condition for start trigger time
        startConditionMet(imageNo) = str2double(timeStamps{imageNo, 1}) > startTime;
        stopConditionMet(imageNo) = str2double(timeStamps{imageNo, 1}) > endTime;
    end
    
    % Find time moment when trigger condition has been met
    startMomentIndex = find(diff(startConditionMet)==1, 1, 'first');
    if isempty(startMomentIndex)
        fsprintf("No matching frames found for video %s", MAT_FileArray(filenum))
        continue
    end
    % Determine which frame timestamp is closer to the actual start of the
    % stimuli
    t0 = abs(startTime - str2double(timeStamps{startMomentIndex}));
    t1 = abs(startTime - str2double(timeStamps{startMomentIndex + 1}));
    if t1 < t0
        startMomentIndex = startMomentIndex + 1;
    end
    stopMomentIndex = find(diff(stopConditionMet)==1, 1, 'first');
    
    % Rename all files to something easy for ffmpeg to work with
    newPath = cell(stopMomentIndex - startMomentIndex);
    for imageNo = 1:(stopMomentIndex - startMomentIndex) 
        newPath{imageNo} = string(inputFolderPath) + "/recording" + num2str(imageNo) + ".bmp";
        movefile(imagePaths{imageNo + startMomentIndex}, newPath{imageNo})
    end

    % s is a space ' ' and 34 is a " to encapsulate text incase there are spaces in the file path

    ffFilename = cell2mat(MAT_FileArray(filenum));
    ffFilename = split(ffFilename, '.mat');
    ffFilename = [ffFilename{1}, '.mp4'];
    ffoutput = [outputFolderPath,'/RE-', ffFilename];
    % Take in all images (in chronological order) and make a 100 FPS video
    % command = 'ffmpeg -i "' + inputFolderPath + 'recording%d.jpg" -c:v libx264 "' ...
    %     + ffoutput + '" -r 100 test.mp4';
    command = ['ffmpeg -i ', 34, inputFolderPath, '/recording%d.bmp', 34, ...
        ' -c:v libx264 ', 34, ffoutput, 34, ...
        ' -r 100'];   
    [~, ~] = system(command, '-echo');

    % Put file names back where they belong
    for imageNo = 1:(stopMomentIndex - startMomentIndex) 
        movefile(newPath{imageNo}, imagePaths{imageNo + startMomentIndex})
    end
end
