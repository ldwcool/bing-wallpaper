#!/bin/bash

# 定义远程仓库地址
REMOTE_REPO_URL="git@github.com:ldwcool/bing-wappler.git"

# 进入脚本所在目录
cd "$(dirname "$0")"

# 发送curl请求并将响应保存到文件
curl -o ./bing_image.json "https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&nc=1587287726147&pid=hp"

# 检查是否已安装jq
if ! command -v jq &> /dev/null; then
    echo "jq 工具未安装，正在安装..."
    sudo apt update
    sudo apt install -y jq
fi

# 使用jq解析JSON并提取字段
enddate=$(jq -r '.images[0].enddate' bing_image.json)
urlbase=$(jq -r '.images[0].urlbase' bing_image.json)
title=$(jq -r '.images[0].title' bing_image.json)
copyright=$(jq -r '.images[0].copyright' bing_image.json)

# 删除临时文件
rm bing_image.json

# 删除空格
copyright=$(echo "${copyright}" | sed 's/ //g')

# 删除右括号 )
copyright=$(echo "${copyright}" | sed 's/)//g')

# 替换 (  / + 为下划线
copyright=$(echo "${copyright}" | sed 's/[(\/+]/_/g')

# 拼接URL
url="https://cn.bing.com${urlbase}_UHD.jpg"

# 删除标题中的问号
title=$(echo "${title}" | sed 's/\?//g')

imagefilename="${enddate}_${title}_${copyright}.jpg"

# 下载图片到当前目录
curl -o "./${imagefilename}" "$url"

# 检查当前目录是否为Git仓库
if [ ! -d ".git" ]; then
    # 如果不是Git仓库，初始化为Git仓库并配置默认远程仓库地址
    git init
    git remote add origin "${REMOTE_REPO_URL}"
fi

git add .
git commit -m "添加图片：${imagefilename}"
# 执行git pull以确保同步远程更改
git pull origin master
# 推送更改
git push -u origin master

