function [overlayRGB, figH] = visualizeResults(I, skinMask, redMap, inflMask, cfg)
% Create:
%  - pseudocolor redness heatmap
%  - overlay on original image
%  - panels for QA

% heatmap (parula colormap)
hm = ind2rgb(gray2ind(mat2gray(redMap), 256), parula(256));

% overlay (blend only where inflamed)
overlayRGB = I;
alpha = cfg.OVERLAY_ALPHA;
for c = 1:3
    tmp  = overlayRGB(:,:,c);
    hmC  = hm(:,:,c);
    tmp(inflMask) = (1-alpha).*tmp(inflMask) + alpha.*hmC(inflMask); % <-- fixed indexing
    overlayRGB(:,:,c) = tmp;
end

% draw a white boundary around inflamed areas (no toolboxes needed)
contourMask = bwperim(inflMask,8);
for c = 1:3
    ch = overlayRGB(:,:,c);
    ch(contourMask) = 1;   % white outline
    overlayRGB(:,:,c) = ch;
end

% panel figure
figH = figure('Name','Skin Inflammation Analysis','Color','w', ...
              'Units','normalized','Position',[0.1 0.1 0.8 0.75]);
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I); title('Original');
nexttile; imshow(skinMask); title('Skin Mask');
nexttile; imshow(redMap,[]); title('Redness Map');
nexttile; imshow(ind2rgb(gray2ind(mat2gray(redMap),256), parula(256))); title('Redness Heatmap');
nexttile; imshow(inflMask); title('Inflamed Mask');
nexttile; imshow(overlayRGB); title('Overlay');
end
