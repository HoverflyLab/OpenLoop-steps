function [Hindlegs_RawData, Hindlegs_Calculations, Axis_Angle, Column_Names] = ProcessHindLegsData(usePadding, TempHindlegsCSV, Row , FrameHeight, Axis_Angle, calculations)
%PROCESSHINDLEGSDATA Proximal-Knee Angle and Distance, Knee-Distal Angle and Distance, Area, + confidence for each, Right and Left

    % IMPORTANT - DLC Y values are inverted so we need to take the Y
    %value given from the resolution of the frame, this allows us to work with Y values that
    %match standard graphing conventions. e.g. X value increases left to right, Y value increases bottom to top.

    % Check if we're using this function with data, if not, check if we want to
    % pad the results with empty space to make it easier for the user's
    % analysis scripts
    if ~exist('TempHindlegsCSV', 'var') && usePadding == 1
        % Recreate the column names so the user can see what's missing
        Column_Names.raw = getRawNames();
        Column_Names.calculated = getCalcNames();
        % Pad out zeros for the unused data
        Hindlegs_RawData = zeros(1,length(column_Names.raw));
        Hindlegs_Calculations = zeros(1,length(Column_Names.calculated));
        % We were only padding out values, so go back to the main code
        return
    elseif ~exist('TempHindlegsCSV', 'var') && usePadding ~= 1
        return
    end
    
    % Set these to 0 in case calculations aren't required by user
    Hindlegs_Calculations = 0;
    Column_Names.calculated = "No calculations made for hind legs data";
    % Read in Hindlegs label data
    Hindlegs_Proximal_Right_X = TempHindlegsCSV(Row,2);
    Hindlegs_Proximal_Right_Y = FrameHeight - TempHindlegsCSV(Row,3);
    Hindlegs_Proximal_Right_Confidence = TempHindlegsCSV(Row,4);

    Hindlegs_Knee_Right_X = TempHindlegsCSV(Row,5);
    Hindlegs_Knee_Right_Y = FrameHeight - TempHindlegsCSV(Row,6);
    Hindlegs_Knee_Right_Confidence = TempHindlegsCSV(Row,7);

    Hindlegs_Distal_Right_X = TempHindlegsCSV(Row,8);
    Hindlegs_Distal_Right_Y = FrameHeight - TempHindlegsCSV(Row,9);
    Hindlegs_Distal_Right_Confidence = TempHindlegsCSV(Row,10);

    Hindlegs_Abdoment_Right_X = TempHindlegsCSV(Row,11);
    Hindlegs_Abdoment_Right_Y = FrameHeight - TempHindlegsCSV(Row,12);
    Hindlegs_Abdoment_Right_Confidence = TempHindlegsCSV(Row,13);

    Hindlegs_Proximal_Left_X = TempHindlegsCSV(Row,14);
    Hindlegs_Proximal_Left_Y = FrameHeight - TempHindlegsCSV(Row,15);
    Hindlegs_Proximal_Left_Confidence = TempHindlegsCSV(Row,16);

    Hindlegs_Knee_Left_X = TempHindlegsCSV(Row,17);
    Hindlegs_Knee_Left_Y = FrameHeight - TempHindlegsCSV(Row,18);
    Hindlegs_Knee_Left_Confidence = TempHindlegsCSV(Row,19);
    
    Hindlegs_Distal_Left_X = TempHindlegsCSV(Row,20);
    Hindlegs_Distal_Left_Y = FrameHeight - TempHindlegsCSV(Row,21);
    Hindlegs_Distal_Left_Confidence = TempHindlegsCSV(Row,22);

    Hindlegs_Abdoment_Left_X = TempHindlegsCSV(Row,23);
    Hindlegs_Abdoment_Left_Y = FrameHeight - TempHindlegsCSV(Row,24);
    Hindlegs_Abdoment_Left_Confidence = TempHindlegsCSV(Row,25);
    
    % Populate RawData into an array with the data provided by each label.
    Hindlegs_RawData = [Hindlegs_Proximal_Right_X, Hindlegs_Proximal_Right_Y, Hindlegs_Proximal_Right_Confidence, ...
                        Hindlegs_Knee_Right_X    , Hindlegs_Knee_Right_Y    , Hindlegs_Knee_Right_Confidence    , ...
                        Hindlegs_Distal_Right_X  , Hindlegs_Distal_Right_Y  , Hindlegs_Distal_Right_Confidence  , ...
                        Hindlegs_Abdoment_Right_X, Hindlegs_Abdoment_Right_Y, Hindlegs_Abdoment_Right_Confidence, ...
                        Hindlegs_Proximal_Left_X , Hindlegs_Proximal_Left_Y , Hindlegs_Proximal_Left_Confidence , ...
                        Hindlegs_Knee_Left_X     , Hindlegs_Knee_Left_Y     , Hindlegs_Knee_Left_Confidence     , ...
                        Hindlegs_Distal_Left_X   , Hindlegs_Distal_Left_Y   , Hindlegs_Distal_Left_Confidence   , ...
                        Hindlegs_Abdoment_Left_X , Hindlegs_Abdoment_Left_Y , Hindlegs_Abdoment_Left_Confidence];

    % Populate the column names for data readability
    Column_Names.raw = getRawNames();
    
    % HINDLEGS CALCULATIONS
    %Calculate the angle of the leg from the Proximal point to the Knee.
    %Calculate the distance from the Proximal point to the Knee.
    %Calculate the angle from the Knee to the Distal point.
    %Calculate the distance from the Knee to the Distal point.
    
    if calculations == 'y'
        % Calculate the angle of the leg from the Proximal point to the Knee.
        ProximalKnee_Width_Right = Hindlegs_Knee_Right_X - Hindlegs_Proximal_Right_X;
        ProximalKnee_Height_Right = Hindlegs_Knee_Right_Y - Hindlegs_Proximal_Right_Y;
        %calculates the arctan and returns the answer in degrees
        ProximalKnee_Angle_Right = atand(ProximalKnee_Width_Right/ProximalKnee_Height_Right);
        if(ProximalKnee_Height_Right >= 0)
            ProximalKnee_Angle_Right = 180 - abs(ProximalKnee_Angle_Right - Axis_Angle);                   
        else
            ProximalKnee_Angle_Right = abs(ProximalKnee_Angle_Right - Axis_Angle);
        end
        
        %Calculate ProximalKnee_Angle_Confidence
        ProximalKnee_Angle_Right_Confidence = Hindlegs_Proximal_Right_Confidence * Hindlegs_Knee_Right_Confidence;

        %Calculate ProximalKnee_Angle
        ProximalKnee_Width_Left = Hindlegs_Knee_Left_X - Hindlegs_Proximal_Left_X;
        ProximalKnee_Height_Left = Hindlegs_Knee_Left_Y - Hindlegs_Proximal_Left_Y;
        %calculates the arctan and returns the answer in degrees
        ProximalKnee_Angle_Left = atand(ProximalKnee_Width_Left/ProximalKnee_Height_Left);
        if(ProximalKnee_Height_Left >= 0)
            ProximalKnee_Angle_Left = 180 - abs(ProximalKnee_Angle_Left - Axis_Angle);                   
        else
            ProximalKnee_Angle_Left = abs(ProximalKnee_Angle_Left - Axis_Angle);
        end
        
        %Calculate ProximalKnee_Angle_Confidence
        ProximalKnee_Angle_Left_Confidence = Hindlegs_Proximal_Left_Confidence * Hindlegs_Knee_Left_Confidence;
        
        % Calculate the distance from the Proximal point to the Knee
        ProximalKnee_Distance_Right = sqrt((ProximalKnee_Width_Right^2) + (ProximalKnee_Height_Right^2));
        ProximalKnee_Distance_Right_Confidence = Hindlegs_Proximal_Right_Confidence * Hindlegs_Knee_Right_Confidence;
        
        ProximalKnee_Distance_Left = sqrt((ProximalKnee_Width_Left^2) + (ProximalKnee_Height_Left^2));
        ProximalKnee_Distance_Left_Confidence = Hindlegs_Proximal_Left_Confidence * Hindlegs_Knee_Left_Confidence;
        
        
        % Calculate the angle from the Knee to the Distal point.
        KneeDistal_Width_Right = Hindlegs_Distal_Right_X - Hindlegs_Knee_Right_X;
        KneeDistal_Height_Right = Hindlegs_Distal_Right_Y - Hindlegs_Knee_Right_Y;
        %calculates the arctan and returns the answer in degrees
        KneeDistal_Angle_Right = atand(KneeDistal_Width_Right/KneeDistal_Height_Right);
        if(Axis_Angle >= 0)
            if(KneeDistal_Angle_Right > Axis_Angle)
                KneeDistal_Angle_Right = -abs(KneeDistal_Angle_Right - Axis_Angle);
            else
                KneeDistal_Angle_Right = abs(KneeDistal_Angle_Right - Axis_Angle);
            end                        
        else
            if(KneeDistal_Angle_Right < Axis_Angle)
                KneeDistal_Angle_Right = abs(KneeDistal_Angle_Right - Axis_Angle);
            else
                KneeDistal_Angle_Right = -abs(KneeDistal_Angle_Right - Axis_Angle);
            end
        end
        
        %Calculate KneeDistal_Angle_Confidence
        KneeDistal_Angle_Right_Confidence = Hindlegs_Knee_Right_Confidence * Hindlegs_Distal_Right_Confidence;
        
        
        %Calculate KneeDistal_Angle
        KneeDistal_Width_Left = Hindlegs_Distal_Left_X - Hindlegs_Knee_Left_X;
        KneeDistal_Height_Left = Hindlegs_Distal_Left_Y - Hindlegs_Knee_Left_Y;
        %calculates the arctan and returns the answer in degrees
        KneeDistal_Angle_Left = atand(KneeDistal_Width_Left/KneeDistal_Height_Left);
        if(Axis_Angle >= 0)
            if(KneeDistal_Angle_Left > Axis_Angle)
                KneeDistal_Angle_Left = abs(KneeDistal_Angle_Left - Axis_Angle);
            else
                KneeDistal_Angle_Left = -abs(KneeDistal_Angle_Left - Axis_Angle);
            end
        else
            if(KneeDistal_Angle_Left < Axis_Angle)
                KneeDistal_Angle_Left = -abs(KneeDistal_Angle_Left - Axis_Angle);
            else
                KneeDistal_Angle_Left = abs(KneeDistal_Angle_Left - Axis_Angle);
            end
        end
        
        %Calculate KneeDistal_Angle_Confidence
        KneeDistal_Angle_Left_Confidence = Hindlegs_Knee_Left_Confidence * Hindlegs_Distal_Left_Confidence;
        
        % Calculate the distance from the Knee to the Distal point
        KneeDistal_Distance_Right = sqrt((KneeDistal_Width_Right^2) + (KneeDistal_Height_Right^2));
        KneeDistal_Distance_Right_Confidence = Hindlegs_Knee_Right_Confidence * Hindlegs_Distal_Right_Confidence;
        
        KneeDistal_Distance_Left = sqrt((KneeDistal_Width_Left^2) + (KneeDistal_Height_Left^2));
        KneeDistal_Distance_Left_Confidence = Hindlegs_Knee_Left_Confidence * Hindlegs_Distal_Left_Confidence;
        
        % Assemble Calculations into an array
        Hindlegs_Calculations = [ProximalKnee_Angle_Right   , ProximalKnee_Angle_Right_Confidence   , ...
                                 ProximalKnee_Angle_Left    , ProximalKnee_Angle_Left_Confidence    , ...
                                 ProximalKnee_Distance_Right, ProximalKnee_Distance_Right_Confidence, ...
                                 ProximalKnee_Distance_Left , ProximalKnee_Distance_Left_Confidence , ...
                                 KneeDistal_Angle_Right     , KneeDistal_Angle_Right_Confidence     , ...
                                 KneeDistal_Angle_Left      , KneeDistal_Angle_Left_Confidence      , ...
                                 KneeDistal_Distance_Right  , KneeDistal_Distance_Right_Confidence  , ...
                                 KneeDistal_Distance_Left   , KneeDistal_Distance_Left_Confidence];

        % Assemble string array of all calculation names
        Column_Names.calculated = getCalcNames();
    elseif calculations ~= 'y' && usePadding == 1
        Column_Names.calculated = getCalcNames();
        Hindlegs_Calculations = zeros(1,length(Column_Names.calculated));
    end
