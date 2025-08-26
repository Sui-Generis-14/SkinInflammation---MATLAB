function skinMask = getSkinMask(I, cfg)
% Combine permissive HSV + YCbCr rules, then clean up morphologically

[h,w,~] = size(I); 
skinMask = false(h,w);

% --- HSV rule ---
if cfg.SKIN_USE_HSV
    HSV = rgb2hsv(I);
    H = HSV(:,:,1); S = HSV(:,:,2); V = HSV(:,:,3);
    % broad skin-ish region (tuned to be inclusive)
    mHSV = (H > 0.0 & H < 0.14 | H > 0.9) & (S > 0.1 & S < 0.68) & (V > 0.15 & V < 0.98);
else
    mHSV = true(h,w);
end

% --- YCbCr rule ---
if cfg.SKIN_USE_YCbCr
    YCbCr = rgb2ycbcr(I);
    Cb = YCbCr(:,:,2); Cr = YCbCr(:,:,3);
    % normalize to [0,1] if needed
    if max(Cb(:)) > 1, Cb = Cb/255; Cr = Cr/255; end
    mYCC = (Cr > 0.30 & Cr < 0.62) & (Cb > 0.23 & Cb < 0.58);
else
    mYCC = true(h,w);
end

skinMask = mHSV & mYCC;

% --- morphology cleanup ---
skinMask = imopen(skinMask, strel('disk', cfg.SKIN_OPEN_RADIUS));
skinMask = imclose(skinMask, strel('disk', cfg.SKIN_CLOSE_RADIUS));
skinMask = imfill(skinMask, 'holes');

% remove small if image is large
skinMask = bwareaopen(skinMask, cfg.SKIN_MIN_PIXELS);

% if mask vanished (e.g., gloves, bandage), fallback to whole image
if ~any(skinMask(:))
    warning('Skin mask empty; falling back to full-frame.');
    skinMask = true(h,w);
end
end
