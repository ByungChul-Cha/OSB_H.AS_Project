import os
import firebase_admin
from firebase_admin import credentials, storage


# Firebase Admin SDK 초기화
cred = credentials.Certificate('osb-project-9307e-firebase-adminsdk-b5a5c-ff43e26e39.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'osb-project-9307e.appspot.com'
})

# 업로드할 이미지 파일 경로
folder_path = '../Imagedata/Src/Raw'

# Firebase Storage 버킷 설정
bucket = storage.bucket()

# Firebase Storage 내에 저장할 기본 경로 설정
firebase_base_path = 'Image/Src/Raw'

# 폴더 내 모든 파일 순회
for root, dirs, files in os.walk(folder_path):
    for file in files:
        file_path = os.path.join(root, file)
        
        # Firebase Storage에 저장될 파일 이름 설정 (파일 이름 그대로 사용)
        relative_path = os.path.relpath(file_path, folder_path)
        destination_blob_name = os.path.join(firebase_base_path, relative_path).replace("\\", "/")  # 경로 구분자 변경 (Windows 지원)

        # 이미지 파일 업로드
        blob = bucket.blob(destination_blob_name)
        blob.upload_from_filename(file_path)
        
        print(f'File {file_path} uploaded to {destination_blob_name}.')