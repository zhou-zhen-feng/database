
rm(list = ls())        # remove all variables in memory

### Get the directory ofcurrent script (only for r-studio)
curWD <- dirname(rstudioapi::getSourceEditorContext()$path) 
setwd(curWD)


library(transforEmotion)

setup_miniconda()


zhangsanvideo <- "zhangsan.mp4"
jianguovideo  <- "jianguo.mp4"
jiejievideo  <-"https://www.youtube.com/watch?v=ERZt8ntiXCo" #通过视频链接提取
emotions <- c("excitement", "happiness", "pride",
              "anger", "fear", "sadness",
              "neutral")
zhangsan.emotions <- video_scores(zhangsanvideo, classes = emotions, 
                                 nframes = 200, save_video = TRUE, #一共抽取200帧画面
                                 save_frames = TRUE, video_name = 'zhangsan',
                                 start = 10, end = 120)
jianguo.emotions <- video_scores(jianguovideo, classes = emotions, 
                                 ffreq = 5, save_video = TRUE, #平均每5帧抽取1帧画面
                                  save_frames = TRUE, video_name = 'jianguo',
                                  start = 10, end = 50) 

jiejie.emotions <- video_scores(jiejievideo, classes = emotions, 
                                 ffreq = 2, save_video = TRUE, #平均每2帧抽取1帧画面
                                 save_frames = TRUE, video_name = 'jianguo',
                                 start = 1, end = 10) 

library(zoo)
library(ggpubr)

#罗翔视频
zhangsan.emotions$frame <- 1:nrow(zhangsan.emotions)
zhangsan.emotions[,1:7] <- rollmean(zhangsan.emotions[,1:7], 5, fill = NA, align = "center")

zhangsan.long <- reshape::melt(zhangsan.emotions[,-7], id.vars = "frame")
custom_colors <- c("#D01B1B", "red", "lightpink",
                   "lightblue", "#47abd8" , "#1B1BD0")
ggline(zhangsan.long, x = 'frame', y = "value", color = "variable",
       plot_type = "l", xlab = "Frame", ylab = "FER Score",
       palette = custom_colors) +
  theme_classic() + theme(legend.position = "bottom") +
  labs(color = "Emotion")

#特朗普视频
jianguo.emotions$frame <- 1:nrow(jianguo.emotions)
jianguo.emotions[,1:7] <- rollmean(jianguo.emotions[,1:7], 5, fill = NA, align = "center")
 
jianguo.long <- reshape::melt(jianguo.emotions[,-7], id.vars = "frame")
custom_colors <- c("#D01B1B", "red", "lightpink",
                   "lightblue", "#47abd8" , "#1B1BD0")
ggline(jianguo.long, x = 'frame', y = "value", color = "variable",
       plot_type = "l", xlab = "Frame", ylab = "FER Score",
       palette = custom_colors) +
  theme_classic() + theme(legend.position = "bottom") +
  labs(color = "Emotion")

#小姐姐视频
jiejie.emotions$frame <- 1:nrow(jiejie.emotions)
jiejie.emotions[,1:7] <- rollmean(jiejie.emotions[,1:7], 5, fill = NA, align = "center")

jiejie.long <- reshape::melt(jiejie.emotions[,-7], id.vars = "frame")
custom_colors <- c("#D01B1B", "red", "lightpink",
                   "lightblue", "#47abd8" , "#1B1BD0")
ggline(jiejie.long, x = 'frame', y = "value", color = "variable",
       plot_type = "l", xlab = "Frame", ylab = "FER Score",
       palette = custom_colors) +
  theme_classic() + theme(legend.position = "bottom") +
  labs(color = "Emotion")
