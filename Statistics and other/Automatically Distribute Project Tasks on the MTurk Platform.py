#!/usr/bin/env python
# coding: utf-8

# In[1]:


import boto3
import uuid

# ===== 配置区 需要改的如下=====
AWS_ACCESS_KEY = 'YOUR_AWS_ACCESS_KEY'             # AWS访问密钥ID
AWS_SECRET_KEY = 'YOUR_AWS_SECRET_KEY'             # AWS访问密钥
Task_number = "Task8"                              # 每次都需要改
HIT_TITLE = "Historical Racial Language Annotation Survey Task8"             # 任务标题,每次改一下
SURVEY_URL_BASE = "https://utexas.qualtrics.com/jfe/form/SV_0d1ntYmad3DFRb0"  # 问卷链接，每次都需要改
HIT_MAX_ASSIGNMENTS = 3                            # 任务数，每次都需要改
# 已存在的黑名单 QualificationTypeId（用于屏蔽已做过问卷的worker, 第7个qualification），每次需要更改
BLACKLIST_QUALIFICATION_ID = '3WOL3YSRDZIOM06T4IOI97VNNEUZ5A'



####### 以下不需要改 ########
REGION = 'us-east-1'                               # AWS区域，MTurk目前只支持 us-east-1
ENDPOINT = 'https://mturk-requester.us-east-1.amazonaws.com'  # MTurk正式环境端点

# 任务列表页和详情页标题下的简短介绍（显示给worker的简洁介绍）
HIT_DESCRIPTION = (
    "In this task, you will simply classify the category of each word and assess its intensity. "
    "These words are drawn from historical U.S. newspapers published between 1800 and 1910."
)

# 问卷页面顶部的详细说明文本（填写completion code前的说明）
QUESTION_OVERVIEW_TEXT = """
We are conducting an academic survey on historical racial language annotation.
In this task, you will simply classify the category of each word and assess its intensity.
These words are drawn from historical U.S. newspapers published between 1800 and 1910.
Click the link below to complete the survey. At the end of the survey,
you will receive a code to receive credit for participating in our survey.
Welcome to continue searching for and participating in other surveys in this series!

Make sure to leave this window open while you complete the survey.
When you are finished, return to this page and paste the code into the box.
"""

HIT_REWARD = '2.00'                                # 单个任务的奖励金额（美元，字符串）
HIT_ASSIGNMENT_DURATION = 7200                     # 任务完成时长，单位秒（这里2小时）
HIT_LIFETIME = 604800                              # 任务存活时长，单位秒（这里7天）
KEYWORDS = "word classification, intensity rating, racism, historical words"  # 关键词
AUTO_APPROVAL_DELAY_SECONDS = 604800               # 自动批准时间，单位秒（这里7天）


# 连接MTurk客户端，准备调用API
mturk = boto3.client(
    'mturk',
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY,
    region_name=REGION,
    endpoint_url=ENDPOINT
)

def publish_hit(blacklist_qualification_id, task_number):
    """
    发布HIT任务函数，自动添加地区、Master资格、通过率、黑名单资格限制。
    参数:
        blacklist_qid (str): 用于屏蔽已完成者的Qualification Type ID
    返回:
        HIT ID字符串，如果发布失败返回None
    """
    # 构造带workerId参数的问卷链接，方便后续在外部问卷中记录workerId
    survey_url = SURVEY_URL_BASE
    print(f"正在发布新的问卷链接{task_number}: {survey_url}")  

    # 任务问题的XML格式：顶部说明 + completion code 输入框（纯文本版本，100% 兼容 MTurk XSD）
    question_xml = f"""
    <QuestionForm xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/QuestionForm.xsd">
      <Overview>
        <Title>{HIT_TITLE}</Title>
        <Text>{QUESTION_OVERVIEW_TEXT.strip()}
        
    Please open this link in a browser tab and complete the survey:
    {SURVEY_URL_BASE}

    After completing the survey, copy the completion code and paste it below.</Text>
          </Overview>
          <Question>
            <QuestionIdentifier>code</QuestionIdentifier>
            <DisplayName>Provide the completion code here</DisplayName>
            <IsRequired>true</IsRequired>
            <FreeTextAnswer/>
          </Question>
        </QuestionForm>
        """

    # 资格要求：限制美国地区、通过率95%以上、Masters资格，及黑名单过滤
    qualification_requirements = [
        {
            'QualificationTypeId': '00000000000000000071',  # 地区：美国
            'Comparator': 'In',
            'LocaleValues': [{'Country': 'US'}],
            'ActionsGuarded': 'DiscoverPreviewAndAccept'
        },
        {
            'QualificationTypeId': '000000000000000000L0',  # 通过率≥95%
            'Comparator': 'GreaterThanOrEqualTo',
            'IntegerValues': [95],
            'ActionsGuarded': 'DiscoverPreviewAndAccept'
        },
        {
            'QualificationTypeId': "2F1QJWKUDD8XADTFD2Q0G6UTO95ALH",  # Masters（正式环境）
            'Comparator': 'Exists',
            'ActionsGuarded': 'DiscoverPreviewAndAccept'
        },
        {
            'QualificationTypeId': blacklist_qualification_id,             # 黑名单：必须“没有”该资格
            'Comparator': 'DoesNotExist',
            'ActionsGuarded': 'DiscoverPreviewAndAccept'
        }
    ]

    # 幂等token，避免脚本重复运行导致发布多个一模一样的HIT
    unique_token = f"{task_number}-" + str(uuid.uuid4())

    try:
        response = mturk.create_hit(
            Title=HIT_TITLE,
            Description=HIT_DESCRIPTION,
            Reward=HIT_REWARD,
            AssignmentDurationInSeconds=HIT_ASSIGNMENT_DURATION,
            LifetimeInSeconds=HIT_LIFETIME,
            MaxAssignments=HIT_MAX_ASSIGNMENTS,
            Question=question_xml,
            QualificationRequirements=qualification_requirements,
            Keywords=KEYWORDS,
            AutoApprovalDelayInSeconds=AUTO_APPROVAL_DELAY_SECONDS,
            RequesterAnnotation=f"{task_number}",              # 便于后台筛选定位
            UniqueRequestToken=unique_token           # 幂等：相同token不会重复创建
        )
    except Exception as e:
        print(f"HIT 发布失败，错误信息: {e}")
        return None

    hit = response['HIT']
    hit_id = hit['HITId']
    hit_type_id = hit.get('HITTypeId', '')
    print(f"HIT 发布成功，HIT ID: {hit_id}")
    if hit_type_id:
        print(f"HIT Type ID: {hit_type_id}")
    return hit_id


if __name__ == '__main__':
    # 执行发布，传入黑名单资格ID (qualification)
    publish_hit(BLACKLIST_QUALIFICATION_ID,Task_number)


# In[ ]:




