rm(list = ls())        # remove all variables in memory

### Get the directory ofcurrent script (only for r-studio)
curWD <- dirname(rstudioapi::getSourceEditorContext()$path) 
setwd(curWD)


library(bruceR)
library(tidyverse)
library(dplyr)
library(lavaan)
library(semTools)

data<-read.csv("Final_COVIDiSTRESS_Vol2_cleaned.csv")

##check BRS
Freq(data$resilience_1)

#清理存在缺失值的个体
#使用 complete.cases() 函数检查从 resilience_1 到 resilience_6 的变量
complete_rows <- complete.cases(data[, c("resilience_1", "resilience_2", "resilience_3",
                                         "resilience_4", "resilience_5", "resilience_6")])
# 过滤数据集，只保留完整的行
filtered_data <- data[complete_rows, ]

# 计算从 resilience_1 到 resilience_6 的变量
cor_matrix1 <- cor(filtered_data[, c("resilience_1", "resilience_2", "resilience_3", 
                                     "resilience_4", "resilience_5", "resilience_6")])

print(cor_matrix1) # Item2/4/6 should be reversed

filtered_data$BRS1<-filtered_data$resilience_1
filtered_data$BRS2<-8-filtered_data$resilience_2
filtered_data$BRS3<-filtered_data$resilience_3
filtered_data$BRS4<-8-filtered_data$resilience_4
filtered_data$BRS5<-filtered_data$resilience_5
filtered_data$BRS6<-8-filtered_data$resilience_6

cor_matrix2 <- cor(filtered_data[, c("BRS1", "BRS2", "BRS3", 
                                     "BRS4", "BRS5", "BRS6")])
print(cor_matrix2)

data_step1<-filtered_data

##check sex
class(data_step1$gender)
Freq(data_step1$gender)

data_step1$sex<-factor(data_step1$gender)

data_step1$sex<-as.numeric(data_step1$sex)
Freq(data_step1$sex) #1 Female, 2 Male

# 删除 sex 中不为 1 和 2 的行
filtered_data <- data_step1[data_step1$sex %in% c(1, 2), ]
data_step2<-filtered_data

##check age
complete_rows <- complete.cases(data_step2[, c("age")])
# 过滤数据集，只保留完整的行
filtered_data <- data_step2[complete_rows, ]

# 使用cut函数将年龄变量分组
# 分组逻辑：https://link.springer.com/article/10.1007/s10804-022-09412-9
filtered_data$agerange <- cut(filtered_data$age,
                              breaks = c(-Inf, 29, 45, 65, Inf),
                              labels = c(1, 2, 3, 4),
                              right = TRUE)

# 显示结果
print(filtered_data$agerange)
Freq(filtered_data$agerange)

data_step3<-filtered_data


##check country

# 计算每个选项的选择次数
option_counts <- table(data_step3$residing_country)
print(option_counts)

# 筛选出选择次数大于等于 200 的选项
selected_options <- names(option_counts[option_counts >= 200])
print(selected_options)


# 根据筛选出的选项保留数据集中对应的样本
filtered_data <- data_step3[data_step3$residing_country %in% selected_options, ]

filtered_data$country<-factor(filtered_data$residing_country)

filtered_data$country<-as.numeric(filtered_data$country)

Freq(filtered_data$residing_country)
Freq(filtered_data$country) #国家从1-21排序


data_step4<-filtered_data



# 计算social identification
# 选择中立选项为中位数
Alpha(data_step4, 
      vars = cc("identity_1_midneutral,identity_2_midneutral,identity_3_midneutral,
                identity_4_midneutral")) # 0.751

data_step4$identification_mean<-rowMeans(data_step4[,c("identity_1_midneutral","identity_2_midneutral",
                                                       "identity_3_midneutral","identity_4_midneutral")])

Describe(data_step4$identification_mean)


#整合BRS总分和两个因子得分
Alpha(data_step4, 
      vars = cc("BRS1,BRS2,BRS3,BRS4,BRS5,BRS6")) #Cronbach’s α = 0.878

Alpha(data_step4, 
      vars = cc("BRS1,BRS3,BRS5")) #Cronbach’s α = 0.787

Alpha(data_step4, 
      vars = cc("BRS2,BRS4,BRS6")) #Cronbach’s α = 0.842

#计算均值
data_step4$BRS_mean<-rowMeans(data_step4[,c("BRS1","BRS2","BRS3","BRS4","BRS5","BRS6")])
data_step4$BRS_Posi<-rowMeans(data_step4[,c("BRS1","BRS3","BRS5")])
data_step4$BRS_Nega<-rowMeans(data_step4[,c("BRS2","BRS4","BRS6")])

Describe(data_step4$BRS_mean)
Describe(data_step4$BRS_Posi)
Describe(data_step4$BRS_Nega)


##perceived social support (对中立选项两种计分方式0或中位数，这里选择中位数)
Freq(data_step4$perceived_support_1_midneutral)

Alpha(data_step4, 
      vars = cc("perceived_support_1_midneutral,
                perceived_support_2_midneutral,
                perceived_support_3_midneutral")) #Cronbach’s α = 0.873
#计算均值
data_step4$perceivedsupport<-rowMeans(data_step4[,c("perceived_support_1_midneutral",
                                                    "perceived_support_2_midneutral",
                                                    "perceived_support_3_midneutral")])
Describe(data_step4$perceivedsupport)
Describe(data_step4$PSUP_3_midneutral_avg)


# 验证中介关系
library(mediation)

BRS <- data_step4$BRS_mean
perceivedsupport <- data_step4$perceivedsupport
identification <- data_step4$identification_mean

# 中介变量为DV,系数是a.
model.m <- lm(perceivedsupport ~ identification, data=data_step4)
summary(model.m)
confint(model.m)

# y为DV，中介和X作为变量，算的是c'和b
model.y <- lm(BRS ~ identification + perceivedsupport, data=data_step4)
summary(model.y)
confint(model.y)

# y为DV，X为IV
model.y0 <- lm(BRS ~ identification, data=data_step4)
summary(model.y0)
confint(model.y0)



# 第二种方式计算中介
BRS <- data_step4$BRS_mean
perceivedsupport <- data_step4$perceivedsupport
identification <- data_step4$identification_mean

brs_support_iden_1 <- lm(BRS ~ identification, data = data_step4)
summary(brs_support_iden_1)

brs_support_iden_2 <- lm(perceivedsupport ~ identification, data = data_step4)
summary(brs_support_iden_2)

brs_support_iden_3 <- lm(BRS ~ identification + perceivedsupport, data = data_step4)
summary(brs_support_iden_3)

brs_support_iden <- mediate(brs_support_iden_2, brs_support_iden_3, treat = "identification", mediator = "perceivedsupport")
summary(brs_support_iden)










