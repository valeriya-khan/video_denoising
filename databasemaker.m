%cuttng video into frames and saving as images
workingDir = tempname;
mkdir(workingDir)
mkdir(workingDir,'images')
ii = 1;
shuttleVideo = VideoReader('robt310_proj3_expert_vkhan.avi');
while hasFrame(shuttleVideo)
   img = readFrame(shuttleVideo);
   filename = [sprintf('%03d',ii) '.jpg'];
   fullname = fullfile(workingDir,'images',filename);
   imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
   ii = ii+1;
end