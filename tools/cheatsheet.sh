# Creating efficient GIF from video with subtitles

ffmpeg -y -i input.mp4 -filter_complex "fps=15,scale=600:-1:flags=lanczos,subtitles=subtitles.srt,palettegen" palette.png

ffmpeg -y -i input.mp4 -i palette.png -filter_complex "fps=15,scale=600:-1:flags=lanczos,subtitles=subtitles.srt[x];[x][1:v]paletteuse" -r 10 output.gif
