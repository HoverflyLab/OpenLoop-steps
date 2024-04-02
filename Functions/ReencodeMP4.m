% Written by Raymond Aoukar and Chris Johnston - last updated 2023-04-11
% This script is used to re-encode the video files produced by Guvcview to work properly with Deeplabcut 
clear all

% Name of the folder in the folder path we should return to next time we need to select our input folder
inputParentFolderName = 'Saved Data';
% Default file path to be used if we could not find the inputParentFolder 
inputParentFolderPath = '/home/hoverfly/Documents/';
% Name of the folder in the folder path we should return to next time we need to select our output folder
outputParentFolderName = 'OpenLoopData';
% Default file path to be used if we could not find the outputParentFolder
outputParentFolderPath = '/home/hoverfly/Documents/';

% check if persistent variables file exists, if so load the last folderpaths provided by the user.
if(exist('PersistentVariables.mat','file'))
    disp('Loading folder paths');
    load('PersistentVariables','inputParentFolderPath','outputParentFolderPath');
end

% Ask user to locate the inputFolderPath where the videos they wish to encode should be located 
% and the outputFilePath where they wish the Re-encoded versions to be stored
inputFolderPath = uigetdir(inputParentFolderPath, 'Location of Videos to encode');
outputFolderPath = uigetdir(outputParentFolderPath, 'Location to store Re-encoded videos');

% Check to make sure both file paths are valid before continuing
if(length(inputFolderPath) <= 1 || length(outputFolderPath) <= 1)
    disp('Atleast one file path is invalid');
    return;
end

% Look for a folder with the same name as the inputParentFolderName variable within the inputFolderPath
stringLocation = strfind(inputFolderPath,inputParentFolderName);

% If we found the inputParentFolderName get rid of the rest of the folder
% path so we can save this and return to this folder next time.
if stringLocation >= 1
    inputParentFolderPath = inputFolderPath(1:(stringLocation + length(inputParentFolderName)));
end

% Look for a folder with the same name as the outputParentFolderName variable within the outputFolderPath
stringLocation = strfind(inputFolderPath,inputParentFolderName);

% If we found the outputParentFolderName get rid of the rest of the folder
% path so we can save this and return to this folder next time.
if stringLocation >= 1
    outputParentFolderPath = outputFolderPath(1:(stringLocation + length(outputParentFolderName)));
end

% Save the file paths provided by the user for next time
save('PersistentVariables','inputParentFolderPath','outputParentFolderPath');

% Find all mp4 files and add them to an array, then calculate the size of the array
MP4_Array = dir(fullfile(inputFolderPath, '*.mp4')); 
[m,n] = size(MP4_Array);
MP4_FileArray = struct2cell(MP4_Array);
MP4_FileArray = MP4_FileArray(1,:);

% Creates a number of commands that will be used to re-encode the video files to work with Deeplabcut
ffmpeg = '/usr/bin/ffmpeg -i';
s = ' ';

for filenum = 1:m
    ffinput = [inputFolderPath,'/', cell2mat(MP4_FileArray(filenum))];
    ffoutput = [outputFolderPath,'/RE-', cell2mat(MP4_FileArray(filenum))];
    
    %20220214 Chris updated; this is for camera output setting with
    %YUYV-422 as YUYV 422 is cameras native input
    
    %s is a space ' ' and 34 is a " to encapsulate text incase there are spaces in the file path
    ffcombine = [ffmpeg, s, 34, ffinput, 34, ' -pix_fmt yuv422p', s, '-crf 0 -c:v libx264 ', 34, ffoutput, 34];   
    %Used for reencoding video files prior to 2022-02-14
    %ffcombine = [ffmpeg, s, 34, ffinput, 34, ' -pix_fmt yuv420p', s, '-crf 0 -c:v libx264 ', 34, ffoutput, 34];
    unix(ffcombine);
end