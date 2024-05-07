% Written by Raymond Aoukar and Chris Johnston - last updated 2023-04-11
% This script is used to re-encode the video files produced by Guvcview to work properly with Deeplabcut 
function reencodeVideo(inputFolderPath, outputFolderPath)

% Check to make sure both file paths are valid before continuing
if(length(inputFolderPath) <= 1 || length(outputFolderPath) <= 1)
    disp('Atleast one file path is invalid');
    return;
end

% Find all mp4 files and add them to an array, then calculate the size of the array
MP4_Array = dir(fullfile(inputFolderPath, '*.mp4')); 
[m,~] = size(MP4_Array);
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
