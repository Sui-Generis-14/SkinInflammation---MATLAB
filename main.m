% main.m
% Entry point for single-image run.
% Usage:
%   - Set paths in config.m
%   - Run: main
%   - Or call from CLI: main;  (updates outputs in /out)

clear; clc;

cfg = projectConfig();  % load configuration

% === choose source ===
% Option A: hardcode a single file
inPath = fullfile(cfg.DATA_DIR, cfg.SAMPLE_IMAGE);

% Option B: prompt user (uncomment)
% [f,p] = uigetfile({'*.jpg;*.jpeg;*.png;*.tif;*.tiff'}, 'Select skin image');
% if isequal(f,0), error('No image selected.'); end
% inPath = fullfile(p,f);

% --- 1) read image ---
I = lib.loadImage(inPath);

% --- 2) color/illumination normalization ---
Inorm = lib.preprocessColor(I, cfg);

% --- 3) skin mask ---
skinMask = lib.getSkinMask(Inorm, cfg);

% --- 4) redness map (Lab a* + Erythema Index fusion) ---
[redMap, redComponents] = lib.computeRednessMap(Inorm, cfg);

% --- 5) inflammation segmentation within skin only ---
inflMask = lib.segmentInflammation(redMap, skinMask, cfg);

% --- 6) measurements ---
metrics = lib.measureInflammation(inflMask, redMap, skinMask, cfg);

% --- 7) visualization ---
[overlayRGB, panelFig] = lib.visualizeResults(I, skinMask, redMap, inflMask, cfg);

% --- 8) save outputs ---
out = lib.saveReport(inPath, overlayRGB, panelFig, metrics, cfg);

fprintf('[OK] Processed: %s\nSaved overlay: %s\nSaved report: %s\n\n', ...
    inPath, out.overlayPath, out.reportJsonPath);

% close figures if configured
if cfg.CLOSE_FIGS_AFTER_SAVE
    close(panelFig);
end
