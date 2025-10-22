library(plm)
library(lmtest)
library(lme4)
library(glmmTMB)
library(dplyr)
library(nortest)
library(ggplot2)
library(data.table)
library(fixest)
library(tidyverse)
library(data.table)
library(tidyr)
library(readr)
library(ggplot2)
library(tidyLPA)
library(bruceR)
library(blavaan)  
library(semTools)
library(tidyr)
library(dplyr)
library(readstata13)
library(rcompanion)
library(effsize)
library(readxl)
library(dplyr)
library(sf)
# 导入数据
panel_data <- read_csv("D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\总面板数据\\panel_data_update.csv", 
                       col_types = cols(stateicp = col_character(), countyicp = col_character()))


############################################
#######对各个变量的描述性统计###############
############################################
# outcome
Describe(panel_data$white_sup_ratio,digits = 3)

# Treatments
Describe(panel_data$slave_ratio,digits = 3)

# Controls
Describe(panel_data$totpop,digits = 3)
Describe(panel_data$totpop,digits = 3)

panel_data$free_black_ratio <- panel_data$fctot / panel_data$totpop * 100
Describe(panel_data$free_black_ratio,digits = 3)
Describe(panel_data$acimp,digits = 3)
Describe(panel_data$water,digits = 3)
Describe(panel_data$rail,digits = 3)
Describe(panel_data$farm_value_per,digits = 3)
Describe(panel_data$proportion_farm_50,digits = 3)
Describe(panel_data$manufacture_out_per,digits = 3)
Describe(panel_data$wealth_per,digits = 3)
Describe(panel_data$cotton,digits = 3)

# Supplement
Describe(panel_data$black_white_labor_ratio,digits = 3)

###############################################
####1860年南方各县的奴隶比例描述图#############
###############################################
# 单独提取出每个县的slave_ratio
county_slave_ratio <- panel_data[, c("stateicp", "countyicp", "state_county", "slave_ratio")]
county_slave_ratio_unique <- unique(county_slave_ratio)
county_slave_ratio_unique <- county_slave_ratio_unique[!is.na(county_slave_ratio_unique$slave_ratio), ]

# 匹配fips
county_state_icpcode <- read_excel("D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\newspaper.com 爬取\\full_icp_fips_mappings.xlsx")
colnames(county_state_icpcode) <- tolower(colnames(county_state_icpcode))

# 合并数据
county_slave_fips <- county_slave_ratio_unique %>%
  left_join(county_state_icpcode, by = c("stateicp", "countyicp"))

# 去除没匹配上的fips的县
county_slave_fips  <- county_slave_fips  %>%filter(!is.na(countyfips))


# 加载历史地图县级数据（1920年县级）
historical_map_county <- st_read(
  dsn = "D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\1920年地图数据\\US_AtlasHCB_Counties\\US_AtlasHCB_Counties\\US_HistCounties_Shapefile", 
  layer = "US_HistCounties")

map_1920_county <- historical_map_county[historical_map_county$START_N <= 19201231 & historical_map_county$END_N >= 19201231, ]

map_1920_county <- map_1920_county[map_1920_county$STATE_TERR %in% c("Alabama", "Arkansas", "Florida", "Georgia", "Kentucky", "Louisiana",
                                                                      "Mississippi", "Missouri", "North Carolina", "South Carolina", "Tennessee", "Texas",
                                                                      "Virginia", "West Virginia"), ]

# 合并地图数据slave_ratio
# 组成FIPS列
county_slave_fips$statefips <- as.character(county_slave_fips$statefips)
county_slave_fips$countyfips <- as.character(county_slave_fips$countyfips)
county_slave_fips$FIPS <- paste0(county_slave_fips$statefips, county_slave_fips$countyfips)

map_county_slave_fips <- map_1920_county %>%
  left_join(
    county_slave_fips,by = "FIPS")


# slave程度颜色分组
slave_ratio_bins <- cut(
  map_county_slave_fips$slave_ratio, 
  breaks = c(0, 20, 40, 60, 80, 100), 
  include.lowest = TRUE,right = FALSE)

