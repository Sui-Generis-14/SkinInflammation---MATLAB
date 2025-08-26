function out = saveReport(inPath, overlayRGB, panelFig, metrics, cfg)
[~,base,~] = fileparts(inPath);
ts = datestr(now,'yyyymmdd_HHMMSS');

overlayName = sprintf('%s_overlay_%s.png', base, ts);
panelName   = sprintf('%s_panels_%s.png',  base, ts);
csvName     = sprintf('%s_metrics_%s.csv', base, ts);
jsonName    = sprintf('%s_metrics_%s.json', base, ts);

overlayPath = fullfile(cfg.OUT_DIR, overlayName);
panelPath   = fullfile(cfg.OUT_DIR, panelName);
csvPath     = fullfile(cfg.OUT_DIR, csvName);
jsonPath    = fullfile(cfg.OUT_DIR, jsonName);

imwrite(overlayRGB, overlayPath);
exportgraphics(panelFig, panelPath, 'Resolution', 180);

% flat metrics for CSV
T = struct2table(flattenMetrics(metrics), 'AsArray', true);
if cfg.SAVE_CSV, writetable(T, csvPath); end
if cfg.SAVE_JSON
    str = jsonencode(metrics);
    fid = fopen(jsonPath,'w'); fwrite(fid, str,'char'); fclose(fid);
end

out = struct('overlayPath', overlayPath, 'panelPath', panelPath, ...
             'reportCsvPath', csvPath, 'reportJsonPath', jsonPath);
end

function S = flattenMetrics(m)
S = struct();
S.percent_inflamed = m.percent_inflamed;
S.inflamed_pixels  = m.inflamed_pixels;
S.skin_pixels      = m.skin_pixels;
S.redness_mean     = m.redness_mean;
S.redness_median   = m.redness_median;
S.redness_max      = m.redness_max;
S.region_count     = m.region_count;
% aggregate top-3 largest regions by area (optional)
areas = arrayfun(@(r) r.Area, m.regions);
[~,idx] = sort(areas,'descend');
k = min(3, numel(idx));
for i=1:k
    r = m.regions(idx(i));
    S.(sprintf('r%d_area',i)) = r.Area;
    S.(sprintf('r%d_mean',i)) = r.MeanIntensity;
    S.(sprintf('r%d_max',i))  = r.MaxIntensity;
    S.(sprintf('r%d_cx',i))   = r.Centroid(1);
    S.(sprintf('r%d_cy',i))   = r.Centroid(2);
end
end
