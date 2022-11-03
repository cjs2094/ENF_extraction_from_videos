# Code for Analysis of ENF Signal Extraction From Videos Acquired by Rolling Shutters
This repository contains an implementation of the following paper:

[Analysis of ENF Signal Extraction From Videos Acquired by Rolling Shutters](https://www.techrxiv.org/articles/preprint/Analysis_of_ENF_Signal_Extraction_From_Videos_Acquired_by_Rolling_Shutters/21300960)

Jisoo Choi, Chau-Wai Wong, Hui Su, and Min Wu, "[Analysis of ENF signal extraction from videos acquired by rolling shutters](https://www.techrxiv.org/articles/preprint/Analysis_of_ENF_Signal_Extraction_From_Videos_Acquired_by_Rolling_Shutters/21300960)," submitted to
*IEEE Transactions on Information Forensics and Security (T-IFS)*, under review.

**DOI**: [10.36227/techrxiv.21300960.v1](https://doi.org/10.36227/techrxiv.21300960.v1)

If you used any of the code or the dataset, please cite our paper as listed above

## Requirement
Matlab

## Preparation
* If you want to play with the dataset used in the paper, please download the video dataset named `'vids.zip'` from the following URL:
[https://ieee-dataport.org/documents/rolling-shutter-videos-enf-extraction-0](https://ieee-dataport.org/documents/rolling-shutter-videos-enf-extraction-0), upzip, and put it under the directory `./code_release/`
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
* For the dataset used in the paper, open each script file named `'main1_Figs7aedh10.m'`, `'main2_Fig8.m'`, and `'main3_Fig7cg'` and run sequentially each section divided by %%
  * `'main1_Figs7aedh10.m'` draws spectrograms and extract ENF signals
    * NOTE: The second section starting with "[step 1]" generates .mat files, which may take some time. If you want to avoid the wait, download the mat file dataset named `'mats.zip'` for the video dataset `'vids'` from the following URL:
[https://ieee-dataport.org/documents/rolling-shutter-videos-enf-extraction-0](https://ieee-dataport.org/documents/rolling-shutter-videos-enf-extraction-0), upzip it, and put each .mat file into the corresponding directory. For example, the mat file named `'rowSig_iPhoneVideo0.mat'` should be put under the directory `./code_release/vids/iPhoneVideo0/`
  * `'main2_Fig8.m'` quantatively compares two extraction methods
  * `'main3_Fig7cg'` compares practical scalar values versus theoretical scalar values for aliased ENF components
* For your own video(s), the entry point is the script file named `'main1_Figs7aedh10.m'`. Run the entire sections in the script to draw spectrograms and extract ENF signals

## Contact
Jisoo Choi, email: [cjs2094@gmail.com](cjs2094@gmail.com)
