function [modelList, inputStrings, inputDefaults, boxSize, keykey] = findModelsUsed(video, csvFiles)
% function findModelsUsed: Using a single video, determine which models 
% the user employed when doing their DLC analysis

% Get just the video name on its own
videoName = video.name;
videoName = strsplit(videoName, '.mp4');
videoName = videoName{1};

% Grab only the .csv files relating to the single video
allFiles = {csvFiles.name};
singleVidFiles = regexp(allFiles, videoName, 'match');
singleVidFiles = singleVidFiles(~cellfun('isempty', singleVidFiles));

% Ewwww this is a gross and horrible fix! Hell no!
for i = 1:length(singleVidFiles)
    singleVidFiles{i} = singleVidFiles{i}{1};
end

% Search via strings which models were used
% Order of model search: wings, head, front legs, hind legs
models = ["Wings", "Head", "FrontLegs", "HindLegs"];
modelList = cell(1,length(models));
inputStrings = cell(1, length(models));
inputDefaults = cell(1, length(models));

% Loop over all models
count = 1;
for i = 1:length(models)
    tempModelTest = regexpi(allFiles, models(i));
    tempModelTest = tempModelTest(~cellfun('isempty', tempModelTest));
    % If we've found a match for a model, add to the list!
    if ~isempty(tempModelTest)
        modelList{count} = models(i);
        inputStrings{count} = sprintf('Perform ''%s'' model calculations? y/n', models(i));
        inputDefaults{count} = 'y';
        count = count + 1;
    end
end

% Cull model lists if they aren't full
modelList = modelList(~cellfun('isempty', modelList));
inputStrings = inputStrings(~cellfun('isempty', inputStrings));
inputDefaults = inputDefaults(~cellfun('isempty', inputDefaults));

% Assign boxSize according to how many models we have
boxSize = [1, 45];
for i = 1:length(inputStrings) - 1
    boxSize = [boxSize; 1, 45];
end
