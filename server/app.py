from flask import Flask, jsonify, render_template, request
import csv

app = Flask(__name__)

# CSV 파일 경로
file_path = 'data/pill_kr.csv'

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/search', methods=['POST'])
def search():
   data = request.get_json()
   search_terms = data.get('terms', [])

   print_front_list = []
   print_back_list = []
   row_data_list = []
   with open(file_path, 'r', encoding='utf-8') as file:
      csv_reader = csv.DictReader(file)
      for row in csv_reader:
            for term in search_terms:
               if term in row['PRINT_FRONT']:
                  print_front_list.append(row['PRINT_FRONT'])
                  row_data_list.append(row)
               if term in row['PRINT_BACK']:
                  print_back_list.append(row['PRINT_BACK'])
                  row_data_list.append(row)
   return jsonify({
      'print_front_list': print_front_list,
      'print_back_list': print_back_list,
      'row_data_list': row_data_list
   })
if __name__ == '__main__':
   app.run(host='0.0.0.0', port=5000, debug=True)
