function driftRanges = calculatedriftRange(folderPath, windowsize)
% 计算文件夹中每个vxp文件中的波形进行平均值滤波后的漂移值
% 输入: folderpath - 包含VXP文件的文件夹路径；windowsize - 滤波窗口大小（可选，默认值为25）
% 输出: driftRanges - 结构体数组，包含文件名和对应的漂移值

arguments
    folderPath (1,1) string
    windowsize (1,1) double {mustBePositive, mustBeInteger} = 25
end

% 获取所有txt文件列表
fileList = dir(fullfile(folderPath, '*.vxp'));

% 初始化结果结构体
driftRanges = struct('filename', {}, 'range', {});

% 检查是否有txt文件
if isempty(fileList)
    warning('文件夹中没有找到txt文件！');
    return;
end

% 遍历处理每个文件
for i = 1:length(fileList)
    filename = fullfile(folderPath, fileList(i).name);
    
    try
        % 读取文件数据
        fid = fopen(filename, 'r');
        wave = textscan(fid, '%f %*[^\n]', 'HeaderLines',8);
        wave = wave{1,1};
        fclose(fid);
        % 检查波形数据是否为空
        if isempty(wave)
            rangeValue = NaN;
            warning('文件 %s 为空，返回NaN', fileList(i).name);
        else
            %应用平均值滤波
            filteredwave=movmean(wave,windowsize)*10;

            % 计算极差（最大值-最小值）
            minVal = min(filteredwave(:));
            maxVal = max(filteredwave(:));
            rangeValue = round(maxVal - minVal, 2);
        end
        
        % 存储结果
        driftRanges(i).filename = fileList(i).name;
        driftRanges(i).range = rangeValue;
        
    catch ME
        % 错误处理
        warning('文件 %s 处理失败: %s', fileList(i).name, ME.message);
        driftRanges(i).filename = fileList(i).name;
        driftRanges(i).range = NaN;
    end
end

% 显示结果表格
fprintf('\n处理完成！结果汇总：\n');
disp(struct2table(driftRanges));
end