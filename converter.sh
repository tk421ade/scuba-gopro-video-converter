#!/bin/bash
set -e

# https://dubiouscreations.com/2018/05/28/video-editing-on-linux-action-cam-scuba-diving-videos/
# https://gist.github.com/nonoesp/d54f7b905c2c6a9d3c14db27c721ff34


# Parse named parameters
while getopts ":i:o:" opt; do
  case ${opt} in
    i) input_file_folder="$OPTARG";;
    o) output_folder="$OPTARG";;
    \?) echo "Invalid option: -$OPTARG"; exit 1;;
  esac
done

# Check if the required parameters are set
if [ -z "$input_file_folder" ] || [ -z "$output_folder" ]; then
  echo "Usage: $0 -i <input file or folder> -o <folder output>"
  exit 1
fi

CURRENT_DIR=$(pwd)

# validate output folder
if [[ "$output_folder" == /* ]]; then
  full_output_folder="${output_folder}"
else
  full_output_folder="${CURRENT_DIR}/${output_folder}"
fi

if [ ! -d "$full_output_folder" ]; then
  echo "Output folder '${full_output_folder}' does not exist"
  exit 1
fi

# validate input file/folder
if [[ "$input_file_folder" == /* ]]; then
  full_input_file_folder="${input_file_folder}"
else
  full_input_file_folder="${CURRENT_DIR}/${input_file_folder}"
fi

if [ ! -e "$full_input_file_folder" ]; then
  echo "Input file/folder '${full_input_file_folder}' does not exist"
  exit 1
fi

if [ -d "$full_input_file_folder" ]; then
  input_videos=($(find $full_input_file_folder -maxdepth 1 -type f -name "*.MP4"))
else
  input_videos=("$full_input_file_folder")
fi

# prepare temporal folders
TMP_INPUT_FRAMES="/tmp/scuba-converter-input/"
TMP_OUTPUT_FRAMES="/tmp/scuba-converter-output/"

mkdir -p "$TMP_INPUT_FRAMES"
mkdir -p "$TMP_OUTPUT_FRAMES"

process_video() {
  video_fullpath_input=$1
  video_filename_input=$(basename "$video_fullpath_input")
  video_filename_output=$(basename "$video_fullpath_output")
  video_fullpath_output="${full_output_folder}/${video_filename_input%.*}_CONVERTED.${video_filename_input##*.}"
  #echo "video_fullpath_input: '${video_fullpath_input}', video_fullpath_output: '${video_fullpath_output}'"
  #echo "video_filename_input: '${video_filename_input}', video_filename_output: '${video_filename_output}'"
  video_filename_input_noextension="${video_filename_input%.*}"
  #echo "video_filename_input_noextension: '${video_filename_input_noextension}', video_filename_output_noextension: '${video_filename_output_noextension}'"

  echo
  echo "> Processing video: ${video_filename_input} ... "
  echo
  echo

  # create the frames
  ffmpeg -i "$video_fullpath_input" "${TMP_INPUT_FRAMES}/${video_filename_input_noextension}_%09d_out.jpg"

  #convert every frame
  cd "$TMP_INPUT_FRAMES"
  for file in *_out.jpg; do
    # Your command here, using "$file" as the variable
    echo "Processing $file"
    convert "$file" -separate -contrast-stretch 0.35%x0.7%  -combine "${TMP_OUTPUT_FRAMES}/${file}"
  done

  cd "$CURRENT_DIR"

  echo "Merging Frames ..."
  ffmpeg -y -framerate 50 -pattern_type glob -i "${TMP_OUTPUT_FRAMES}/*.jpg" "$video_fullpath_output"
  echo
  echo "> '${video_fullpath_output}' completed "
  echo
  echo

  # clean up
  rm $TMP_INPUT_FRAMES"$video_filename_input_noextension"*.jpg
  rm $TMP_OUTPUT_FRAMES"$video_filename_input_noextension"*.jpg
}


for video in "${input_videos[@]}"; do
  process_video "$video"
done

echo "Video processing completed"

