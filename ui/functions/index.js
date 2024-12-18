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

    // 각 항목을 ITEM_SEQ 폴더에 저장
    for (const rowData of jsonData) {
      const itemSeq = rowData["ITEM_SEQ"]; // ITEM_SEQ 변수값 추출
      const folderName = `split_pilldata/${itemSeq}`; // 폴더명 설정

      // 폴더가 이미 존재하는지 확인
      const [files] = await bucket.getFiles({ prefix: folderName });

      // 폴더가 존재하면 폴더 내 모든 파일 삭제
      if (files.length > 0) {
        for (const file of files) {
          await file.delete();
        }
        console.log(`Deleted all files in ${folderName}`);
      }

      // 해당 폴더(ITEM_SEQ)가 존재하지 않을 때만 파일 생성 및 업로드
      const newFileName = `${folderName}/data.json`;
      const newFilePath = path.join(os.tmpdir(), `data_${itemSeq}.json`);
      fs.writeFileSync(newFilePath, JSON.stringify(rowData, null, 2), "utf8");
      await bucket.upload(newFilePath, {
        destination: newFileName,
      });
      console.log(`Uploaded data to ${newFileName}`);
      fs.unlinkSync(newFilePath); // 임시 파일 삭제
    }

    // 원본 임시 파일 삭제
    fs.unlinkSync(tempFilePath);

    // Firebase Storage에서 original_pilldata/data.json 파일 삭제
    await bucket.file(filePath).delete();
    console.log(`Deleted original file: ${filePath}`);
    return null;
  });

// Firebase Storage의 split_pilldata 폴더 삭제
exports.deleteSplitPillDataFolder = functions.https.onCall(async () => {
  try {
    const bucket = admin.storage().bucket();
    const [splitPillDataFiles] = await bucket.getFiles({
      prefix: "split_pilldata/",
    });
    for (const file of splitPillDataFiles) {
      await file.delete();
    }
    console.log("Deleted all files in split_pilldata folder");

    await bucket.deleteFiles({ prefix: "split_pilldata/" });
    console.log("Deleted split_pilldata folder");
  } catch (error) {
    console.error("Error deleting split_pilldata folder:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Failed to delete split_pilldata folder",
    );
  }
});
