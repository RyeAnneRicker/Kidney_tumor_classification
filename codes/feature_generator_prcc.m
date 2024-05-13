path = '/Users/chenzirong/MATLAB code/lab/prcc-NC_tif_crop/'; % immage folder path
pathlist = dir(strcat(path, '*.tif')); % list of image pathes in the folder
num = length(pathlist);
GLRL_feature = zeros(num, 11); % initialize the GLRL matrix
GLCM_feature = zeros(num, 20); % initialize the GLCM matrix
% HU_feature = zeros(num, 7);
HIST_feature = zeros(num, 6); % initialize the histogram matrix
label = zeros(num, 1);
patient = zeros(num, 1);
% imagename_list = zeros(num, 1)
for i = 1 : num
    imagename = pathlist(i).name;
    imagepath = strcat(path, imagename);
    if isletter(imagename(1 + strfind(imagename, 'T')))
        continue
    end
    % get the label of the image
    label(i, :) = str2double(imagename(1 + strfind(imagename, 'T')));
%     get the patient number of the feature
    begin = strfind(imagename, 'e') + 1;
    ending = strfind(imagename, '_');
    patient(i, :) = str2double(imagename(begin : ending(1)-1));
%     read the image
    f = imread(imagepath);
% change the color image into gray images
    if size(f, 3) == 3
        f = rgb2gray(f);
    elseif size(f, 3) == 2
        f = f(:,:,1);
    end
%     f = double(imresize(f, [100, 100]));

% set the background pixel to NaN 
    f1 = f;
    f(f == 0) = nan;
    
    % extract the GLRL features
    [GLRLMS,~]= grayrlmatrix(f1, 'G', [0 255], 'N', 256);
    for j=1:4
        GLRLangle = GLRLMS{j};
        GLRLangle(1,:) = zeros(1,size(f, 1));
        GLRLMS{j} = GLRLangle;
    end
    stats1 = grayrlprops(GLRLMS);
    GLRL_feature(i,:) = mean(stats1, 1);
    
    % extract the GLCM features
    offsets = [0 1; -1 1; -1 0; -1 -1];
    glcMat = graycomatrix(f, 'Offset', offsets, 'GrayLimits', [0,255],'NumLevels', 256);
    neighbors = size(glcMat,3);
    glcm = zeros(size(glcMat,1),size(glcMat,2));
    for k=1:neighbors
        glcm = glcm + glcMat(:,:,k);
    end
    stats2 = getGLCProps(glcm);
    GLCM_feature(i, :) = stats2;
    
%     mask = zeros(size(f1));
%     mask(f1 ~= 0) = 1;
%     eta = SI_Moment(f1, mask);
%     HU_feature(i, :) = Hu_Moments(eta);
    
    % extract the histogram features
    HIST_feature(i, :) = chip_histogram_features(f);
    HIST_feature(i, 6) = entropy(f);
    
end
% merge each kind of features together
feature_matrix_CM = table(patient, label, HIST_feature, GLRL_feature, GLCM_feature, HU_feature);
% feature_matrix_combined = [feature_matrix_CM; feature_matrix_NG];
% writetable(feature_matrix_CM, 'feature_matrix_CM.csv');
% feature_matrix_NG(find(patient==0), :) = [];