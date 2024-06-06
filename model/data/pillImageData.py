import urllib

import pandas as pd
from urllib import request

from __init__ import LocalPathPC


SavePath = LocalPathPC + "/Imagedata/Src/Raw/"
startNum = 0
# 0 ~  24729 완료

def GetPillImage():
    pill_data = pd.read_csv(LocalPathPC + "/data/pill_kr.csv", delimiter=',', low_memory=False)
    print("======START GET PILL IMAGE======")

    FilePathList = pill_data["ITEM_IMAGE"]

    for i, each in enumerate(FilePathList):
        idx = i + startNum
        # 다운 받을 알약 이미지 url
        print("=== Download " + str(idx) + ": " + each)
        pillItemSEQ = str(pill_data.loc[idx, "ITEM_SEQ"])
        desFilePath = SavePath + pillItemSEQ + ".jpg"

        # 파일 다운로드
        urllib.request.urlretrieve(each, desFilePath)

        print("==== Item name: " + pillItemSEQ)
        print("==== Save path: " + desFilePath)

    return pill_data["ITEM_SEQ"]


GetPillImage()
