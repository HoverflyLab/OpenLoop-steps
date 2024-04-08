function [keyword, labels] = dlcNamesFcn(config)
% Read the config file
dlcConfig = readlines(config);

%% Obtain the name of the model
% Concenate entire config file into 1 string
keyword = strjoin(dlcConfig);

% Split entire string just to get model name on its own
keyword = split(keyword, "Task:");
keyword = keyword(2);
keyword = split(keyword, "scorer:");
keyword = keyword(1);

% Remove any whitespace from strings
keyword = strtrim(keyword);

%% Obtain the labels of the file
% Concenate entire config file into 1 string
labels = strjoin(dlcConfig);

% Split entire string just to get labels on their own
labels = split(labels, "bodyparts:");
labels = labels(2);
labels = split(labels, "#");
labels = labels(1);

% Split labels into a string array
labels = split(labels, "- ");
% Remove any whitespace from strings
labels = strtrim(labels);
% Remove any empty entries
labels(all(strcmp(labels,""),2),:) = [];
