****************************************
******ba和ws网络分开跑————面板回归*******
****************************************

****streaming student ba****
* 步骤 1: 导入 CSV 文件（含变量名）
import delimited "C:\Users\lenovo\Desktop\two way fixed effects\division_ba.csv", clear

* 步骤 3: 检查数据类型（尤其是 id 和 time_step_hour 是否为数值）
destring id time_step_hour, replace force

* 步骤 5: 面板数据设定（不强制执行 xtset，但推荐设定一次）
xtset id time_step_hour

* 步骤 6: 执行面板回归 + 双重固定效应（id + time_step_hour）
reghdfe attitude hungry tired safe social sadness joy fear disgust anger surprise, absorb(id time_step_hour) vce(cluster id)

* 使用outreg2输出结果到Word文档
outreg2 est1 using  "C:\\Users\\lenovo\\Desktop\\agentsociety\\回归分析\\table2.doc",replace  bdec(3) se sdec(3)  ctitle(atti_student_ba) addtext(Agentid FE, Yes , time FE, Yes) 



****streaming student ws****
* 步骤 1: 导入 CSV 文件（含变量名）
import delimited "C:\Users\lenovo\Desktop\two way fixed effects\division_ws.csv", clear

* 步骤 3: 检查数据类型（尤其是 id 和 time_step_hour 是否为数值）
destring id time_step_hour, replace force

* 步骤 5: 面板数据设定（不强制执行 xtset，但推荐设定一次）
xtset id time_step_hour

* 步骤 6: 执行面板回归 + 双重固定效应（id + time_step_hour）
reghdfe attitude hungry tired safe social sadness joy fear disgust anger surprise, absorb(id time_step_hour) vce(cluster id)

* 使用outreg2输出结果到Word文档
outreg2 est1 using  "C:\\Users\\lenovo\\Desktop\\agentsociety\\回归分析\\table2.doc",append  bdec(3) se sdec(3)  ctitle(atti_student_ws) addtext(Agentid FE, Yes , time FE, Yes) 



****extension ba****
* 步骤 1: 导入 CSV 文件（含变量名）
import delimited "C:\Users\lenovo\Desktop\two way fixed effects\extension_ba.csv", clear

* 步骤 3: 检查数据类型（尤其是 id 和 time_step_hour 是否为数值）
destring id time_step_hour, replace force

* 步骤 5: 面板数据设定（不强制执行 xtset，但推荐设定一次）
xtset id time_step_hour

* 步骤 6: 执行面板回归 + 双重固定效应（id + time_step_hour）
reghdfe attitude hungry tired safe social sadness joy fear disgust anger surprise, absorb(id time_step_hour) vce(cluster id)

* 使用outreg2输出结果到Word文档
outreg2 est1 using  "C:\\Users\\lenovo\\Desktop\\agentsociety\\回归分析\\table2.doc",append  bdec(3) se sdec(3)  ctitle(atti_extension_ba) addtext(Agentid FE, Yes , time FE, Yes) 



****extension ws****
* 步骤 1: 导入 CSV 文件（含变量名）
import delimited "C:\Users\lenovo\Desktop\two way fixed effects\extension_ws.csv", clear

* 步骤 3: 检查数据类型（尤其是 id 和 time_step_hour 是否为数值）
destring id time_step_hour, replace force

* 步骤 5: 面板数据设定（不强制执行 xtset，但推荐设定一次）
xtset id time_step_hour

* 步骤 6: 执行面板回归 + 双重固定效应（id + time_step_hour）
reghdfe attitude hungry tired safe social sadness joy fear disgust anger surprise, absorb(id time_step_hour) vce(cluster id)

* 使用outreg2输出结果到Word文档
outreg2 est1 using  "C:\\Users\\lenovo\\Desktop\\agentsociety\\回归分析\\table2.doc",append  bdec(3) se sdec(3)  ctitle(atti_extension_ws) addtext(Agentid FE, Yes , time FE, Yes) 



****exercise ba****
* 步骤 1: 导入 CSV 文件（含变量名）
import delimited "C:\Users\lenovo\Desktop\two way fixed effects\exercise_ba.csv", clear

* 步骤 3: 检查数据类型（尤其是 id 和 time_step_hour 是否为数值）
destring id time_step_hour, replace force

* 步骤 5: 面板数据设定（不强制执行 xtset，但推荐设定一次）
xtset id time_step_hour

* 步骤 6: 执行面板回归 + 双重固定效应（id + time_step_hour）
reghdfe attitude hungry tired safe social sadness joy fear disgust anger surprise, absorb(id time_step_hour) vce(cluster id)

* 使用outreg2输出结果到Word文档
outreg2 est1 using  "C:\\Users\\lenovo\\Desktop\\agentsociety\\回归分析\\table2.doc",append  bdec(3) se sdec(3)  ctitle(atti_exercise_ba) addtext(Agentid FE, Yes , time FE, Yes) 


****exercise ws****
* 步骤 1: 导入 CSV 文件（含变量名）
import delimited "C:\Users\lenovo\Desktop\two way fixed effects\exercise_ws.csv", clear

* 步骤 3: 检查数据类型（尤其是 id 和 time_step_hour 是否为数值）
destring id time_step_hour, replace force

* 步骤 5: 面板数据设定（不强制执行 xtset，但推荐设定一次）
xtset id time_step_hour

* 步骤 6: 执行面板回归 + 双重固定效应（id + time_step_hour）
reghdfe attitude hungry tired safe social sadness joy fear disgust anger surprise, absorb(id time_step_hour) vce(cluster id)

* 使用outreg2输出结果到Word文档
outreg2 est1 using  "C:\\Users\\lenovo\\Desktop\\agentsociety\\回归分析\\table2.doc",append  bdec(3) se sdec(3)  ctitle(atti_exercise_ws) addtext(Agentid FE, Yes , time FE, Yes) 