# 将 NA 值标记为 "No Data"
map_county_slave_fips$slave_group <- as.character(slave_ratio_bins)
map_county_slave_fips$slave_group[is.na(map_county_slave_fips$slave_ratio)] <- "No Data"


# 确保分组是因子类型，添加 "No Data" 为一个级别
map_county_slave_fips$slave_group <- factor(
  map_county_slave_fips$slave_group, 
  levels = c(levels(slave_ratio_bins), "No Data"))

unique(map_county_slave_fips$slave_group)
levels(map_county_slave_fips$slave_group)

# 分配颜色，包括 "No Data"
mcols <- c( "#F0F0F0", "#D9D9D9", "#B3B3B3", "#8C8C8C", "#666666", alpha("#FFFFFF", 0))
names(mcols) <- c("[0,20)", "[20,40)", "[40,60)", "[60,80)", "[80,100]", "No Data")

# 将分组和对应颜色添加到数据框
map_county_slave_fips$slave_color <- mcols[map_county_slave_fips$slave_group]


# 绘制地图
pdf("D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\总面板数据\\slave_ratio_map.pdf", width = 10, height = 10)
ggplot(data = map_county_slave_fips) +
  geom_sf(aes(fill = slave_group), color = "grey50", size = 0.5) +  
  scale_fill_manual(
    values = mcols,  # 分配颜色
    labels = c("0 ~ 20%", "20 ~ 40%", "40 ~ 60%", "60 ~ 80%", "80 ~ 100%", "No Data"),  # 图例标签
    name = ""  # 图例标题
  ) + 
  theme_minimal() + 
  labs(
    title = "slave_ratio_map_1860"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),  # 标题居中
    legend.position = c(0.9, 0.2),   # 图例位置
    legend.title = element_text(size = 12),  # 图例标题字体大小
    legend.text = element_text(size = 10),  # 图例文字字体大小
    axis.text = element_blank(),  # 移除轴标签
    axis.ticks = element_blank(),  # 移除轴刻度线
    axis.title = element_blank(),   # 移除轴标题
    panel.grid = element_blank()  # 移除网格线
  )
dev.off()

##############################################
####1865年之前各县的white_sup_ratio情况#######
##############################################
white_sup_before_1865 <- panel_data %>%
  filter(year < 1865) %>%
  group_by(stateicp,countyicp,state_county) %>%
  summarize(mean_white_sup_ratio = mean(white_sup_ratio, na.rm = TRUE))

white_sup_before_1865 <- white_sup_before_1865[!is.na(white_sup_before_1865$mean_white_sup_ratio), ]

# 匹配fips
county_state_icpcode <- read_excel("D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\newspaper.com 爬取\\full_icp_fips_mappings.xlsx")
colnames(county_state_icpcode) <- tolower(colnames(county_state_icpcode))

# 合并数据
county_white_sup_fips <- white_sup_before_1865 %>%
  left_join(county_state_icpcode, by = c("stateicp", "countyicp"))

# 去除没匹配上的fips的县
county_white_sup_fips  <- county_white_sup_fips  %>%filter(!is.na(countyfips))


# 加载历史地图县级数据（1920年县级）
historical_map_county <- st_read(
  dsn = "D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\1920年地图数据\\US_AtlasHCB_Counties\\US_AtlasHCB_Counties\\US_HistCounties_Shapefile", 
  layer = "US_HistCounties")

map_1920_county <- historical_map_county[historical_map_county$START_N <= 19201231 & historical_map_county$END_N >= 19201231, ]

map_1920_county <- map_1920_county[map_1920_county$STATE_TERR %in% c("Alabama", "Arkansas", "Florida", "Georgia", "Kentucky", "Louisiana",
                                                                     "Mississippi", "Missouri", "North Carolina", "South Carolina", "Tennessee", "Texas",
                                                                     "Virginia", "West Virginia"), ]

