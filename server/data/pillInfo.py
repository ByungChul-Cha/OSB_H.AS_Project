import requests
import pprint
import privateKey
import pandas as pd
import bs4

# 인증키 입력
encoding = privateKey.encoding
decoding = privateKey.decoding


# final page number = 2474
pill_list = []
name_list = []

for pageNo in range(1, 474):
    print(pageNo)
    # url 입력
    url = 'http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList'
    params = {'serviceKey': decoding,
              'pageNo': pageNo,
              'numOfRows': 10,
              }

    response = requests.get(url, params=params)

    # xml 내용
    content = response.text

    # 출력
    pp = pprint.PrettyPrinter(indent=4)
    # print(pp.pprint(content))


    # xml을 dataFrame으로 변환
    xml_obj = bs4.BeautifulSoup(content, 'lxml-xml')
    rows = xml_obj.findAll('item')
    # print(rows)

    # 각 행의 컬럼, 이름, 값을 가지는 리스트 만들기
    value_list = []  # 데이터값

    # xml 안의 데이터 수집
    for i in range(0, len(rows)):
        columns = rows[i].find_all()
        # 첫째 행 데이터 수집
        for j in range(0, len(columns)):
            if i == 0 and pageNo == 1:
                # 컬럼 이름 값 저장
                name_list.append(columns[j].name)
            # 컬럼의 각 데이터 값 저장
            value_list.append(columns[j].text)
        # 각 행의 value값 전체 저장
        pill_list.append(value_list)
        # 데이터 리스트 값 초기화
        value_list = []

print(name_list)
print(pill_list)

# xml값 DataFrame으로 만들기
pill_df = pd.DataFrame(pill_list, columns=name_list)

pill_df.to_csv('pill_Info.csv', encoding='utf-8-sig')
