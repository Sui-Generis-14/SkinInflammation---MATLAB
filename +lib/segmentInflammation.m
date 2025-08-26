function inflMask = segmentInflammation(redMap, skinMask, cfg)
% Segment hot (inflamed) regions using z-score + Otsu, with robust fallback

R = redMap;
R(~skinMask) = 0;

% z-score normalization stabilizes Otsu across images
if cfg.SEG_ZSCORE
    m = mean(R(skinMask));
    s = std(R(skinMask));
    Z = zeros(size(R));
    Z(skinMask) = (R(skinMask) - m) / max(s, eps);
    base = mat2gray(Z);
else
    base = R;
end

bw = false(size(R));
if cfg.SEG_USE_OTSU
    try
        level = graythresh(base(skinMask)); % Otsu in [0,1]
        bw = base >= level;
    catch
        warning('Otsu failed; using fallback threshold.');
    end
end

% fallback if mask too small/empty
minArea = cfg.SEG_REMOVE_SMALL;
if ~any(bw(:)) || nnz(bw) < minArea
    t = cfg.SEG_PERCENT_OF_MAX_FALLBACK * max(base(skinMask));
    bw = base >= t;
end

% restrict to skin, clean
bw = bw & skinMask;
bw = imopen(bw,  strel('disk', cfg.SEG_OPEN_RADIUS));
bw = imclose(bw, strel('disk', cfg.SEG_CLOSE_RADIUS));
bw = imfill(bw, 'holes');
bw = bwareaopen(bw, minArea);

inflMask = bw;
end