# 合并地图数据white_sup_ratio
# 组成FIPS列
county_white_sup_fips$statefips <- as.character(county_white_sup_fips$statefips)
county_white_sup_fips$countyfips <- as.character(county_white_sup_fips$countyfips)
county_white_sup_fips$FIPS <- paste0(county_white_sup_fips$statefips, county_white_sup_fips$countyfips)

map_county_white_sup_fips <- map_1920_county %>%
  left_join(
    county_white_sup_fips,by = "FIPS")


# 分组
#zero_group <- map_county_white_sup_fips %>%filter(mean_white_sup_ratio == 0)
#zero_group$sup_group <- "0"

#non_zero_data <- map_county_white_sup_fips[map_county_white_sup_fips$mean_white_sup_ratio != 0, ]
white_sup_ratio_bins <- cut(
  map_county_white_sup_fips$mean_white_sup_ratio, 
  breaks = c(0,0.0001,1,2,3,25), 
  include.lowest = TRUE,right = FALSE)

map_county_white_sup_fips$sup_group <- as.character(white_sup_ratio_bins)

#map_county_white_sup_fips <- rbind(zero_group, non_zero_data)
map_county_white_sup_fips$sup_group[is.na(map_county_white_sup_fips$mean_white_sup_ratio)] <- "No Data"


# 确保分组是因子类型，添加 "No Data" 为一个级别
map_county_white_sup_fips$sup_group <- factor(
  map_county_white_sup_fips$sup_group, 
  levels = c(levels(white_sup_ratio_bins), "No Data"))

unique(map_county_white_sup_fips$sup_group)

# 分配颜色，包括 "No Data"
mcols <- c( "#F0F0F0", "#D9D9D9", "#B3B3B3", "#8C8C8C", "#666666", alpha("#FFFFFF", 0))
names(mcols) <- c("[0,0.0001)","[0.0001,1)", "[1,2)", "[2,3)", "[3,25]","No Data")


# 将分组和对应颜色添加到数据框
map_county_white_sup_fips$sup_color <- mcols[map_county_white_sup_fips$sup_group]

# 绘制地图
pdf("D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\总面板数据\\white_sup_ratio_map_before1865.pdf", width = 10, height = 10)
ggplot(data = map_county_white_sup_fips) +
  geom_sf(aes(fill = sup_group), color = "grey50", size = 0.5) +  
  scale_fill_manual(
    values = mcols,  # 分配颜色
    labels = c("0","0 ~ 1%", "1 ~ 2%", "2 ~ 3%", "3 ~ 25%","No Data"),  # 图例标签
    name = ""  # 图例标题
  ) + 
  theme_minimal() + 
  labs(
    title = "white_sup_ratio_map_before1865"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),  # 标题居中
    legend.position = c(0.9, 0.2),   # 图例位置
    legend.title = element_text(size = 12),  # 图例标题字体大小
    legend.text = element_text(size = 10),  # 图例文字字体大小
    axis.text = element_blank(),  # 移除轴标签
    axis.ticks = element_blank(),  # 移除轴刻度线
    axis.title = element_blank(),   # 移除轴标题
    panel.grid = element_blank()  # 移除网格线
  )
dev.off()


##############################################
####1865年之后各县的white_sup_ratio情况#######
##############################################
white_sup_after_1865 <- panel_data %>%
  filter(year > 1865) %>%
  group_by(stateicp,countyicp,state_county) %>%
  summarize(mean_white_sup_ratio = mean(white_sup_ratio, na.rm = TRUE))

white_sup_after_1865 <- white_sup_after_1865[!is.na(white_sup_after_1865$mean_white_sup_ratio), ]

# 匹配fips
county_state_icpcode <- read_excel("D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\newspaper.com 爬取\\full_icp_fips_mappings.xlsx")
colnames(county_state_icpcode) <- tolower(colnames(county_state_icpcode))

# 合并数据
county_white_sup_fips <- white_sup_after_1865 %>%
  left_join(county_state_icpcode, by = c("stateicp", "countyicp"))

