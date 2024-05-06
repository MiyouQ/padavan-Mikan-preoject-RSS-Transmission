#!/bin/sh

# 下载RSS内容到本地文件
RSS_FOLDER="/media/AiDisk_a1/rss"
mkdir -p "$RSS_FOLDER"
RSS_LINKS="
    https://mikanime.tv/RSS/Search?searchstr=ANI+%E7%BE%8E%E5%A5%BD+%E7%A5%9D%E7%A6%8F+3
    https://mikanime.tv/RSS/Search?searchstr=ANI+%E9%BB%91%E6%89%A7%E4%BA%8B+%E5%AF%84%E5%AE%BF
    # 添加更多的 RSS 链接
"

# 下载多个 RSS 文件
for RSS_LINK in $RSS_LINKS; do
    # 从链接中提取文件名并手动添加 .xml 后缀
    FILENAME=$(basename "$RSS_LINK" | sed 's/?searchstr=/_/')  # 替换特殊字符
    wget -q "$RSS_LINK" -O "${RSS_FOLDER}/${FILENAME}.xml"
done

# 切换到指定目录
cd /media/AiDisk_a1/transmission/watch || exit

# 已下载的.torrent文件记录文件
DOWNLOADED_FILE="${RSS_FOLDER}/downloaded_files.txt"
touch "$DOWNLOADED_FILE"

# 处理每个 RSS 文件
for RSS_FILE in "$RSS_FOLDER"/*.xml; do
    # 如果没有找到 XML 文件，则跳过
    [ -e "$RSS_FILE" ] || continue

    # 提取.torrent链接并下载对应的文件
    grep -o 'url="[^"]*\.torrent"' "$RSS_FILE" | cut -d'"' -f2 | while read -r TORRENT_URL; do
        # 提取.torrent文件名
        FILENAME=$(basename "$TORRENT_URL" .torrent).torrent

        # 检查是否已下载过该.torrent文件
        if grep -q "${FILENAME%%.torrent}" "$DOWNLOADED_FILE"; then
            echo "已经下载过 $FILENAME，跳过..."
            continue
        fi

        # 下载.torrent文件到指定目录
        wget -q "$TORRENT_URL" -P /media/AiDisk_a1/transmission/watch

        # 记录已下载的.torrent文件
        echo "${FILENAME%%.torrent}" >> "$DOWNLOADED_FILE"

        echo "已下载 $FILENAME"
    done
done

# 删除下载的RSS文件
rm "${RSS_FOLDER}"/*.xml
