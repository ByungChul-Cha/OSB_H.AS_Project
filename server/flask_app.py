from flask import Flask, jsonify, render_template, request
import sqlite3
import threading

app = Flask(__name__)

# 스레드 로컬 변수로 데이터베이스 연결 관리
_local = threading.local()

def get_db_connection():
    if not hasattr(_local, 'conn'):
        _local.conn = sqlite3.connect('D://Database/Pill/pillList.sqlite')
        _local.c = _local.conn.cursor()
    return _local.c

@app.route("/")
def index():
    return render_template('index.html')

@app.route("/search", methods=['POST'])
def search():
    data = request.get_json()
    search_terms = data.get('terms', [])

    row_data_list = []

    # SQLite 데이터베이스에서 검색
    c = get_db_connection()
    for term in search_terms:
        if term is not None:
         c.execute("SELECT * FROM pill_kr WHERE PRINT_FRONT = ? OR PRINT_BACK = ?", (term, term))
         for row in c.fetchall():
               row_data = {
                   "ITEM_SEQ" : row[1]
              }
               row_data_list.append(row_data)

    return jsonify(row_data_list)


   #with open(file_path, 'r', encoding='utf-8') as file:
   #   csv_reader = csv.DictReader(file)
   #   for row in csv_reader:
   #         for term in search_terms:
   #            if term in row['PRINT_FRONT']:
   #               print_front_list.append(row['PRINT_FRONT'])
   #               row_data_list.append(row)
   #            if term in row['PRINT_BACK']:
   #              print_back_list.append(row['PRINT_BACK'])
   #               row_data_list.append(row)
   #return jsonify({
   #   'print_front_list': print_front_list,
   #   'print_back_list': print_back_list,
   #   'row_data_list': row_data_list
   #}) 
if __name__ == '__main__':
   app.run(host='0.0.0.0', port=5000, debug=True)
