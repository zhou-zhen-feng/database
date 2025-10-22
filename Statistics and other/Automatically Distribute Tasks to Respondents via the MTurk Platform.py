#!/usr/bin/env python
# coding: utf-8

# In[2]:


# 检查是否下载boto3成功
import boto3
print("boto3 version:", boto3.__version__)


# In[ ]:


############ First ###############


# In[ ]:


import boto3
from botocore.exceptions import ClientError

# 初始化 MTurk 客户端（生产环境，默认 endpoint）
client = boto3.client(
    'mturk',
    region_name='us-east-1',
    aws_access_key_id='你的AWS_ACCESS_KEY',
    aws_secret_access_key='你的AWS_SECRET_KEY'
)

# 你的 Worker ID 列表
workers = [ "A14W0AXTJ3R19V","A5V3ZMQI0PU3F"]

subject = 'Racist Language Annotation Task in US Historical Newspapers'
message = """Hello, we are continuing data collection and invite you to participate. 
Each approved submission pays $2! High-quality work will lead to more invitations, and completing 3 or more tasks earns an extra $5 bonus! 
Please click this link to complete the survey: https://utexas.qualtrics.com/jfe/form/SV_0eSacvMEwJ6UOQC"""

# 每次最多 100 个 Worker
batch_size = 100
for i in range(0, len(workers), batch_size):
    batch = workers[i:i+batch_size]
    try:
        response = client.notify_workers(
            Subject=subject,
            MessageText=message,
            WorkerIds=batch
        )
        print(f"发送成功，批次 {i//batch_size + 1}: {batch}")
    except ClientError as e:
        print(f"发送失败，批次 {i//batch_size + 1}: {e.response['Error']['Message']}")


# In[ ]:


########## Second ##########


# In[ ]:


import boto3
from botocore.exceptions import ClientError

# 初始化 MTurk 客户端（生产环境，默认 endpoint）
client = boto3.client(
    'mturk',
    region_name='us-east-1',
    aws_access_key_id='你的AWS_ACCESS_KEY',
    aws_secret_access_key='你的AWS_SECRET_KEY'
)

# 你的 Worker ID 列表
workers = ["A14W0AXTJ3R19V","AJP3A4R5044QG"]

subject = 'Racist Language Annotation Task in US Historical Newspapers'
message = """Hello, we are continuing data collection and invite you to participate. 
Each approved submission pays $2! High-quality work will lead to more invitations, and completing 3 or more tasks earns an extra $5 bonus! 
Please click this link to complete the survey: https://utexas.qualtrics.com/jfe/form/SV_e4IUEdSv9zblo34"""

# 每次最多 100 个 Worker
batch_size = 100
for i in range(0, len(workers), batch_size):
    batch = workers[i:i+batch_size]
    try:
        response = client.notify_workers(
            Subject=subject,
            MessageText=message,
            WorkerIds=batch
        )
        print(f"发送成功，批次 {i//batch_size + 1}: {batch}")
    except ClientError as e:
        print(f"发送失败，批次 {i//batch_size + 1}: {e.response['Error']['Message']}")


# In[ ]:


####### Third #########


# In[ ]:


import boto3
from botocore.exceptions import ClientError

# 初始化 MTurk 客户端（生产环境，默认 endpoint）
client = boto3.client(
    'mturk',
    region_name='us-east-1',
    aws_access_key_id='你的AWS_ACCESS_KEY',
    aws_secret_access_key='你的AWS_SECRET_KEY'
)

# 你的 Worker ID 列表
workers = ["AE861G0AY5RGT","AJP3A4R5044QG","A5V3ZMQI0PU3F"]

subject = 'Racist Language Annotation Task in US Historical Newspapers'
message = """Hello, we are continuing data collection and invite you to participate. 
Each approved submission pays $2! High-quality work will lead to more invitations, and completing 3 or more tasks earns an extra $5 bonus! 
Please click this link to complete the survey: https://utexas.qualtrics.com/jfe/form/SV_eXyn83BQikMCEJM"""

# 每次最多 100 个 Worker
batch_size = 100
for i in range(0, len(workers), batch_size):
    batch = workers[i:i+batch_size]
    try:
        response = client.notify_workers(
            Subject=subject,
            MessageText=message,
            WorkerIds=batch
        )
        print(f"发送成功，批次 {i//batch_size + 1}: {batch}")
    except ClientError as e:
        print(f"发送失败，批次 {i//batch_size + 1}: {e.response['Error']['Message']}")


# In[ ]:


##### Fourth ######


# In[ ]:


import boto3
from botocore.exceptions import ClientError

# 初始化 MTurk 客户端（生产环境，默认 endpoint）
client = boto3.client(
    'mturk',
    region_name='us-east-1',
    aws_access_key_id='你的AWS_ACCESS_KEY',
    aws_secret_access_key='你的AWS_SECRET_KEY'
)

# 你的 Worker ID 列表
workers = ["AJP3A4R5044QG","AB66CTVQ90RCV"]

subject = 'Racist Language Annotation Task in US Historical Newspapers'
message = """Hello, we are continuing data collection and invite you to participate. 
Each approved submission pays $2! High-quality work will lead to more invitations, and completing 3 or more tasks earns an extra $5 bonus! 
Please click this link to complete the survey: https://utexas.qualtrics.com/jfe/form/SV_02N1z6eUnTd2NcW"""

# 每次最多 100 个 Worker
batch_size = 100
for i in range(0, len(workers), batch_size):
    batch = workers[i:i+batch_size]
    try:
        response = client.notify_workers(
            Subject=subject,
            MessageText=message,
            WorkerIds=batch
        )
        print(f"发送成功，批次 {i//batch_size + 1}: {batch}")
    except ClientError as e:
        print(f"发送失败，批次 {i//batch_size + 1}: {e.response['Error']['Message']}")

