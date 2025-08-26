function [redMap, parts] = computeRednessMap(I, cfg)
% produces a normalized redness map by fusing:
%  - Lab "a*" channel (red-green)
%  - Erythema Index: 100*log(R/G) (clipped robustly)

% ensure double RGB in [0,1]
I = im2double(I);
I = min(max(I,0),1);

% Lab a*
lab = rgb2lab(I);
a = lab(:,:,2);  % approx [-128, 127], but MATLAB scales near that
% normalize to [0,1] robustly using percentiles
aN = localPercentileNorm(a, cfg.REDMAP_MINMAX_CLIP);

% Erythema Index (EI) ~ 100*log(R/G)
R = I(:,:,1); G = I(:,:,2);
EI = 100 * log((R+eps) ./ (G+eps));
EI = localPercentileNorm(EI, cfg.REDMAP_MINMAX_CLIP);

% gaussian smooth
if cfg.REDMAP_GAUSS_SIGMA > 0
    aN  = imgaussfilt(aN,  cfg.REDMAP_GAUSS_SIGMA);
    EI  = imgaussfilt(EI,  cfg.REDMAP_GAUSS_SIGMA);
end

% weighted fusion
w = cfg.REDMAP_WEIGHTS;
redMap = zeros(size(aN));
if cfg.REDMAP_USE_LAB_A, redMap = redMap + w(1)*aN; end
if cfg.REDMAP_USE_EI,    redMap = redMap + w(2)*EI; end
redMap = mat2gray(redMap);

parts = struct('aNorm', aN, 'EI', EI);
end

function Xn = localPercentileNorm(X, prcRange)
lo = prctile(X(:), prcRange(1));
hi = prctile(X(:), prcRange(2));
Xn = (X - lo) / max(hi - lo, eps);
Xn = min(max(Xn,0),1);
end
