#!/bin/bash

# 遍历 /e8clib 目录下的所有文件和目录
for file in /e8clib/*; do
  # 如果文件或链接已经存在于 /lib 目录，则跳过
  if [[ -e "/lib/$(basename "$file")" ]]; then
    echo "Skipping $(basename "$file") as it already exists in /lib"
    continue
  fi

  # 创建链接到 /lib 目录
  ln -s "$file" "/lib/$(basename "$file")"
  echo "Linked $(basename "$file") to /lib"
done
