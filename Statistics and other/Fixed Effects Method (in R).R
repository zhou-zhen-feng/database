
setwd("D:/Zhenfeng Zhou/课程作业合辑/homicide_narrative")

library(fixest)
library(sjPlot)
library(mediation)

data <- read.csv("D:/Zhenfeng Zhou/课程作业合辑/homicide_narrative/useful_filter.csv")

data$moral <- (data$care + data$fairness + data$loyalty + data$authority + data$purity) / 5

#### Data Exploration ####

## Economic ##

economic_homi <- feols(homrat ~ rtsalepi+cpi | citycode, data = data)
summary(economic_homi)

economic_sui <- feols(suicrat ~ rtsalepi+cpi | citycode, data = data)
summary(economic_sui)

## Relief ##

relief_homi <- feols(homrat ~ dirrel+worrel+cwa+wpa+private+stypc | citycode, data = data)
summary(relief_homi)

relief_sui <- feols(suicrat ~ dirrel+worrel+cwa+wpa+private+stypc | citycode, data = data)
summary(relief_sui)

## Population ##

population_homi <- feols(homrat ~ pctblk+pctill+pcturb+prurnf+pforb | citycode, data = data)
summary(population_homi)

population_sui <- feols(suicrat ~ pctblk+pctill+pcturb+prurnf+pforb | citycode, data = data)
summary(population_sui)

## Politics ##

politics_homi <- feols(homrat ~ pdemup+pdemlo+govdem | citycode, data = data)
summary(politics_homi)

politics_sui <- feols(suicrat ~ pdemup+pdemlo+govdem | citycode, data = data)
summary(politics_sui)

### Results ###

homi <- feols(homrat ~ rtsalepi+cpi+dirrel+worrel+cwa+wpa+private+stypc+
                pctblk+pctill+pcturb+prurnf+pforb+pdemup+pdemlo+govdem | citycode, data = data)
summary(homi)

sui <- feols(suicrat ~ rtsalepi+cpi+dirrel+worrel+cwa+wpa+private+stypc+
                pctblk+pctill+pcturb+prurnf+pforb+pdemup+pdemlo+govdem | citycode, data = data)
summary(sui)

data_explo_homi <- list(economic_homi, relief_homi, population_homi, politics_homi, homi)
tab_model(data_explo_homi)

data_explo_sui <- list(economic_sui, relief_sui, population_sui, politics_sui, sui)
tab_model(data_explo_sui)

#### Morals as Mediators ####

## Morals mediates Economic ##

# Homicide #

economic_moral_homi_1 <- lm(homrat ~ rtsalepi+cpi, data = data)
summary(economic_moral_homi_1)
economic_moral_homi_2 <- lm(moral ~ rtsalepi+cpi, data = data)
summary(economic_moral_homi_2)
economic_moral_homi_3 <- lm(homrat ~ rtsalepi+cpi+moral, data = data)
summary(economic_moral_homi_3)
economic_moral_homi <- mediate(economic_moral_homi_2, economic_moral_homi_3, treat = "cpi", mediator = "moral")
summary(economic_moral_homi)

# Suicide #

economic_moral_sui_1 <- lm(suicrat ~ rtsalepi+cpi, data = data)
summary(economic_moral_sui_1)
economic_moral_sui_2 <- lm(moral ~ rtsalepi+cpi, data = data)
summary(economic_moral_sui_2)
economic_moral_sui_3 <- lm(suicrat ~ rtsalepi+cpi+moral, data = data)
summary(economic_moral_sui_3)
economic_moral_sui <- mediate(economic_moral_sui_2, economic_moral_sui_3, treat = "cpi", mediator = "moral")
summary(economic_moral_sui)
