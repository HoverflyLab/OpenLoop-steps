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
        
        Head_X_Points = [Head_Midline_Anterior_1_X  Head_Midline_2_X Head_Midline_3_X ...
            Head_Midline_4_X Head_Midline_5_X Head_Midline_Posterior_6_X];
        Head_Y_Points = [Head_Midline_Anterior_1_Y  Head_Midline_2_Y Head_Midline_3_Y ...
            Head_Midline_4_Y Head_Midline_5_Y Head_Midline_Posterior_6_Y];
        
        p = polyfit(Head_X_Points,Head_Y_Points,1);
        
        head_slope = p(1);
        head_angle_rad = atan(head_slope);
        head_angle_deg = atand(head_slope);
        Relative_Head_Angle = head_angle_deg - Axis_Angle;

        % Reject head angles done poorly by polyfit
        head_fit = head_slope(1) * Head_X_Points;
        corr_fit_temp = corrcoef(head_fit, Head_Y_Points);
        corr_fit = corr_fit_temp(2);
           
        if abs(corr_fit(l,:)) < 0.1
            Relative_Head_Angle = NaN;
        end
        
        %% Assemble
        Head_Calculations = [Relative_Head_Angle, Head_Slope_Confidence];
    end
end

