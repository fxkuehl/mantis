#!/bin/sh

cd ${0%/*}

# Supersampling
size=$((1920*3))

sizeL=$size,$((size*9/16))
sizeP=$((size*3/4)),$size

# Sizes to scale down to
sizes="1920 960 640"

images="mantis.png mantis_bare.png mantis_naked.png mantis_top.png mantis_bottom.png mantis_exploded.png"

params="--colorscheme=DeepOcean -D \$fa=1 -D render_pcbs=true -D bottom_color=\"purple\" -D top_color=\"white\""

trap 'echo "Killing background processes ..."; kill $jobs' INT

echo "Perspective view ..."
openscad $params --camera=7,12,0,45,0,15,320 --imgsize=$sizeL \
	-o mantis.png mantis.scad &
jobs="$jobs $!"

echo "Bare-bones view ..."
openscad $params --camera=7,12,0,45,0,15,320 --imgsize=$sizeL \
	-D show_key=false -o mantis_bare.png mantis.scad &
jobs="$jobs $!"

echo "Naked view ..."
openscad $params --camera=7,12,0,45,0,15,320 --imgsize=$sizeL \
	-D show_key=false -D show_switch=false -o mantis_naked.png mantis.scad &
jobs="$jobs $!"

echo "Top-down view ..."
openscad $params --camera=0,12,0,0,0,0,350 --imgsize=$sizeL \
	--projection=ortho -o mantis_top.png mantis.scad &
jobs="$jobs $!"

echo "Bottom-up view ..."
openscad $params --camera=0,12,0,180,0,180,350 --imgsize=$sizeL \
	-o mantis_bottom.png mantis.scad &
jobs="$jobs $!"

echo "Exploded view ..."
openscad $params --camera=0,30,220,65,0,15,1200 --imgsize=$sizeP \
	-D \$explode=60 --projection=ortho -o mantis_exploded.png mantis.scad &
jobs="$jobs $!"

wait || {
	rm -f $images
	exit 1
}

jobs=""

for size in $sizes; do
	mkdir -p ../assets/$size
done

for img in $images; do
	for size in $sizes; do
		echo "Downscaling $img to $size"
		convert $img -colorspace RGB -gaussian-blur 0x1 -attenuate 0.1 +noise Gaussian -resize ${size}x${size} -sampling-factor 4:2:0 -strip -quality 95 -interlace JPEG ../assets/$size/v0.3-${img%.png}.jpg &
		jobs="$jobs $!"
	done
done

wait || {
	rm -f $images
	exit 1
}

rm -f $images
