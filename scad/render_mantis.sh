#!/bin/sh

dir=`pwd`
cd ${0%/*}

version=1.0
scad="mantis-v$version.scad"

# Supersampling
size=$((1920*3))

sizeW=$size,$((size*9/16))
sizeL=$size,$((size*3/4))
sizeP=$((size*3/4)),$size

# Sizes to scale down to
sizes="1920 960 640"

images="mantis.png mantis_bare.png mantis_naked.png mantis_top.png mantis_bottom.png mantis_exploded.png"

params="--colorscheme=DeepOcean -D \$fs=0.5 -D \$fa=1 -D render_pcbs=true -D bottom_color=\"purple\" -D top_color=\"white\""

trap 'echo "Killing background processes ..."; kill $jobs' INT

echo "Perspective view ..."
openscad $params --camera=15,12,10,50,0,22,450 --imgsize=$sizeW \
	-o "$dir/mantis.png" $scad &
jobs="$jobs $!"

echo "Bare-bones view ..."
openscad $params --camera=15,12,10,50,0,22,450 --imgsize=$sizeW \
	-D show_trackball=false -D show_key=false \
	-o "$dir/mantis_bare.png" $scad &
jobs="$jobs $!"

echo "Naked view ..."
openscad $params --camera=15,12,10,50,0,22,450 --imgsize=$sizeW \
	-D show_trackball=false -D show_key=false -D show_switch=false \
	-D case_alpha=0.4 -o "$dir/mantis_naked.png" $scad &
jobs="$jobs $!"

echo "Top-down view ..."
openscad $params --camera=5,25,0,0,0,30,500 --imgsize=$sizeL \
	--projection=ortho -o "$dir/mantis_top.png" $scad &
jobs="$jobs $!"

echo "Bottom-up view ..."
openscad $params --camera=0,8,0,180,0,180,400 --imgsize=$sizeW \
	-D case_alpha=0.2 -D show_desk=false -o "$dir/mantis_bottom.png" $scad &
jobs="$jobs $!"

echo "Exploded view ..."
openscad $params --camera=5,30,220,65,0,15,1250 --imgsize=$sizeP \
	-D show_desk=false -D \$explode=60 --projection=ortho \
	-o "$dir/mantis_exploded.png" $scad &
jobs="$jobs $!"

wait || {
	for img in $images; do
		rm -f "$dir/$img"
	done
	exit 1
}

jobs=""

for size in $sizes; do
	mkdir -p "$dir/$size"
done

for img in $images; do
	for size in $sizes; do
		echo "Downscaling $img to $size"
		convert "$dir/$img" -colorspace RGB -gaussian-blur 0x1 -attenuate 0.1 +noise Gaussian -resize ${size}x${size} -sampling-factor 4:2:0 -strip -quality 95 -interlace JPEG "$dir/$size/v$version-${img%.png}.jpg" &
		jobs="$jobs $!"
	done
done

wait || {
	for img in $images; do
		rm -f "$dir/$img"
	done
	exit 1
}

for img in $images; do
	rm -f "$dir/$img"
done
