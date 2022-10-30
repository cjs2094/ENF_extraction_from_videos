# Code for Analysis of ENF Signal Extraction From Videos Acquired by Rolling Shutters
This repository contains an implementation of the following paper:

[Analysis of ENF Signal Extraction From Videos Acquired by Rolling Shutters](https://www.techrxiv.org/articles/preprint/Analysis_of_ENF_Signal_Extraction_From_Videos_Acquired_by_Rolling_Shutters/21300960)

## Requirement
* Matlab

## Preparation
* If you want to play with the dataset used in the paper, please download the video dataset named `'vids'` from [here](https://ieee-dataport.org/documents/rolling-shutter-videos-enf-extraction-0), upzip, and put it under the directory `./code_release/`
* If you want to examine your own video(s), get your own video(s) ready and follow the procedures below
  * Create a folder named `'vids'`under the directory `./code_release/`
  * Create a folder under the folder `'vids'` that should have the same filename as your video to be investigated. For example, your video is named `'iPhoneVideo_sample1.'` Then, the folder named `'iPhoneVideo_sample1'` is created and located under the directory `./code_release/vids/`
  * Put your video under the directory `./code_release/vids/iPhoneVideo_sample1/`
  * If you have a power reference signal for your video, name it `'power_YourVideoFileName'`, i.e., `'power_iPhoneVideo_sample1'`, and put it under the directory `./code_release/vids/iPhoneVideo_sample1/`
  * Create two .txt files named `'nominalFreq'` and `'Tro'` and put them under the directory `./code_release/vids/iPhoneVideo_sample1/`
    * `'nominalFreq.txt'`: should contain a nominal ENF where your video was captured, i.e., 50 or 60
    * `'Tro.txt'`: should contain the camera read-out time for the device you used for capturing your video
  * For other videos, repeat the processes above

## Usage
* Open each script file named `'main1_Figs.7.(a)(e)(d)(h)_Fig.10.m'`, `'main2_Fig.8.m'`, and `'main3_Figs.7.(c)(g)'` and run sequentially each section divided by %%
  * `'main1_Figs.7.(a)(e)(d)(h)_Fig.10.m'` draws spectrograms and extract ENF signals
    * NOTE: The second section starting with "[step 1]" generates .mat files, which may take some time. If you want to avoid the wait, download the mat file dataset named `'mats'` for the video dataset `'vids'` from [here](Put site) and put each .mat file into the corresponding directory. For example, the mat file named `'rowSig_iPhoneVideo0.mat'` should be put under the directory `./code_release/vids/iPhoneVideo0/`
  * `'main2_Fig.8.m'` quantatively compares two extraction methods
  * `'main3_Figs.7.(c)(g)'` compares practical scalar values versus theoretical scalar values for aliased ENF components
