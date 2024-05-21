%findFlakeCoord.m loads images of the marker chip and allows the user to
%identify the coordinates of nanostructures relative to the alignment marks
%on the chip.

lettervals = dictionary(["A" "B" "C" "D" "E" "F" "G" "H" "I" "J"], ...
    [0 1 2 3 4 5 6 7 8 9]);

cornerpositions = {};
nn = 0;
electrodes = {};
%Open image file
cornernum = 1;
while cornernum ~= 0
    %Open image file
%     filename = uigetfile('*.tif');
%     filename = uigetfile('*.png*');
    filename = uigetfile('*.jpg*');

    %Read image file
    ChipImage = imread(filename);

    %Display image
    image(ChipImage);

    %Get positions of alignment marks from user
    disp('Click on the end points of alignment mark cross with the mouse, starting with the top and going CW but have the fourth be the CENTER');
    [xmark,ymark] = ginput(4);

    %Identify field
    markNum = input('Enter the letters of the mark, stating with the top left going CW: ','s');

    %Determine translation of the alignment mark to 0,0
    Translation = [xmark(4);ymark(4)];

    %Translate alignment mark coordinates such that origin corresponds to Mark
    %4 position
    xmark = xmark-Translation(1);
    ymark = ymark-Translation(2);
    ymark = ymark*(-1);

    %Get positions of nanostructures from user
    jj = 1;
    cornernum = input('Enter the number of corner positions of a nanostructure.  Enter 0 to end data input: ');

    while cornernum ~=0
       disp('Click on the corners of the nanostructure with the mouse');
       cornerdata = ginput(cornernum);

       %Translate positions such that origin corresponds to Mark4 position
       cornerdata = cornerdata' - Translation;
       cornerdata(2,:) = cornerdata(2,:)*(-1);
       cornerpositions{jj+nn} = cornerdata;
       jj = jj + 1;
       cornernum = input('Enter the number of corner positions of a nanostructure.  Enter 0 to end data input: ');
    end

    %electrode axis
    axis_num = 0;
    axis = input("Enter the 2 indices of the coordinates for the axis. " + ...
           "For example, if it was the first point clicked, enter 1. Do not separate inputs. Enter 0 if none: ");
    while axis ~= 0
        axis_num = axis_num +1;
        %corner data for electrodes
        y1 = cornerdata(2, mod(axis, 10));
        y2 = cornerdata(2, floor(axis/10));
        x1 = cornerdata(1, mod(axis, 10));
        x2 = cornerdata(1, floor(axis/10));
        len1 = ((x1-x2)^2+(y1-y2)^2)^0.5;
        len2 = len1+200;
        wid = 100;
        vec1 = (1/len1) * [x1-x2; y1-y2];
        vec2 = [0 1;-1 0] * vec1;
        mat = [vec2 vec1];
        % mat change coord from axis coordinates to whatever coordinate system
        % cornerdata was in
        electrode_corners = mat * [[wid/2;len2/2] [wid/2;-len2/2] [-wid/2;-len2/2] [-wid/2;len2/2]];
        electrode_corners = electrode_corners + [0.5*(x1+x2);0.5*(y1+y2)];
        electrodes{axis_num} = electrode_corners;
        axis = input("Enter the 2 indices of the coordinates for the axis. " + ...
           "For example, if it was the first point clicked, enter 1. Do not separate inputs. Enter 0 if no axis: ");
    end

    %parallel electrode
    parallel_electrodes = {};
    for ll = 1:(length(electrodes))
        e1 = electrodes{ll};
        [center1_x, center1_y] = centroid(polyshape(e1(1,:), e1(2,:)));
        %electrode_poly = polyshape(electrode{ll}(1,:),electrode{ll}(2,:));
        %nano_poly = polyshape(cornerpositions{ll}(1,:), cornerpositions{ll}(2,:));
        %inter1 = intersect(electrode_poly, nano_poly);
        disp("Click on where the center of the parallel electrode should be:")
        [center2_x, center2_y] = ginput(1);
        parallel_electrodes{ll} = e1 - [center1_x; center1_y] + [center2_x; -center2_y] - [Translation(1,:); -Translation(2,:)];
        %parallel_electrodes{ll} = mat * [[wid/2;len2/2] [wid/2;-len2/2] [-wid/2;-len2/2] [-wid/2;len2/2]] + [center2_x; center2_y];
    end

    %Find change of coordinates matrix to translate corner positions from image
    %coordinates to positions (in microns) relative to Mark4
    basisvec1 = [xmark(2);ymark(2)];
    basisvec2 = [xmark(1);ymark(1)];
    basismat = [basisvec1 basisvec2];
    changecoordmat = [15,0;0,15]*basismat^(-1);

    %Determine absolute positions of the marker in microns
    Center = [-2900+2000*lettervals(markNum(3))+200*lettervals(markNum(4));
        2900-2000*lettervals(markNum(1))-200*lettervals(markNum(2))];

    %Translate coordinates of corners to AutoCAD coordinates
    for kk = 1:(length(cornerpositions)-nn)
        tempmat = cornerpositions{kk+nn};
        tempmat = changecoordmat*tempmat;
        tempmat = tempmat + Center;
        cornerpositions{kk+nn} = tempmat;
    end

    for kk = 1:(length(electrodes)-nn)
        tempmat = electrodes{kk+nn};
        tempmat = changecoordmat*tempmat;
        tempmat = tempmat + Center;
        electrodes{kk+nn} = tempmat;

        parallel_electrodes{kk+nn}= changecoordmat*parallel_electrodes{kk+nn}+Center;
    end
    nn = length(cornerpositions);
end

%Write corner position data to file

if length(cornerpositions) ~= 0

    disp('Create a file for saving points.  Use extension .txt');
    savefilename = uiputfile;
    fileid = fopen(savefilename,'w');

    fprintf(fileid,'nanostructures\n');

    for ll = 1:length(cornerpositions)
       tempmat = cornerpositions{ll};
       fprintf(fileid,'%f,%f\n',tempmat);
       fprintf(fileid,'\n');
    end

    fprintf(fileid,'electrodes\n');

    for ll = 1:length(electrodes)
       tempmat = electrodes{ll};
       fprintf(fileid,'%f,%f\n',tempmat);
       fprintf(fileid,'\n');
    end

    fprintf(fileid, 'parallel electrodes\n');
    for ll = 1:length(electrodes)
       tempmat = parallel_electrodes{ll};
       fprintf(fileid,'%f,%f\n',tempmat);
       fprintf(fileid,'\n');
    end

    fclose(fileid);
end
