function [Frontlegs_RawData, Frontlegs_Calculations, Axis_Angle, Column_Names] = ProcessFrontLegsData(usePadding, TempFrontlegsCSV, Row , FrameHeight, Axis_Angle, calculations)
%PROCESSFRONTLEGSDATA Calculates Hinge-Distal Angle and Distance, + confidence : for Left and Right
%   Detailed explanation goes here

    % Set these to 0 in case calculations aren't required by user
    Frontlegs_Calculations = 0;
    Column_Names.calculated = "No calculations made for front legs data";

    % Check if we're using this function with data, if not, check if we want to
    % pad the results with empty space to make it easier for the user's
    % analysis scripts
    if ~exist('TempFrontlegsCSV', 'var') && usePadding == 1
        % Recreate the column names so the user can see what's missing
        Column_Names.raw = getRawNames();
        Column_Names.calculated = getCalcNames();
        % Pad out zeros for the unused data
        Frontlegs_RawData = zeros(1,length(column_Names.raw));
        Frontlegs_Calculations = zeros(1,length(Column_Names.calculated));
        % We were only padding out values, so go back to the main code
        return
    elseif ~exist('TempFrontlegsCSV', 'var') && usePadding ~= 1
        return
    end

    % IMPORTANT - DLC Y values are inverted so we need to take the Y
    %value given from the resolution of the frame, this allows us to work with Y values that
    %match standard graphing conventions. e.g. X value increases left to right, Y value increases bottom to top.
    
    % Read in Frontlegs label data
    Frontlegs_Hinge_Right_X = TempFrontlegsCSV(Row,2);
    Frontlegs_Hinge_Right_Y = FrameHeight - TempFrontlegsCSV(Row,3);
    Frontlegs_Hinge_Right_Confidence = TempFrontlegsCSV(Row,4);

    Frontlegs_Distal_Right_X = TempFrontlegsCSV(Row,5);
    Frontlegs_Distal_Right_Y = FrameHeight - TempFrontlegsCSV(Row,6);
    Frontlegs_Distal_Right_Confidence = TempFrontlegsCSV(Row,7);

    Frontlegs_Hinge_Left_X = TempFrontlegsCSV(Row,8);
    Frontlegs_Hinge_Left_Y = FrameHeight - TempFrontlegsCSV(Row,9);
    Frontlegs_Hinge_Left_Confidence = TempFrontlegsCSV(Row,10);

    Frontlegs_Distal_Left_X = TempFrontlegsCSV(Row,11);
    Frontlegs_Distal_Left_Y = FrameHeight - TempFrontlegsCSV(Row,12);
    Frontlegs_Distal_Left_Confidence = TempFrontlegsCSV(Row,13);
    
    % Populate RawData into an array with the data provided by each label.
    Frontlegs_RawData = [Frontlegs_Hinge_Right_X , Frontlegs_Hinge_Right_Y , Frontlegs_Hinge_Right_Confidence , ...
                         Frontlegs_Distal_Right_X, Frontlegs_Distal_Right_Y, Frontlegs_Distal_Right_Confidence, ...
                         Frontlegs_Hinge_Left_X  , Frontlegs_Hinge_Left_Y  , Frontlegs_Hinge_Left_Confidence  , ...
                         Frontlegs_Distal_Left_X , Frontlegs_Distal_Left_Y , Frontlegs_Distal_Left_Confidence];

    % Populate the column names for data readability
    Column_Names.raw  = getRawNames();

    % FRONTLEGS CALCULATIONS
    %Calculate the angle of the leg from the Hinge to the Distal.
    %Calculate the distance from the Hinge point to the Distal.
    
    if calculations == 'y'
        % Angle of the Frontleg
        %Calculate the Slope Height and Width of the Hinge point to Distal point.
        HingeDistal_Width_Right = Frontlegs_Distal_Right_X - Frontlegs_Hinge_Right_X;
        HingeDistal_Height_Right = Frontlegs_Distal_Right_Y - Frontlegs_Hinge_Right_Y;
        
        %Calculates the arctan and returns the answer in degrees
        HingeDistal_Angle_Right = atand(HingeDistal_Width_Right/HingeDistal_Height_Right);
        if(HingeDistal_Height_Right >= 0)
            HingeDistal_Angle_Right = 180 - abs(HingeDistal_Angle_Right - Axis_Angle);                   
        else
            HingeDistal_Angle_Right = abs(HingeDistal_Angle_Right - Axis_Angle);
        end
        
        %Calculate HingeDistal_Angle_Confidence
        HingeDistal_Angle_Right_Confidence = Frontlegs_Hinge_Right_Confidence * Frontlegs_Distal_Right_Confidence;
        
        
        %Calculate the Slope Height and Width of the Hinge point to Distal point.
        HingeDistal_Width_Left = Frontlegs_Distal_Left_X - Frontlegs_Hinge_Left_X;
        HingeDistal_Height_Left = Frontlegs_Distal_Left_Y - Frontlegs_Hinge_Left_Y;
        
        %Calculates the arctan and returns the answer in degrees
        HingeDistal_Angle_Left = atand(HingeDistal_Width_Left/HingeDistal_Height_Left);
        if(HingeDistal_Height_Left >= 0)
            HingeDistal_Angle_Left = 180 - abs(HingeDistal_Angle_Left - Axis_Angle);                   
        else
            HingeDistal_Angle_Left = abs(HingeDistal_Angle_Left - Axis_Angle);
        end
        
        %Calculate HingeDistal_Angle_Confidence
        HingeDistal_Angle_Left_Confidence = Frontlegs_Hinge_Left_Confidence * Frontlegs_Distal_Left_Confidence;
        
        % Distance from Hinge to Distal
        
        %Calculate HingeDistal_Distance
        %Calculate HingeDistal_Distance_Confidence
        HingeDistal_Distance_Right = sqrt((HingeDistal_Width_Left^2) + (HingeDistal_Height_Left^2));
        HingeDistal_Distance_Right_Confidence = Frontlegs_Hinge_Right_Confidence * Frontlegs_Distal_Right_Confidence;
        
        
        %Calculate HingeDistal_Distance
        %Calculate HingeDistal_Distance_Confidence
        HingeDistal_Distance_Left = sqrt((HingeDistal_Width_Left^2) + (HingeDistal_Height_Left^2));
        HingeDistal_Distance_Left_Confidence = Frontlegs_Hinge_Left_Confidence * Frontlegs_Distal_Left_Confidence;
        
        % Assemble Calculations into an array
        Frontlegs_Calculations  = [HingeDistal_Angle_Right   , HingeDistal_Angle_Right_Confidence   , ...
                                   HingeDistal_Distance_Right, HingeDistal_Distance_Right_Confidence, ...
                                   HingeDistal_Angle_Left    , HingeDistal_Angle_Left_Confidence    , ...
                                   HingeDistal_Distance_Left , HingeDistal_Distance_Left_Confidence];

        % Assemble string array of all calculation names
        Column_Names.calculated = getCalcNames();
    elseif calculations ~= 'y' && usePadding == 1
        Column_Names.calculated = getCalcNames();
        Frontlegs_Calculations = zeros(1,length(Column_Names.calculated));
    end
end

% Use these two functions to handle requests for all names of the dataset
function names = getRawNames()
names = ["Frontlegs_Hinge_Right_X" , "Frontlegs_Hinge_Right_Y" , "Frontlegs_Hinge_Right_Confidence" , ...
         "Frontlegs_Distal_Right_X", "Frontlegs_Distal_Right_Y", "Frontlegs_Distal_Right_Confidence", ...
         "Frontlegs_Hinge_Left_X"  , "Frontlegs_Hinge_Left_Y"  , "Frontlegs_Hinge_Left_Confidence"  , ...
         "Frontlegs_Distal_Left_X" , "Frontlegs_Distal_Left_Y" , "Frontlegs_Distal_Left_Confidence"];
end
function names = getCalcNames()
names = ["HingeDistal_Angle_Right"   , "HingeDistal_Angle_Right_Confidence"   , ...
         "HingeDistal_Distance_Right", "HingeDistal_Distance_Right_Confidence", ...
         "HingeDistal_Angle_Left"    , "HingeDistal_Angle_Left_Confidence"    , ...
         "HingeDistal_Distance_Left" , "HingeDistal_Distance_Left_Confidence"];
end