# 去除没匹配上的fips的县
county_white_sup_fips  <- county_white_sup_fips  %>%filter(!is.na(countyfips))


# 加载历史地图县级数据（1920年县级）
historical_map_county <- st_read(
  dsn = "D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\1920年地图数据\\US_AtlasHCB_Counties\\US_AtlasHCB_Counties\\US_HistCounties_Shapefile", 
  layer = "US_HistCounties")

map_1920_county <- historical_map_county[historical_map_county$START_N <= 19201231 & historical_map_county$END_N >= 19201231, ]

map_1920_county <- map_1920_county[map_1920_county$STATE_TERR %in% c("Alabama", "Arkansas", "Florida", "Georgia", "Kentucky", "Louisiana",
                                                                     "Mississippi", "Missouri", "North Carolina", "South Carolina", "Tennessee", "Texas",
                                                                     "Virginia", "West Virginia"), ]

# 合并地图数据white_sup_ratio
# 组成FIPS列
county_white_sup_fips$statefips <- as.character(county_white_sup_fips$statefips)
county_white_sup_fips$countyfips <- as.character(county_white_sup_fips$countyfips)
county_white_sup_fips$FIPS <- paste0(county_white_sup_fips$statefips, county_white_sup_fips$countyfips)

map_county_white_sup_fips <- map_1920_county %>%
  left_join(
    county_white_sup_fips,by = "FIPS")


# 程度颜色分组
white_sup_ratio_bins <- cut(
  map_county_white_sup_fips$mean_white_sup_ratio, 
  breaks = c(0,0.0001,1,2,3,25),
  include.lowest = TRUE,right = FALSE)

# 将 NA 值标记为 "No Data"
map_county_white_sup_fips$sup_group <- as.character(white_sup_ratio_bins)
map_county_white_sup_fips$sup_group[is.na(map_county_white_sup_fips$mean_white_sup_ratio)] <- "No Data"


# 确保分组是因子类型，添加 "No Data" 为一个级别
map_county_white_sup_fips$sup_group <- factor(
  map_county_white_sup_fips$sup_group, 
  levels = c(levels(white_sup_ratio_bins), "No Data"))

unique(map_county_white_sup_fips$sup_group)

# 分配颜色，包括 "No Data"
mcols <- c( "#F0F0F0", "#D9D9D9", "#B3B3B3", "#8C8C8C", "#666666", alpha("#FFFFFF", 0))
names(mcols) <- c("[0,0.0001)","[0.0001,1)", "[1,2)", "[2,3)", "[3,25]","No Data")

# 将分组和对应颜色添加到数据框
map_county_white_sup_fips$sup_color <- mcols[map_county_white_sup_fips$sup_group]


# 绘制地图
pdf("D:\\American Stories\\自由的代价：经济竞争如何塑造美国南北战争后的种族仇恨叙事？\\总面板数据\\white_sup_ratio_map_after1865_.pdf", width = 10, height = 10)
ggplot(data = map_county_white_sup_fips) +
  geom_sf(aes(fill = sup_group), color = "grey50", size = 0.5) +  
  scale_fill_manual(
    values = mcols,  # 分配颜色
    labels = c("0","0 ~ 1%", "1 ~ 2%", "2 ~ 3%", "3 ~ 25%","No Data"),  # 图例标签
    name = ""  # 图例标题
  ) + 
  theme_minimal() + 
  labs(
    title = "white_sup_ratio_map_before1865"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16),  # 标题居中
    legend.position = c(0.9, 0.2),   # 图例位置
    legend.title = element_text(size = 12),  # 图例标题字体大小
    legend.text = element_text(size = 10),  # 图例文字字体大小
    axis.text = element_blank(),  # 移除轴标签
    axis.ticks = element_blank(),  # 移除轴刻度线
    axis.title = element_blank(),   # 移除轴标题
    panel.grid = element_blank()  # 移除网格线
  )
dev.off()






