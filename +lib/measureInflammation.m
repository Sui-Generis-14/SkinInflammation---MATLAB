function metrics = measureInflammation(inflMask, redMap, skinMask, cfg) %#ok<INUSD>
% Compute area %, mean redness, max redness, and region stats

totalSkin = nnz(skinMask);
inflPixels = nnz(inflMask);
pctInflamed = 100 * inflPixels / max(totalSkin, 1);

% summarize redness only over inflamed region
R = redMap(inflMask);
metrics = struct();
metrics.percent_inflamed = pctInflamed;
metrics.inflamed_pixels = inflPixels;
metrics.skin_pixels = totalSkin;

if isempty(R)
    metrics.redness_mean = 0;
    metrics.redness_max  = 0;
    metrics.redness_median = 0;
else
    metrics.redness_mean = mean(R);
    metrics.redness_max  = max(R);
    metrics.redness_median = median(R);
end

% connected-component region measurements
cc = bwconncomp(inflMask, 8);
stats = regionprops(cc, redMap, ...
    'Area','BoundingBox','Centroid','MeanIntensity','MaxIntensity');
metrics.region_count = numel(stats);
metrics.regions = stats;
end
