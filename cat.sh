#! /bin/bash
 
#調試模式
#set -x
 
#上传目录
logdate=$(date +%Y%m%d%H%M%S)
today=$(date +%Y-%m-%d)
path_upload=/home/tv/src
path_m3u8=/home/tv/m3u8

function cut_m3u8(){
	mkdir -p $path_m3u8/$today/${weiyi_md5} &&
	openssl rand 16 > enc.key
	echo "enc.key" > enc.keyinfo
	echo $PWD/"enc.key" >> enc.keyinfo
	openssl rand -hex 16 >> enc.keyinfo 
 
	ffmpeg -y -i $path_upload/$filemp4 -c copy -map 0 -hls_time 10 -hls_key_info_file enc.keyinfo -hls_playlist_type vod -hls_segment_filename "$path_m3u8/$today/${weiyi_md5}/file%d.ts" $path_m3u8/$today/${weiyi_md5}/playlist.m3u8 
	ffmpeg -ss 05.28 -i $path_upload/$filemp4 -vframes 1 $path_m3u8/$today/${weiyi_md5}/thumb.jpg -y &&
	str=$filemp4
	echo ${str%%.*}
	abc=${str%%.*}
	echo $abc
	cp -f $path_upload/$abc.jpg   $path_m3u8/$today/${weiyi_md5}/thumb.jpg
	mv   enc.key $path_m3u8/$today/${weiyi_md5}/
	echo "$name	${weiyi_md5}	$today	`date +%F_%R`" >> /home/tv/link$logdate.txt 
	echo >> /home/tv/link$logdate.txt 
}

#   curl "http://10.39.1.177/video.php?weiyi_md5=${weiyi_md5}&title=${name}&tv_link="/${weiyi_md5}/playlist.m3u8"&pic="/${weiyi_md5}/thumb.jpg"
 
 
#循环在upload查找所有的MP4格式文件
for file in `find $path_upload  | grep 'mp4'`
do
    #对视频文件生成md5值
    weiyi_md5=`md5sum ${file} |cut -d ' ' -f 1`
    echo ${weiyi_md5}
    #截取影片名称
    name1=${file%*.mp4// /}
    echo $name1
    name=${name1##*/}
    echo $name
  #  mv -f  /home/tv/sc/$abc.jpg   $path_m3u8/$today/${weiyi_md5}/thumb.jpg
  
    #合并MP4文件名，和m3u8文件名。
    filem3u8=`eval echo $name.m3u8`
    filemp4=`eval echo $name.mp4`
    #截取upload下影片文件夹名称
    path1=${file%/*}
    echo $path1
    path=${path1##*/}
    echo $path
    #data={"weiyi_md5":"${weiyi_md5}","title":"${name1}"}
    cut_m3u8

done

