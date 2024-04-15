function [Head_RawData, Head_Calculations, Axis_Angle] = ProcessHeadData(TempHeadCSV, Row , FrameHeight, Axis_Angle, calculations)
%PROCESSHEADDATA Calculates the line of best fit for the Head

    %% IMPORTANT - DLC Y values are inverted so we need to take the Y
    %value given from the resolution of the frame, this allows us to work with Y values that
    %match standard graphing conventions. e.g. X value increases left to right, Y value increases bottom to top.
    
    % Set these to 0 in case calculations aren't required by user
    Head_Calculations = 0;

    %% Read in Head label data
    Head_Midline_Anterior_1_X = TempHeadCSV(Row,2);
    Head_Midline_Anterior_1_Y = FrameHeight - TempHeadCSV(Row,3);
    Head_Midline_Anterior_1_Confidence = TempHeadCSV(Row,4);

    Head_Midline_2_X = TempHeadCSV(Row,5);
    Head_Midline_2_Y = FrameHeight - TempHeadCSV(Row,6);
    Head_Midline_2_Confidence = TempHeadCSV(Row,7);

    Head_Midline_3_X = TempHeadCSV(Row,8);
    Head_Midline_3_Y = FrameHeight - TempHeadCSV(Row,9);
    Head_Midline_3_Confidence = TempHeadCSV(Row,10);

    Head_Midline_4_X = TempHeadCSV(Row,11);
    Head_Midline_4_Y = FrameHeight - TempHeadCSV(Row,12);
    Head_Midline_4_Confidence = TempHeadCSV(Row,13);

    Head_Midline_5_X = TempHeadCSV(Row,14);
    Head_Midline_5_Y = FrameHeight - TempHeadCSV(Row,15);
    Head_Midline_5_Confidence = TempHeadCSV(Row,16);

    Head_Midline_Posterior_6_X = TempHeadCSV(Row,17);
    Head_Midline_Posterior_6_Y = FrameHeight - TempHeadCSV(Row,18);
    Head_Midline_Posterior_6_Confidence = TempHeadCSV(Row,19);
    
    %% Populate RawData by continually appending the data provided by each label. 
    Head_RawData = [Head_Midline_Anterior_1_X, Head_Midline_Anterior_1_Y, Head_Midline_Anterior_1_Confidence];
    Head_RawData = [Head_RawData, Head_Midline_2_X, Head_Midline_2_Y, Head_Midline_2_Confidence];
    Head_RawData = [Head_RawData, Head_Midline_3_X, Head_Midline_3_Y, Head_Midline_3_Confidence];
    Head_RawData = [Head_RawData, Head_Midline_4_X, Head_Midline_4_Y, Head_Midline_4_Confidence];
    Head_RawData = [Head_RawData, Head_Midline_5_X, Head_Midline_5_Y, Head_Midline_5_Confidence];
    Head_RawData = [Head_RawData, Head_Midline_Posterior_6_X, Head_Midline_Posterior_6_Y, Head_Midline_Posterior_6_Confidence];
    
    if calculations ~= 0
        %% HEAD LINE OF BEST FIT CALCULATIONS
        %Calculate confidence value (by multiplying confidence of each point together)
        %Calculate average slope of all points
        ConfidenceArray = [Head_Midline_Anterior_1_Confidence,Head_Midline_2_Confidence,Head_Midline_3_Confidence,Head_Midline_4_Confidence,Head_Midline_5_Confidence,Head_Midline_Posterior_6_Confidence];
        Head_Slope_Confidence = prod(ConfidenceArray); % prod returns the multiple of all elements
        
        SumOfAllX = Head_Midline_Anterior_1_X + Head_Midline_2_X + Head_Midline_3_X + Head_Midline_4_X + Head_Midline_5_X + Head_Midline_Posterior_6_X;
        SumOfAllY = Head_Midline_Anterior_1_Y + Head_Midline_2_Y + Head_Midline_3_Y + Head_Midline_4_Y + Head_Midline_5_Y + Head_Midline_Posterior_6_Y;
        
        Head_Slope = (atand(SumOfAllX / SumOfAllY)) - Axis_Angle;
        
        %% Assemble
        Head_Calculations = [Head_Slope, Head_Slope_Confidence];
    end
end

