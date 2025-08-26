function batchProcess(inputDir)
% batchProcess.m — process all images in a folder
% Usage: batchProcess('data')

if nargin < 1, inputDir = fullfile(pwd,'data'); end
cfg = projectConfig();

imds = imageDatastore(inputDir, 'IncludeSubfolders', false, ...
    'FileExtensions', {'.jpg','.jpeg','.png','.tif','.tiff'});

if ~hasdata(imds)
    error('No images found in %s', inputDir);
end

i = 0;
reset(imds);
while hasdata(imds)
    i = i + 1;
    inPath = imds.read();
    if isstruct(inPath), inPath = inPath.Files{1}; end  % compatibility

    try
        I = lib.loadImage(inPath);
        Inorm = lib.preprocessColor(I, cfg);
        skinMask = lib.getSkinMask(Inorm, cfg);
        [redMap, ~] = lib.computeRednessMap(Inorm, cfg);
        inflMask = lib.segmentInflammation(redMap, skinMask, cfg);
        metrics = lib.measureInflammation(inflMask, redMap, skinMask, cfg);
        [overlayRGB, panelFig] = lib.visualizeResults(I, skinMask, redMap, inflMask, cfg);
        out = lib.saveReport(inPath, overlayRGB, panelFig, metrics, cfg);
        if cfg.CLOSE_FIGS_AFTER_SAVE, close(panelFig); end
        fprintf('[%d] OK: %s\n', i, out.overlayPath);
    catch ME
        warning('[%d] FAILED: %s\n  -> %s', i, inPath, ME.message);
    end
end
end
