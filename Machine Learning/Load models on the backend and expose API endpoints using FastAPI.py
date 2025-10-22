#!/usr/bin/env python
# coding: utf-8

import os
import re
import io
import string
import time
import numpy as np
import pandas as pd
import torch
from torch import nn
from transformers import RobertaModel, AutoTokenizer
from fastapi import FastAPI, UploadFile, File, Query
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware

# ======================
# 路径配置
# ======================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BERT_PATH = os.path.join(BASE_DIR, "bertweet-base")
CATEGORY_CKPT = os.path.join(BASE_DIR, "category.pt")
EMOTION_CKPT = os.path.join(BASE_DIR, "emotion.pt")
RESULT_DIR = os.path.join(BASE_DIR, "results")
os.makedirs(RESULT_DIR, exist_ok=True)

# ======================
# 模型定义
# ======================
class BertClassifier(nn.Module):
    def __init__(self, pretrained_path, num_classes, dropout_prob=0.5):
        super().__init__()
        self.roberta = RobertaModel.from_pretrained(pretrained_path)
        self.dropout = nn.Dropout(dropout_prob)
        self.classifier = nn.Linear(self.roberta.config.hidden_size, num_classes)

    def forward(self, input_ids, attention_mask):
        outputs = self.roberta(input_ids=input_ids, attention_mask=attention_mask)
        pooled_output = outputs.last_hidden_state[:, 0, :]
        pooled_output = self.dropout(pooled_output)
        return self.classifier(pooled_output)

# ======================
# 设备
# ======================
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# ======================
# 载入模型
# ======================
category_model = BertClassifier(pretrained_path=BERT_PATH, num_classes=7)
category_model.load_state_dict(torch.load(CATEGORY_CKPT, map_location=device))
category_model.to(device).eval()

emotion_model = BertClassifier(pretrained_path=BERT_PATH, num_classes=3)
emotion_model.load_state_dict(torch.load(EMOTION_CKPT, map_location=device))
emotion_model.to(device).eval()

tokenizer = AutoTokenizer.from_pretrained(BERT_PATH, use_fast=True, local_files_only=True)

# ======================
# 类别映射
# ======================
category_id2label = {
    0: "经济",
    1: "社会",
    2: "科技",
    3: "政治",
    4: "体育",
    5: "文化",
    6: "军事"
}

emotion_id2label = {
    2: "消极",
    0: "中性",
    1: "积极"
}

# ======================
# 文本预处理函数
# ======================
def clean_text(text):
    text = str(text)
    text = re.sub(r"http\S+|www\.\S+", "", text)
    text = text.translate(str.maketrans("", "", string.punctuation))
    text = "".join(c for c in text if c.isprintable())
    return " ".join(text.split())

# ======================
# 预测函数
# ======================
def predict_category(texts):
    results = []
    for text in texts:
        cleaned = clean_text(text)
        inputs = tokenizer(cleaned, return_tensors="pt", truncation=True, padding=True, max_length=128)
        if "token_type_ids" in inputs:
            inputs.pop("token_type_ids")
        inputs = {k: v.to(device) for k, v in inputs.items()}

        with torch.no_grad():
            logits = category_model(**inputs)
            probs = torch.softmax(logits, dim=1).cpu().numpy()[0]
        pred_id = int(np.argmax(probs))
        pred_label = category_id2label[pred_id]

        # 概率单独展开
        prob_dict = {f"prob_{category_id2label[i]}": round(float(probs[i]), 4) for i in range(len(probs))}

        results.append({
            "text": text,
            "category_label": pred_label,
            **prob_dict
        })
    return results


def predict_emotion(texts):
    results = []
    for text in texts:
        cleaned = clean_text(text)
        inputs = tokenizer(cleaned, return_tensors="pt", truncation=True, padding=True, max_length=128)
        if "token_type_ids" in inputs:
            inputs.pop("token_type_ids")
        inputs = {k: v.to(device) for k, v in inputs.items()}

        with torch.no_grad():
            logits = emotion_model(**inputs)
            probs = torch.softmax(logits, dim=1).cpu().numpy()[0]
        pred_id = int(np.argmax(probs))
        pred_label = emotion_id2label[pred_id]

        # 概率单独展开
        prob_dict = {f"prob_{emotion_id2label[i]}": round(float(probs[i]), 4) for i in range(len(probs))}

        results.append({
            "emotion_label": pred_label,
            **prob_dict
        })
    return results

# ======================
# FastAPI 应用配置
# ======================
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ======================
# 批量上传接口
# ======================
@app.post("/api/upload")
async def upload_file(file: UploadFile = File(...)):
    try:
        # 读取文件内容
        content = await file.read()
        if file.filename.endswith(".csv"):
            df = pd.read_csv(io.BytesIO(content))
        elif file.filename.endswith(".xlsx"):
            df = pd.read_excel(io.BytesIO(content))
        elif file.filename.endswith(".txt"):
            #df = pd.read_csv(io.BytesIO(content), header=None)
            df = pd.read_csv(io.BytesIO(content), sep=None, engine="python", header=None, encoding="utf-8-sig")

        else:
            return {"code": 400, "data": {}, "message": "仅支持CSV 或 Excel 或txt文件"}

        # 检查并提取文本列
        if "text" in df.columns:
            texts = df["text"].astype(str).tolist()
        elif df.shape[1] == 1:
            # 只有一列时，自动取该列为文本列
            texts = df.iloc[:, 0].astype(str).tolist()
        else:
            return {"code": 400, "data": {}, "message": "文件中必须包含 'text' 列或仅有一列文本数据"}


        # 模型预测
        category_results = predict_category(texts)
        emotion_results = predict_emotion(texts)

        # 合并结果
        output_data = []
        for cat, emo in zip(category_results, emotion_results):
            merged = {**cat, **emo}
            output_data.append(merged)

        result_df = pd.DataFrame(output_data)

        # 保存结果文件
        timestamp = int(time.time())
        result_filename = f"batch_result_{timestamp}.csv"
        result_path = os.path.join(RESULT_DIR, result_filename)
        result_df.to_csv(result_path, index=False, encoding='utf-8')

        file_url = f"http://127.0.0.1:8000/api/download?file_name={result_filename}"

        return {
            "code": 200,
            "data": {
                "list": [
                    {
                        "fileName": result_filename,
                        "fullPath": file_url,
                        "size": os.path.getsize(result_path),
                        "createTime": int(time.time() * 1000)
                    }
                ]
            },
            "message": "下载文件生成成功"
        }

    except Exception as e:
        return {"code": 500, "data": {}, "message": f"服务器错误: {str(e)}"}

# ======================
# 文件下载接口
# ======================
@app.get("/api/download")
async def download_file(file_name: str = Query(...)):
    file_path = os.path.join(RESULT_DIR, file_name)
    if not os.path.exists(file_path):
        return {"code": 404, "data": {}, "message": "文件不存在"}
    return FileResponse(
        path=file_path,
        filename=file_name,
        media_type="text/csv; charset=utf-8")
