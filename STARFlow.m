close all;
clear;

% load settings
 st = parameter_settings();

 st.alpha = 0.01;
 st.lambda = 0.08; % the weight of the data term
 st.pyramid_factor = 0.5;
 st.warps = 5; % the numbers of warps per level
 st.max_its = 10; % the number of equation iterations per warp
 
show_flow = 1; % 1 = display the evolution of the flow, 0 = do not show
h = figure('Name', 'Optical flow');
   
Im1 = double(imread('figures\other-data\Grove2\frame10.png'))/255;
Im2 = double(imread('figures\other-data\Grove2\frame11.png'))/255;  

floPath = 'figures\other-data\Grove2\flow10.flo';


% STAR
alpha = 0.001;
beta = 0.0001;

for pI = [1.5]                      
    for pR = [0.5]                   
        [I1, R1] = STAR(Im1, alpha, beta, pI, pR);
        [I2, R2] = STAR(Im2, alpha, beta, pI, pR);
        
        hsv1 = rgb2hsv(Im1);
        hsv1(:,:,3) = I1;
        imwrite(hsv2rgb(hsv1), ['figures\other-data\Grove2\frame_illumination_10.png']);
        I1_rgb=imread('figures\other-data\Grove2\frame_illumination_10.png');
        I1_rgb = double(I1_rgb);
        hsv1(:,:,3) = R1;
        imwrite(hsv2rgb(hsv1), ['figures\other-data\Grove2\frame_reflectance_10.png']);
        R1_rgb=imread('figures\other-data\Grove2\frame_reflectance_10.png');
        R1_rgb = double(R1_rgb);
        
        hsv2 = rgb2hsv(Im2);
        hsv2(:,:,3) = I2;
        imwrite(hsv2rgb(hsv2), ['figures\other-data\Grove2\frame_illumination_11.png']);
        I2_rgb=imread('figures\other-data\Grove2\frame_illumination_11.png');
        I2_rgb = double(I2_rgb);
        hsv2(:,:,3) = R2;
        imwrite(hsv2rgb(hsv2), ['figures\other-data\Grove2\frame_reflectance_11.png']);
        R2_rgb = imread('figures\other-data\Grove2\frame_reflectance_11.png');
        R2_rgb = double(R2_rgb);
    end
end



%I with Laplacian in flowfusion
f = fspecial('gaussian', [7 7], 2);
I1_orignal = I1_rgb;
I2_orignal = I2_rgb;
I1_rgb  = I1_rgb - imfilter(I1_rgb, f, 'symmetric');
I2_rgb  = I2_rgb - imfilter(I2_rgb, f, 'symmetric');



% call main routine
[flow, Numu, Numv] = coarse_to_fine(Im1,Im2,I1_rgb,I2_rgb,R1_rgb, R2_rgb, st, show_flow, h);

u = flow(:, :, 1);
v = flow(:, :, 2);

%% evalutate the correctness of the computed flow
% read the ground-truth flow
realFlow = readFlowFile(floPath);
tu = realFlow(:, :, 1);
tv = realFlow(:, :, 2);

%flowImg0 = uint8(robust_flowToColor(realFlow));
%figure; imshow(flowImg0);

% compute the mean end-point error (mepe) and the mean angular error (mang)
UNKNOWN_FLOW_THRESH = 1e9;
[mang, mepe] = flowError(tu, tv, u, v, ...
  0, 0.0, UNKNOWN_FLOW_THRESH);
disp(['Mean end-point error: ', num2str(mepe)]);
disp(['Mean angular error: ', num2str(mang)]);

% display the flow
flowImg = uint8(robust_flowToColor(flow));
figure; imshow(flowImg);


