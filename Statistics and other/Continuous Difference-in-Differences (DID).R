### 请把Scapegoating_share_logit修改成原始数据（去除logit) ###

# 1. 加载包
install.packages("fixest")  
library(fixest)

# 2. 读取数据
df <- read.csv("D:/德国犹太报道/最终面板/面板数据_含Exposure_Index.csv")

# 3. 创建 Post1933 断点变量
df$Post1933 <- ifelse(df$Year >= 1933, 1, 0)

# 4. 提取每个城市1932年的 Nazi_Support 值，合并回原始数据
# 先提取1932年这一年的支持率
support_1932 <- df[df$Year == 1932, c("City", "Nazi_Support")]
names(support_1932)[2] <- "Nazi_Support_1932"  # 改名方便识别

# 合并1932支持率到完整数据框（按城市合并）
df <- merge(df, support_1932, by = "City", all.x = TRUE)

# 5. Logit 变换因变量（避免 log(0) 错误）
df$Scapegoating_Share_logit <- log(df$Scapegoating_Share / (1 - df$Scapegoating_Share))

# 6. 运行连续型DID模型c (变量依此加入)

model_C_1 <- feols(
  Scapegoating_Share_logit ~ Post1933 * Nazi_Support_1932 | City + Year,
  data = df,
  cluster = ~City)

model_C_2 <- feols(
  Scapegoating_Share_logit ~ Post1933 * Nazi_Support_1932 + Wage_corrected  | City + Year,
  data = df,
  cluster = ~City)

model_C_3 <- feols(
  Scapegoating_Share_logit ~ Post1933 * Nazi_Support_1932 + Wage_corrected + Jewish_Pop_Share | City + Year,
  data = df,
  cluster = ~City)


# 7. 查看结果并依此添加入三线图
summary(model_C_1)
summary(model_c_2)
summary(model_c_3)



## 平行趋势检验（event study),ref = -1的意思是以设置的冲击点前一年，比如冲击点要是1933，-1就是
# 以1932年为基准。这里也可以试一试一开始的数据，比如1924（去掉1923年的话）。

# Nazi_Support_1932指的是1932年纳粹支持率

model_event_continuous <- feols(
  Scapegoating_Share_logit ~ i(event_time, Nazi_Support_1932, ref = -1) +
    Wage_corrected + Jewish_Pop_Share | City,
  data = df_event,
  cluster = ~City)

event_df <- broom::tidy(model_event_continuous, conf.int = TRUE)

# 保留交互项
event_df_filtered <- event_df %>%
  filter(grepl("event_time::", term)) %>%
  mutate(
    year = as.numeric(gsub(".*event_time::(-?\\d+).*", "\\1", term))
  )

# 画图
library(ggplot2)
library(showtext)  # 用于加载中文字体

showtext_auto()  # 自动启用中文字体

# 设置中文字体，例如微软雅黑（也可换成系统有的字体）
windowsFonts(myfont = windowsFont("微软雅黑"))

ggplot(event_df_filtered, aes(x = year, y = estimate)) +
  geom_line(color = "#0072B2", size = 1.2) +
  geom_point(color = "#0072B2", size = 2.2) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.4, color = "#0072B2") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray30") +
  geom_hline(yintercept = 0, linetype = "dotted", color = "gray30") +
  labs(
    title = "事件研究：纳粹支持对替罪羊行为的影响",
    x = "相对于1933年的年份",
    y = "纳粹支持对替罪羊比例的影响"
  ) +
  theme_minimal(base_size = 13, base_family = "myfont")