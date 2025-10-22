setwd("C:/Users/windows/OneDrive - 南京大学/桌面/临时文件夹/douyin_multimodal")

library(readxl)
library(sjPlot)

data <- read_excel("C:/Users/windows/OneDrive - 南京大学/桌面/临时文件夹/douyin_multimodal/douyin_multimodal.xlsx")

data$rhythm <- data$节奏
data$loudness <- data$响度
data$lightness <- data$平均明亮度
data$hue <- data$平均色相
data$saturation <- data$平均纯度
data$duration <- data$视频时长
data$facenum <- data$人脸数量
data$tagnum <- data$tag数量
data$description <- data$描述长度
data$posemo <- data$积极情感
data$nagemo <- data$消极情感
data$fannum <- data$粉丝量
data$likenum <- data$获赞
data$videonum <- data$作品
data$album <- data$有无合集
data$live <- data$有无直播
data$gender <- data$男女

data$like <- data$点赞数
data$comment <- data$评论数
data$repost <- data$分享数
data$collect <- data$收藏数

like_reg <- lm(like ~ rhythm+loudness+lightness+hue+saturation+duration+facenum+tagnum+description+posemo+nagemo+fannum+likenum+videonum
               +as.factor(album)+as.factor(live)+as.factor(gender), data = data)
summary(like_reg)
like_regtable <- stargazer(like_reg, type = "html")
writeLines(like_regtable, "like_table.html")

comment_reg <- lm(comment ~ rhythm+loudness+lightness+hue+saturation+duration+facenum+tagnum+description+posemo+nagemo+fannum+likenum+videonum
               +as.factor(album)+as.factor(live)+as.factor(gender), data = data)
summary(comment_reg)
comment_regtable <- stargazer(comment_reg, type = "html")
writeLines(comment_regtable, "comment_table.html")

collect_reg <- lm(collect ~ rhythm+loudness+lightness+hue+saturation+duration+facenum+tagnum+description+posemo+nagemo+fannum+likenum+videonum
               +as.factor(album)+as.factor(live)+as.factor(gender), data = data)
summary(collect_reg)
collect_regtable <- stargazer(collect_reg, type = "html")
writeLines(collect_regtable, "collect_table.html")

repost_reg_lm <- lm(repost ~ rhythm+loudness+lightness+hue+saturation+duration+facenum+tagnum+description+posemo+nagemo+fannum+likenum+videonum
                  +as.factor(album)+as.factor(live)+as.factor(gender), data = data)
summary(repost_reg_lm)
repost_lm_regtable <- stargazer(repost_reg_lm, type = "html")
writeLines(repost_lm_regtable, "repost_lm_table.html")

repost_reg_poiss <- glm(repost ~ rhythm+loudness+lightness+hue+saturation+duration+facenum+tagnum+description+posemo+nagemo+fannum+likenum+videonum
                  +as.factor(album)+as.factor(live)+as.factor(gender), family = poisson(), data = data)
summary(repost_reg_poiss)
repost_poiss_regtable <- stargazer(repost_reg_poiss, type = "html")
writeLines(repost_poiss_regtable, "repost_poiss_table.html")

result1 <- list(like_reg, comment_reg, collect_reg, repost_reg_lm)
tab_model(result1)

result2 <- list(like_reg, comment_reg, collect_reg, repost_reg_poiss)
tab_model(result2)
