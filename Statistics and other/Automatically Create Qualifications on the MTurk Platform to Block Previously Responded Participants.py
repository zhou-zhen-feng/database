#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import boto3
import pandas as pd
from tqdm import tqdm

# ===== 配置区 =====
AWS_ACCESS_KEY = 'YOUR_AWS_ACCESS_KEY'
AWS_SECRET_KEY = 'YOUR_AWS_SECRET_KEY'
REGION = 'us-east-1'
ENDPOINT = 'https://mturk-requester.us-east-1.amazonaws.com'  # 正式环境

EXCEL_PATH = r'workerid_lists.xlsx'  # 你的Excel文件路径
qual_id_list = []

# ===== 连接MTurk =====
mturk = boto3.client(
    'mturk',
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY,
    region_name=REGION,
    endpoint_url=ENDPOINT
)

# ===== 读取Excel =====
# Excel必须格式：
# 第一列: QualificationName
# 后面列: WorkerId1, WorkerId2, WorkerId3, ...
df = pd.read_excel(EXCEL_PATH, engine='openpyxl')

# 按行遍历，每行代表一个问卷的屏蔽名单
for idx, row in tqdm(df.iterrows(), total=len(df), desc="Processing surveys"):
    qual_name = str(row[0]).strip()
    worker_ids = [str(w).strip() for w in row[1:] if pd.notna(w)]

    print(f"\n📌 正在处理问卷 '{qual_name}'，共{len(worker_ids)}个Worker...")

    # 查找是否已存在该Qualification
    existing_quals = mturk.list_qualification_types(Query=qual_name, MustBeRequestable=True)['QualificationTypes']
    if existing_quals:
        qual_id = existing_quals[0]['QualificationTypeId']
        print(f"  - Qualification 已存在，ID: {qual_id}")
    else:
        # 创建Qualification
        response = mturk.create_qualification_type(
            Name=qual_name,
            Keywords='blacklist, block, prevent duplicate',
            Description=f'Workers who completed survey: {qual_name}',
            QualificationTypeStatus='Active'
        )
        qual_id = response['QualificationType']['QualificationTypeId']
        print(f"  - 新建 Qualification，ID: {qual_id}")
        
    qual_id_list.append(qual_id)

    # 批量授予资格
    for worker_id in worker_ids:
        try:
            mturk.associate_qualification_with_worker(
                QualificationTypeId=qual_id,
                WorkerId=worker_id,
                IntegerValue=1,
                SendNotification=False
            )
            print(f"    → 已屏蔽 Worker: {worker_id}")
        except Exception as e:
            print(f"    ⚠️ 屏蔽失败 Worker: {worker_id}，错误: {e}")

print("\n🎯 所有问卷资格创建和屏蔽完成！")


print(qual_id_list)

