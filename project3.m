%% Saving images in to cellArrayOfImages
for k = 1:512
	jpgFileName = strcat(num2str(k,'%03.f'), '.jpg');
	if exist(jpgFileName, 'file')
		imageData = rgb2gray(imread(jpgFileName));
        cellArrayOfImages{k} = imageData;
	else
		fprintf('File %s does not exist.\n', jpgFileName);
    end
end
%% Removing salt and pepper noise with median filter
for k=1:512
    cellArrayOfImages{k}=medfilt2(cellArrayOfImages{k});
end
%% Found approach
for k=1:512
    I=cellArrayOfImages{k};
    PQ = size(I);
    %Create Notch filters corresponding to extra peaks in the Fourier transform
    H1 = notch('gaussian', PQ(1), PQ(2), 4, 9, 5);
    H2 = notch('gaussian', PQ(1), PQ(2), 4, 17, 9);
    H3 = notch('gaussian', PQ(1), PQ(2), 4, 34, 16);
    H4 = notch('gaussian', PQ(1), PQ(2), 4, -7, -3);
    H5 = notch('gaussian', PQ(1), PQ(2), 4, -15, -7);
    H6 = notch('gaussian', PQ(1), PQ(2), 4, -32, -14);
    % Calculate the discrete Fourier transform of the image
    F=fft2(double(I),PQ(1),PQ(2));
    % Apply the notch filters to the Fourier spectrum of the image
    FS_I = F.*H1.*H2.*H3.*H4.*H5.*H6;
    fi=fftshift(FS_I);
    F_I=real(ifft2(FS_I));
    % Saving in array
    cellArrayOfImages{k}=uint8(F_I);
end
%% Saving image of frequency domain in order to make mask 
% imgArr=zeros(512,512);
% for k=1:512
%     imgArr(:,k)=cellArrayOfImages{k}(:,50);
% end
% ft = fftshift(fft2(imgArr));
% ft=mat2gray(log(1+abs(ft)));
% %imwrite(ft,'mask2.png');

%% Making mask consist of 1 and 0
imgArr=zeros(512,512);
I=rgb2gray(imread('mask2.png'));
for i=1:512
    for j=1:512
        if I(i,j)>0
            I(i,j)=1;
        else
            I(i,j)=0;
        end
    end
end
%% Applying mask and saving the result
for i=1:512
    for k=1:512
        imgArr(:,k)=cellArrayOfImages{k}(:,i);
    end
    freq=fftshift(fft2(imgArr));
    imshow(log(1+abs(freq)),[]);
    pause(1);
    freq1=freq.*double(I);
    finv=ifft2(ifftshift(freq1));
    for k=1:512
        cellArrayOfImages{k}(:,i)=finv(:,k);
    end
end
%% Histogram matching
for i=2:512
    img=real(cellArrayOfImages{i});
    cellArrayOfImages{i}=imhistmatch(img,real(cellArrayOfImages{100}));
end
%% Creating output video (please change file address to appropriate one)
shuttleVideo = VideoReader('robt310_proj3_expert_vkhan.avi');
outputVideo = VideoWriter(fullfile('/home/valeriya/Рабочий �?тол/Imageproc/project 3','out.avi'));
outputVideo.FrameRate = shuttleVideo.FrameRate;
open(outputVideo)
for ii = 1:512
   img = cellArrayOfImages{ii};
   writeVideo(outputVideo,img);
end
close(outputVideo)