end

% Use these two functions to handle requests for all names of the dataset
function names = getRawNames()
names = ["Hindlegs_Proximal_Right_X", "Hindlegs_Proximal_Right_Y", "Hindlegs_Proximal_Right_Confidence", ...
        "Hindlegs_Knee_Right_X"    , "Hindlegs_Knee_Right_Y"    , "Hindlegs_Knee_Right_Confidence"    , ...
        "Hindlegs_Distal_Right_X"  , "Hindlegs_Distal_Right_Y"  , "Hindlegs_Distal_Right_Confidence"  , ...
        "Hindlegs_Abdoment_Right_X", "Hindlegs_Abdoment_Right_Y", "Hindlegs_Abdoment_Right_Confidence", ...
        "Hindlegs_Proximal_Left_X" , "Hindlegs_Proximal_Left_Y" , "Hindlegs_Proximal_Left_Confidence" , ...
        "Hindlegs_Knee_Left_X"     , "Hindlegs_Knee_Left_Y"     , "Hindlegs_Knee_Left_Confidence"     , ...
        "Hindlegs_Distal_Left_X"   , "Hindlegs_Distal_Left_Y"   , "Hindlegs_Distal_Left_Confidence"   , ...
        "Hindlegs_Abdoment_Left_X" , "Hindlegs_Abdoment_Left_Y" , "Hindlegs_Abdoment_Left_Confidence"];
end
function names = getCalcNames()
names = ["ProximalKnee_Angle_Right"   , "ProximalKnee_Angle_Right_Confidence"   , ...
         "ProximalKnee_Angle_Left"    , "ProximalKnee_Angle_Left_Confidence"    , ...
         "ProximalKnee_Distance_Right", "ProximalKnee_Distance_Right_Confidence", ...
         "ProximalKnee_Distance_Left" , "ProximalKnee_Distance_Left_Confidence" , ...
         "KneeDistal_Angle_Right"     , "KneeDistal_Angle_Right_Confidence"     , ...
         "KneeDistal_Angle_Left"      , "KneeDistal_Angle_Left_Confidence"      , ...
         "KneeDistal_Distance_Right"  , "KneeDistal_Distance_Right_Confidence"  , ...
         "KneeDistal_Distance_Left"   , "KneeDistal_Distance_Left_Confidence"];
end
