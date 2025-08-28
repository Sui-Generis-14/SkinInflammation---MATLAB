# Skin Inflammation Detection

A MATLAB project that detects and highlights inflamed (red) skin regions from a normal photo and reports metrics you can track over time. Built to be fast, explainable, and training-free (no deep learning needed).

# What It Does

1. Takes a skin photo (JPG/PNG).
2. Cleans the image (neutral color, reduced glare, even lighting).
3. Finds skin only (so clothes/background are ignored).
4. Builds a redness heatmap (how red each skin pixel is).
5. Converts it into binary inflamed regions (yes/no).

6. Saves:

   - Overlay image with highlights,

   -  6-panel QA figure (each step),

   - JSON + CSV with metrics (e.g., percent inflamed).


# Getting Started
## 1) Set Up

- Use MATLAB Online (recommended) or Desktop MATLAB.

- Ensure Image Processing Toolbox is available.

## 2) Project Layout

Put this folder in your MATLAB Drive or local MATLAB path:

        skin_inflammation/
        ├── data/                   # Input images (put your JPG/PNG here)
        ├── out/                    # Auto-created: results are saved here
        ├── main.m                  # Single-image pipeline
        ├── batchProcess.m          # Folder pipeline
        ├── projectConfig.m         # All settings/toggles/paths
        └── +lib/                   # Helper functions
            ├── loadImage.m
            ├── preprocessColor.m
            ├── getSkinMask.m
            ├── computeRednessMap.m
            ├── segmentInflammation.m
            ├── measureInflammation.m
            ├── visualizeResults.m
            ├── saveReport.m
            └── utils.m

## 3) Run

- Put an image in data/ (e.g., sample1.jpg).

- In MATLAB Command Window:

        clear; clc; main               % process the sample image set in projectConfig.m
        % or process a whole folder:
        batchProcess('data')

## Outputs

Saved in out/ with timestamps:

- *_overlay_*.png – original photo with inflamed regions highlighted.

- *_panels_*.png – 6-panel figure (Original | Skin Mask | Redness Map | Heatmap | Inflamed Mask | Overlay).

- *_metrics_*.json & *_metrics_*.csv – percent inflamed, redness stats, region features.

## Packages / Tools Used

MATLAB + Image Processing Toolbox: 
rgb2lab, lab2rgb, rgb2hsv, rgb2ycbcr, adapthisteq (CLAHE), imreducehaze (optional),
imgaussfilt, graythresh (Otsu), imopen, imclose, imfill, bwareaopen, bwperim, strel,
bwconncomp, regionprops, imageDatastore, ind2rgb, gray2ind, imshow.

Base MATLAB: FFT (fft2/ifft2) for homomorphic illumination, jsonencode, writetable.
