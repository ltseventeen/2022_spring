%% 我们首先读入两种藻的光谱数据，这是用readtable()实现的。
% 这个函数很简单。你可以在命令行窗口打入"help readtable"查看这个函数的作用。
spec_algae1_table = readtable('娜（本组数据）/7120.csv');
spec_algae2_table = readtable('娜（本组数据）/7942（新）.csv');

% 运行这一节会弹出两个警报，但这不需要担心，这是因为文件的第一行不是表头。
% 所以，MATLAB把第二行当作表头，然后通过警告的方式告诉你。

%% 但是，有的同学把自己的数据分成了好几个文件，所以上面这节的代码对你不适用。
% 如果你很不幸就是这么干的，那么恭喜，你现在将小小地体会到数据整理不规范带来的……没错，痛苦。
% 庆幸你不是在处理一个好几十TB的数据集吧，因为好在这儿整理数据不是很难。
% 现在你只需要动脑筋读入这几个文件，并且把它们整合成一个table。
% 提示：如果两个表格的表头全都不一样，表格与表格之间就可以通过[表格1,表格2]合并。
% 例如，我可以用new_table = [spec_algae1_table, spec_algae2_table];来
% 合并spec_algae1_table和spec_algae2_table——假如两个表格里没有重复的表头的话。
% 当然，也还有一个笨办法：你可以用Excel打开多个csv文件，然后复制黏贴，手动把它们拼成一个。
% 祝你好运。

%% 下面我们整理一下光谱数据，把它们分别放到两个array里。
% 所以，你现在可以看到，两个array的每行是一个光谱数据。这个光谱数据是经过插值的，
% 插值的范围是300到799，一共500个数值。
% 然后，这些光谱数据还经过了所谓的正规化，或者叫做normalization，
% 也就是减掉平均值，再除以标准差，
% 这样就可以让浓的藻类样本和稀的藻类样本的吸光度处于类似的水平,
% 从而避免浓度为数据方差做贡献，这样浓度就不会让PCA算法疑惑了。

% 我们先规定好插值的X值：
interpolation_range = 300:799;

% 这里的函数：sort_spectra_into_array，可以在文件末尾看到
spec_algae1 = sort_spectra_into_array(spec_algae1_table, interpolation_range);
spec_algae2 = sort_spectra_into_array(spec_algae2_table, interpolation_range);

%% 我们可以把这些归一化的光谱画出来看一下，这很简单。
% 有的同学的光谱里混入了奇怪的东西，可以通过这张图检查，然后决定是否去掉，
% 去掉的方式就是手动从csv里面找到它，然后把它删掉（注意一条光谱一共有两列！），
% 然后重新跑一遍前面的代码。

% 要画图，先figure。不写figure也可以，但如果要画很多图就会引发混乱。
figure;

% 然后选两种颜色，把两种光谱分别画出来就可以了
% 这里用hold on，否则新做的图会把旧的图覆盖掉
hold on;
plot(interpolation_range, spec_algae1, 'r');
plot(interpolation_range, spec_algae2, 'b');

% 最后给x轴和y轴加上标签
xlabel('Wavelength (nm)')
ylabel('Normalized Abs')

%% 下面我们尝试PCA
% 首先把所有光谱堆到一起
spec_for_pca = [spec_algae1; spec_algae2];
%分号表示用第一个方向堆积（竖着堆积），逗号表示延第二个方向堆积（横着堆积）

% 然后，创建一组标签，防止我们忘了这些被堆到一起的光谱分别属于哪种藻类。
% 我现在假定algae1是7120，algae2是7942，这不一定适用于你的情况，所以先弄明白再运行：
spec_algae_type = [ones(size(spec_algae1, 1), 1)*7120; ones(size(spec_algae2, 1), 1)*7942];

% 实际上一行命令就可以做PCA了，是不是很方便？
% 这里我们将只请求前6个主成分。你也可以尝试观察更多的主成分。
% 如果报错了，说明你没有安装Statistics and Machine Learning Toolbox
PC_number = 6;
[pcs, spec_transformed, ~, ~, variance_explained] = pca(spec_for_pca, "NumComponents", PC_number);
%"~"代表不需要，不保存的数据。spec_transformed是基，最后一个是解释的方差

% 下面我们绘一些图来检查主成分分析的效果。

%% 首先将前6个主成分画出来，你发现了什么？
figure;
for pc_id = 1:PC_number
    subplot(PC_number, 1, pc_id)
    %将6个主成分拆成6个子图，并用1~6命名
    plot(interpolation_range, pcs(:, pc_id));
end
%从主成分1~6，毛刺越来越多

%% 然后将光谱到前两个主成分的投影画出来。如果不出意外，你应该可以画一条直线，将两种藻的投影隔开
figure; hold on; %hold on让机子不要把前面的图清掉
scatter(spec_transformed(spec_algae_type==7120, 1), spec_transformed(spec_algae_type==7120, 2), 5, 'red', 'filled');
%red 红点；filled 填充（不然画出来是一堆圈）
scatter(spec_transformed(spec_algae_type==7942, 1), spec_transformed(spec_algae_type==7942, 2), 5, 'blue', 'filled');
legend('7120', '7942')%加图例
xlabel('PC1'); ylabel('PC2')

%% 最后检查一下我们的每个主成分分别解释了数据的多少方差。不出意外的话，前4个主成分基本就能解释数据的所有方差
figure;
plot(variance_explained)
xlabel('PC')
ylabel('Variance Explained (%)')

% 你可以计算一下，前4个主成分解释了多少方差？
%可以发现，第一个主成分解释了绝大多数方差，前三个主成分基本上已经把数据解释完了

%% 作为一个附加，我们展示一下怎么做t-SNE，你可以观察t-SNE和PCA的效果
% t-SNE也很好做：
[embedding, KLDiv] = tsne(spec_for_pca);

% 上面的KLDiv的含义是"KL散度"。我们不会介绍它，
% 你只需要知道t-SNE和CNN一样，也是一个用梯度下降的算法，
% 而它的损失函数是原数据和嵌入之间的KL散度，所以KLDiv越小越好。

% 然后绘图
figure; hold on; 
scatter(embedding(spec_algae_type==7120, 1), embedding(spec_algae_type==7120, 2), 5, 'red', 'filled');
scatter(embedding(spec_algae_type==7942, 1), embedding(spec_algae_type==7942, 2), 5, 'blue', 'filled');
legend('7120', '7942')
xlabel('t-SNE1'); ylabel('t-SNE2')

% 如果不出意外，你也可以画一条直线把两种藻的光谱的t-SNE二维嵌入分开。
% 所以，直观上看，你觉得t-SNE与PCA的降维效果有什么区别？

%% 这是上面用到的函数：
function specs = sort_spectra_into_array(spec_table, x)
% 我们首先计算一下spec_table里面有多少条光谱数据：
spec_number = floor(size(spec_table, 2) / 2);

% 创建一个空array用来存储光谱：
specs = zeros(spec_number, length(x));

% 对于每条光谱，都做一下处理再放进specs里面
for spec_id = 1:spec_number

    % 先插值
    new_spec = interp1(spec_table{:, spec_id*2-1}, spec_table{:, spec_id*2}, x);
    
    % 再正规化
    new_spec = (new_spec - mean(new_spec)) / std(new_spec);

    % 最后放进specs里
    specs(spec_id, :) = new_spec;
end

end
