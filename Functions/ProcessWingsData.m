function [Wings_RawData, Wings_Calculations, Axis_Angle] = ProcessWingsData(TempWingsCSV, Row, FrameHeight, ~, calculations)
%PROCESSWINGDATA Calculates Right and Left Wing Beat Amplitude
    % Set these to 0 in case calculations aren't required by user
    Wings_Calculations = '0';
    Axis_Angle = '0';
    %% IMPORTANT - DLC Y values are inverted so we need to take the Y
    %value given from the resolution of the frame, this allows us to work with Y values that
    %match standard graphing conventions. e.g. X value increases left to right, Y value increases bottom to top.

    %% Read in Wings label data
    Wings_Hinge_Right_X = TempWingsCSV(Row,2);
    Wings_Hinge_Right_Y = FrameHeight - TempWingsCSV(Row,3);
    Wings_Hinge_Right_Confidence = TempWingsCSV(Row,4);

    Wings_Distal_Right_X = TempWingsCSV(Row,5);
    Wings_Distal_Right_Y = FrameHeight - TempWingsCSV(Row,6);
    Wings_Distal_Right_Confidence = TempWingsCSV(Row,7);

    Wings_Hinge_Left_X = TempWingsCSV(Row,8);
    Wings_Hinge_Left_Y = FrameHeight - TempWingsCSV(Row,9);
    Wings_Hinge_Left_Confidence = TempWingsCSV(Row,10);

    Wings_Distal_Left_X = TempWingsCSV(Row,11);
    Wings_Distal_Left_Y = FrameHeight - TempWingsCSV(Row,12);
    Wings_Distal_Left_Confidence = TempWingsCSV(Row,13);

    Wings_Thorax_Upper_X = TempWingsCSV(Row,14);
    Wings_Thorax_Upper_Y = FrameHeight - TempWingsCSV(Row,15);
    Wings_Thorax_Upper_Confidence = TempWingsCSV(Row,16);

    Wings_Thorax_Lower_X =  TempWingsCSV(Row,17);
    Wings_Thorax_Lower_Y = FrameHeight - TempWingsCSV(Row,18);
    Wings_Thorax_Lower_Confidence = TempWingsCSV(Row,19);    

    %% Populate RawData by continually appending the data provided by each label. 
    Wings_RawData = [Wings_Hinge_Right_X, Wings_Hinge_Right_Y, Wings_Hinge_Right_Confidence];
    Wings_RawData = [Wings_RawData, Wings_Distal_Right_X, Wings_Distal_Right_Y, Wings_Distal_Right_Confidence];
    Wings_RawData = [Wings_RawData, Wings_Hinge_Left_X, Wings_Hinge_Left_Y, Wings_Hinge_Left_Confidence];
    Wings_RawData = [Wings_RawData, Wings_Distal_Left_X, Wings_Distal_Left_Y, Wings_Distal_Left_Confidence];
    Wings_RawData = [Wings_RawData, Wings_Thorax_Upper_X, Wings_Thorax_Upper_Y, Wings_Thorax_Upper_Confidence];
    Wings_RawData = [Wings_RawData, Wings_Thorax_Lower_X, Wings_Thorax_Lower_Y, Wings_Thorax_Lower_Confidence];
    
    %% WING BEAT AMPLITUDE CALCULATIONS
    %Calculate confidence values (by multiplying confidence of each point together).
    %LongitudinalAxis Slope (Theta_Angle)
    %Wing SlopeWidth and SlopeHeight
    %Calculate the WBA using the slopes
    
    if calculations ~= 0
        %% Calculate confidence values (by multiplying confidence of each point together).
        WBA_Right_Confidence = Wings_Hinge_Right_Confidence * Wings_Distal_Right_Confidence;
        WBA_Left_Confidence = Wings_Hinge_Left_Confidence * Wings_Distal_Left_Confidence;
        Axis_Angle_Confidence = Wings_Thorax_Upper_Confidence * Wings_Thorax_Lower_Confidence;
        
        
        %% LongitudinalAxis Slope (Theta_Angle)
        LongitudinalAxis_Width = (Wings_Thorax_Upper_X - Wings_Thorax_Lower_X);
        LongitudinalAxis_Height = (Wings_Thorax_Upper_Y - Wings_Thorax_Lower_Y);

        %Calculates the absolute arctan and returns the answer in degrees
        Axis_Angle = atand(LongitudinalAxis_Width/LongitudinalAxis_Height);
        
        
        %% SlopeWidth and SlopeHeight
        WBA_SlopeWidth_Right = (Wings_Distal_Right_X - Wings_Hinge_Right_X);
        WBA_SlopeHeight_Right = (Wings_Distal_Right_Y - Wings_Hinge_Right_Y);
    
        WBA_SlopeWidth_Left = (Wings_Distal_Left_X - Wings_Hinge_Left_X);
        WBA_SlopeHeight_Left = (Wings_Distal_Left_Y - Wings_Hinge_Left_Y);
    
        
        %% Calculate Wing Beat Amplitudes
        %calculates the arctan and returns the answer in degrees
        WBA_Right = atand(WBA_SlopeWidth_Right/WBA_SlopeHeight_Right);
        if(WBA_SlopeHeight_Right >= 0)
            WBA_Right = 180 - abs(WBA_Right - Axis_Angle);                   
        else
            WBA_Right = abs(WBA_Right - Axis_Angle);
        end
        
        %calculates the arctan and returns the answer in degrees
        WBA_Left = atand(WBA_SlopeWidth_Left/WBA_SlopeHeight_Left);
        if(WBA_SlopeHeight_Left >= 0)
            WBA_Left = 180 - abs(WBA_Left - Axis_Angle);
        else
            WBA_Left = abs(WBA_Left - Axis_Angle);
        end
        
        %% Assemble
        Wings_Calculations =  [WBA_Right,WBA_Right_Confidence,WBA_Left,WBA_Left_Confidence,Axis_Angle,Axis_Angle_Confidence];
    end
end