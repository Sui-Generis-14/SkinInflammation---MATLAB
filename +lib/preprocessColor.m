function J = preprocessColor(I, cfg)
% White balance + optional dehaze + CLAHE on L + homomorphic illumination

J = I;

% --- gray-world white balance ---
if cfg.APPLY_GRAYWORLD
    mu = squeeze(mean(reshape(J,[],3),1));
    scale = mean(mu) ./ (mu + eps);
    J = reshape(reshape(J,[],3) .* scale, size(J));
    J = min(max(J,0),1);
end

% --- dehaze (optional) ---
if cfg.DEHAZE
    try
        J = imreducehaze(J);  % needs IPT
    catch
        warning('imreducehaze not available; skipping dehaze');
    end
end

% --- CLAHE on L (Lab) ---
if cfg.APPLY_CLAHE
    lab = rgb2lab(J);
    L = lab(:,:,1)/100;             % normalize [0,1]
    Lc = adapthisteq(L,'NumTiles',[8 8],'ClipLimit',0.01);
    lab(:,:,1) = Lc*100;
    J = lab2rgb(lab);
    J = min(max(J,0),1);
end

% --- homomorphic illumination correction ---
if cfg.ILLUM_CORRECT
    % apply to intensity (Y)-like channel via rgb2gray surrogate
    Y = rgb2gray(J);
    Ylog = log1p(Y);
    Yf = fft2(Ylog);
    [M,N] = size(Y);
    [U,V] = meshgrid((-N/2):(N/2-1), (-M/2):(M/2-1));
    D = sqrt(U.^2 + V.^2);
    H = 1 - exp(-(D.^2)/(2*(0.15*max(M,N))^2)); % high-pass
    Ycorr = real(ifft2(fftshift(H).*Yf));
    Ycorr = mat2gray(expm1(Ycorr));
    % re-scale RGB by ratio
    r = (Ycorr + eps) ./ (Y + eps);
    J = min(max(J .* r, 0), 1);
end
end
