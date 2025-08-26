function I = loadImage(path)
arguments
    path (1,:) char
end
if ~isfile(path), error('File not found: %s', path); end
I = imread(path);
if size(I,3) == 1
    I = repmat(I,1,1,3); % ensure RGB
end
I = im2double(I);
end
