%% 分别读取两段视频，并通过裁剪的方式得到256*256大小的图像块
sample_dataset('蓝藻视频\7120.mp4', 2500, 'vd1');
sample_dataset('蓝藻视频\7942.mp4', 2500, 'vd2');

imgs = imageDatastore(["vd1", "vd2"], "LabelSource", "foldernames");

%%
sample_dataset('蓝藻视频\7120(2).mp4', 500, 'vd3');
sample_dataset('蓝藻视频\7942（2）.mp4', 500, 'vd4');

img7120 = imageDatastore('vd3', "LabelSource", "foldernames");
img7942 = imageDatastore('vd4', "LabelSource", "foldernames");
%%
predict_result_7120 = trainedNetwork_1.predict(img7120);
probability_7120 = sum(predict_result_7120)/500;

predict_result_7942 = trainedNetwork_1.predict(img7942);
probability_7942 = sum(predict_result_7942)/500;
%% 用到的函数
function sample_dataset(video_path, sample_number, target_dir)
if ~isfolder(target_dir)
    mkdir(target_dir)
end

vid = VideoReader(video_path);
w = vid.Width;
h = vid.Height;

% 算出每个样本的取样位置
X = randi(w-256, [sample_number,1]);
Y = randi(h-256, [sample_number,1]);
FID = randi(vid.NumFrames, [sample_number, 1]);

h = waitbar(0,"Sampling images...");
for sample_id = 1:sample_number
    waitbar(sample_id / sample_number, h, ['Sampling images...' num2str(sample_id) '/' num2str(sample_number)])
    % 对所有帧做灰度化和直方图均衡化
    video_frame = vid.read(FID(sample_id));
    new_image_sample = histeq(rgb2gray(video_frame), 256);
    %转成灰度图节约时间，histeq直方图均衡化防止视频亮度不同影响判断
    new_image_sample = new_image_sample(Y:(Y+255), X:(X+255));
    imwrite(new_image_sample, fullfile(target_dir, [num2str(sample_id) '.jpg']))
end
close(h)
%关闭进度条

end
