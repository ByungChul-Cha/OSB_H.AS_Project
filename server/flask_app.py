from flask import Flask, jsonify, render_template, request
import sqlite3
import threading

app = Flask(__name__)

# 스레드 로컬 변수로 데이터베이스 연결 관리
_local = threading.local()
DATABASE_PATH = 'D://Database/Pill/pillList.sqlite'

def get_db_connection():
    if not hasattr(_local, 'conn'):
        _local.conn = sqlite3.connect(DATABASE_PATH)
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

@app.route('/get_item_name', methods=['Get'])
def get_item_name():
    item_seq = request.args.get('itemSeq')
    
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        cursor = conn.cursor()
        cursor.execute("SELECT ITEM_NAME FROM pill_kr WHERE ITEM_SEQ = ?", (item_seq,))
        result = cursor.fetchone()
        
        if result:
            return result[0]  # ITEM_NAME 값 반환
        else:
            return 'Item not found', 404
    
    except sqlite3.Error as e:
        return f'Database error: {e}', 500
    
    finally:
        if conn:
            conn.close()

@app.route('/name_search', methods=['POST'])
def name_search():
    # 클라이언트에서 전달된 데이터 받기
    data = request.get_json()
    inputText = data.get('inputText')
    selectedShape = data.get('selectedShape')
    selectedColor = data.get('selectedColor')

    # 클라이언트에서 전송된 데이터 확인
    print(f"inputText: {inputText}")
    print(f"selectedShape: {selectedShape}")
    print(f"selectedColor: {selectedColor}")

    # SQLite 데이터베이스 쿼리 실행
    with sqlite3.connect(DATABASE_PATH) as conn:
        cursor = conn.cursor()
        sql = """
            SELECT ITEM_SEQ
            FROM pill_kr
            WHERE PRINT_BACK = ? OR PRINT_FRONT = ?
              AND DRUG_SHAPE = ?
              AND (COLOR_CLASS1 = ? OR COLOR_CLASS2 = ?)
        """
        cursor.execute(sql, (inputText, inputText, selectedShape, selectedColor, selectedColor))
        result = cursor.fetchone()

    # 결과 반환
    if result:
        return jsonify({'item_seq': result[0]})
    else:
        return jsonify({'item_seq': None})


if __name__ == '__main__':
   app.run(host='0.0.0.0', port=5000, debug=True)
