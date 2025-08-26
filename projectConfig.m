function cfg = projectConfig()
% config.m — central config & thresholds

% --- I/O ---
cfg.DATA_DIR = fullfile(pwd, 'data');           % put sample images here
cfg.OUT_DIR  = fullfile(pwd, 'out');            % outputs go here
cfg.SAMPLE_IMAGE = 'sample1.jpg';               % change to your test image

% auto-create out dir
if ~exist(cfg.OUT_DIR, 'dir'); mkdir(cfg.OUT_DIR); end

% --- preprocessing ---
cfg.APPLY_GRAYWORLD = true;        % white balance (gray-world)
cfg.APPLY_CLAHE     = true;        % local contrast enhancement (LAB-L)
cfg.DEHAZE          = false;       % set true if strong veiling/glare
cfg.ILLUM_CORRECT   = true;        % homomorphic illumination correction

% --- skin detection ---
% HSV & YCbCr bounds are fairly permissive; we AND/OR then clean up.
cfg.SKIN_USE_HSV  = true;
cfg.SKIN_USE_YCbCr = true;
cfg.SKIN_MIN_PIXELS = 5000;        % reject tiny masks
cfg.SKIN_OPEN_RADIUS = 3;
cfg.SKIN_CLOSE_RADIUS = 5;

% --- redness map ---
cfg.REDMAP_USE_LAB_A = true;       % core redness via Lab a*
cfg.REDMAP_USE_EI    = true;       % Erythema Index: 100*log(R/G) (robustly clipped)
cfg.REDMAP_GAUSS_SIGMA = 1.0;      % slight smoothing
cfg.REDMAP_MINMAX_CLIP = [1, 99];  % percentile clipping before fusion
cfg.REDMAP_WEIGHTS = [0.6, 0.4];   % [Lab a*, EI] fusion weights

% --- segmentation ---
cfg.SEG_USE_OTSU = true;           % Otsu threshold after z-score
cfg.SEG_ZSCORE = true;             % normalize redMap for stable Otsu
cfg.SEG_PERCENT_OF_MAX_FALLBACK = 0.55; % fallback fraction if Otsu fails
cfg.SEG_OPEN_RADIUS  = 2;
cfg.SEG_CLOSE_RADIUS = 6;
cfg.SEG_REMOVE_SMALL = 500;        % remove components smaller than this (px)

% --- visualization ---
cfg.OVERLAY_ALPHA = 0.45;          % overlay opacity
cfg.CLOSE_FIGS_AFTER_SAVE = true;

% --- reporting ---
cfg.SAVE_CSV   = true;
cfg.SAVE_JSON  = true;
end
