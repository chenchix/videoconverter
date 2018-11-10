#!/bin/bash 
IFS='
'
set -f


FILES=$(find $DIR -not -path '*/\.*' -type f \( ! -iname ".*" \) -name '*mov')

for j in ${FILES[@]}; do
	FILE=$(basename "${j}")
	DIR=$(dirname "${j}")
	i=$(echo $j |sed 's/ /\\ /g' )
	k=$(echo $j |sed 's/\.//g' |sed 's/mov//g' |sed 's/ /_/g' |sed 's/\//_/g' )
	T=${FILE%%.*}
	
	echo "${FILE} - ${DIR} - ${i} - ${k}" 
	#mkdir -p $T
	cd ${DIR}
	if [ ! -f "${FILE}.done" ]; then
		cd -
		echo "Extracting video from $i"
		$(sh -c "ffmpeg -i ${i} -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -an 2018/$T.nosound.mp4")

		#echo "Extracting audio from $i"
		#$(sh -c "ffmpeg -i ${i} -acodec ac3_fixed -vn 2018/$T.ac3")

		echo "Extracting channels from $i"
		$(sh -c "ffmpeg -i ${i} -map 0:a:0 -c ac3 2018/left.wav -map 0:a:1 -c ac3 2018/right.wav")

		echo "Re-encoding original video"
		$(sh -c "ffmpeg -i 2018/$T.nosound.mp4 -i 2018/left.wav -map 0:0 -map 1:0 -c:v copy -c:a copy 2018/$k.original.mp4")

		echo "Creating video translated"
		$(sh -c "ffmpeg -i 2018/$T.nosound.mp4 -i 2018/right.wav -map 0:0 -map 1:0 -c:v copy -c:a copy 2018/$k.translated.mp4")


		rm -rf 2018/$T.nosound.mp4 2018/*ac3 2018/*wav

		cd ${DIR}
		touch ${FILE}.done
		cd -
	else
		cd -
		echo "Video already processed ${i}"
	fi
	
done


