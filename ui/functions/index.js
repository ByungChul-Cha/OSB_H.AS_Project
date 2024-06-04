const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { Storage } = require("@google-cloud/storage");
const path = require("path");
const os = require("os");
const fs = require("fs");

admin.initializeApp();
const storage = new Storage();

exports.splitAndOrganizeJsonFile = functions.storage
  .object()
  .onFinalize(async (object) => {
    const bucket = storage.bucket(object.bucket);
    const filePath = object.name;
    const fileName = path.basename(filePath);
    const tempFilePath = path.join(os.tmpdir(), fileName);

    // 'data.json' 파일이 업로드되었을 때만 실행
    if (fileName !== "data.json") {
      return null;
    }

    // 파일 다운로드
    await bucket.file(filePath).download({ destination: tempFilePath });
    const data = fs.readFileSync(tempFilePath, "utf8");
    const jsonData = JSON.parse(data);
    const rowDataList = jsonData["row_data_list"];

    // 각 항목을 ITEM_SEQ 폴더에 저장
    for (const rowData of rowDataList) {
      const itemSeq = rowData["ITEM_SEQ"]; // ITEM_SEQ 변수값 추출
      const folderName = `split_pilldata/${itemSeq}`; // 폴더명 설정
      const exists = await bucket.getFiles({ prefix: folderName });

      // 해당 폴더(ITEM_SEQ)가 존재하지 않을 때만 파일 생성 및 업로드
      if (!exists[0].length) {
        const newFileName = `${folderName}/data.json`;
        const newFilePath = path.join(os.tmpdir(), `data_${itemSeq}.json`);
        fs.writeFileSync(newFilePath, JSON.stringify(rowData, null, 2), "utf8");
        await bucket.upload(newFilePath, {
          destination: newFileName,
        });
        console.log(`Uploaded data to ${newFileName}`);
        fs.unlinkSync(newFilePath); // 임시 파일 삭제
      } else {
        console.log(`${folderName} already exists. Skipping.`);
      }
    }

    // 원본 임시 파일 삭제
    fs.unlinkSync(tempFilePath);
    return null;
  });
