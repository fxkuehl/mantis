#!/bin/sh

dir=`pwd`
cd ${0%/*}

version=1.0
scad="mantis-v$version.scad"
cust="${scad%.scad}.json"
osc=`which openscad-nightly`
colors=DeepOcean
params=""
if [ ! -x "$osc" ]; then
	osc="openscad"
else
	params="--backend=Manifold"
fi

if [ -n "$1" ]; then
	params="$params -p$cust -P$1"
	shift 1
fi
if [ -n "$1" ]; then
	colors="$1"
	shift 1
fi

# Supersampling
size=$((1920*3))

sizeW=$size,$((size*9/16))
sizeL=$size,$((size*3/4))
sizeP=$((size*3/4)),$size

# Sizes to scale down to
sizes="1920 1440 1152"

images="mantis.png mantis_rear.png mantis_bare.png mantis_naked.png mantis_top.png mantis_bottom.png mantis_exploded.png"

params="$params --colorscheme=$colors -D \$fs=0.5 -D \$fa=1 -D render_pcbs=true -D bottom_color=\"purple\" -D top_color=\"white\" -D shadow_softness=6"

trap 'echo "Killing background processes ..."; kill $jobs' INT

persp_cam=15,0,10,45,0,22,450
rear_cam=15,40,10,45,0,150,450
bottom_cam=-15,30,10,225,0,135,450

echo "Perspective view ..."
$osc $params --camera=$persp_cam --imgsize=$sizeW \
	-o "$dir/mantis.png" "$@" $scad &
jobs="$jobs $!"

echo "Rear view ..."
$osc $params --camera=$rear_cam --imgsize=$sizeW \
	-o "$dir/mantis_rear.png" "$@" $scad &
jobs="$jobs $!"

echo "Bare-bones view ..."
$osc $params --camera=$persp_cam --imgsize=$sizeW \
	-D show_trackball=false -D show_key=false \
	-o "$dir/mantis_bare.png" "$@" $scad &
jobs="$jobs $!"

echo "Naked view ..."
$osc $params --camera=$persp_cam --imgsize=$sizeW \
	-D show_trackball=false -D show_key=false -D show_switch=false \
	-D case_alpha=0.4 -o "$dir/mantis_naked.png" "$@" $scad &
jobs="$jobs $!"

echo "Top-down view ..."
$osc $params --camera=5,25,0,0,0,30,500 --imgsize=$sizeL \
	--projection=ortho -o "$dir/mantis_top.png" "$@" $scad &
jobs="$jobs $!"

echo "Bottom-up view ..."
#$osc $params --camera=0,8,0,180,0,180,400 --imgsize=$sizeW \
#	-D case_alpha=0.2 -D show_desk=false --projection=ortho \
#	-o "$dir/mantis_bottom.png" "$@" $scad &
$osc $params --camera=$bottom_cam --imgsize=$sizeL \
	-D case_alpha=0.4 -D show_desk=false \
	-o "$dir/mantis_bottom.png" "$@" $scad &
jobs="$jobs $!"

echo "Exploded view ..."
#$osc $params --camera=5,30,270,65,0,15,1300 --imgsize=$sizeP \
#	-D \$explode=40 -D fast_shadow=false --projection=ortho \
#	-o "$dir/mantis_exploded.png" "$@" $scad &
$osc $params --camera=10,30,180,65,0,15,1150 --imgsize=$sizeP \
	-D \$explode=30 -D show_desk=false \
	-o "$dir/mantis_exploded.png" "$@" $scad &
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
		convert "$dir/$img" -colorspace RGB -gaussian-blur 0x1 -attenuate 0.1 +noise Gaussian -resize ${size}x${size} -sampling-factor 4:2:0 -colorspace sRGB -strip -quality 95 -interlace JPEG "$dir/$size/v$version-${img%.png}.jpg" &
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
