# Hướng dẫn Debug Upload Ảnh

## Vấn đề đã sửa

✅ **Đã thêm package `http_parser`** vào `pubspec.yaml` - đây là nguyên nhân chính gây lỗi upload ảnh.

## Các bước kiểm tra

### 1. Kiểm tra Backend đang chạy

```bash
cd D:\App_Chat_API\backend
npm run dev
```

Backend phải chạy ở địa chỉ: `http://192.168.2.4:3000`

### 2. Kiểm tra Firebase Storage Rules

Vào Firebase Console → Storage → Rules và đảm bảo rules cho phép upload:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /chat-images/{roomId}/{imageId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 3. Kiểm tra Log khi upload

Khi bạn upload ảnh, hãy xem log trong:

**Flutter App (Debug Console):**

- `🔍 [UPLOAD] Starting upload` - Bắt đầu upload
- `✓ [UPLOAD] User: email` - User đã đăng nhập
- `✓ [UPLOAD] Token obtained` - Đã lấy được token
- `✓ [UPLOAD] Adding image` - Đang thêm ảnh
- `📤 [UPLOAD] Sending to` - Đang gửi request
- `✅ [UPLOAD] Success!` - Upload thành công

**Backend (Terminal):**

- `📥 [UPLOAD CONTROLLER] Request received` - Nhận request
- `📁 [MULTER] File filter` - Kiểm tra file
- `✓ [MULTER] File accepted` - File hợp lệ
- `📤 [UPLOAD SERVICE] Starting upload` - Bắt đầu upload lên Firebase
- `✅ [UPLOAD SERVICE] Upload successful!` - Upload thành công

### 4. Các lỗi thường gặp và cách sửa

#### Lỗi: "No images provided"

- **Nguyên nhân:** Không có file được gửi lên
- **Giải pháp:** Kiểm tra xem `ImagePicker` có chọn được ảnh không

#### Lỗi: "Room ID is required"

- **Nguyên nhân:** Thiếu roomId trong request
- **Giải pháp:** Đảm bảo `chatId` được truyền vào hàm `uploadImages()`

#### Lỗi: "User not logged in"

- **Nguyên nhân:** Chưa đăng nhập Firebase
- **Giải pháp:** Đăng nhập lại vào app

#### Lỗi: "Only image files are allowed"

- **Nguyên nhân:** File không phải là ảnh (jpeg, png, gif, webp)
- **Giải pháp:** Chỉ chọn file ảnh hợp lệ

#### Lỗi: "File too large"

- **Nguyên nhân:** File lớn hơn 5MB
- **Giải pháp:** Giảm kích thước ảnh hoặc tăng `MAX_FILE_SIZE` trong backend

#### Lỗi: "Upload failed" (Firebase)

- **Nguyên nhân:** Không có quyền upload lên Firebase Storage
- **Giải pháp:**
  1. Kiểm tra Firebase Storage Rules
  2. Kiểm tra service account có quyền Storage Admin
  3. Kiểm tra `FIREBASE_STORAGE_BUCKET` trong `.env`

### 5. Test Upload thủ công

Chạy script test trong backend:

```bash
cd D:\App_Chat_API\backend
node tests/test-upload.js
```

Script này sẽ test upload ảnh trực tiếp lên API.

### 6. Kiểm tra Network

Nếu app không kết nối được backend:

1. Kiểm tra IP trong `.env` có đúng không:

   ```bash
   ipconfig
   ```

   Tìm IPv4 Address của WiFi/Ethernet

2. Kiểm tra firewall có chặn port 3000 không

3. Đảm bảo điện thoại và máy tính cùng mạng WiFi

## Code đã sửa

### pubspec.yaml

```yaml
dependencies:
  # ... các dependencies khác
  http_parser: ^4.0.2 # ← ĐÃ THÊM
```

Sau khi thêm, chạy:

```bash
flutter pub get
```

## Kết luận

Lỗi chính là thiếu package `http_parser` trong `pubspec.yaml`. Package này cần thiết để parse MIME type khi upload file với Dio.

Sau khi chạy `flutter pub get`, bạn có thể thử upload ảnh lại. Nếu vẫn còn lỗi, hãy kiểm tra log theo hướng dẫn ở trên để xác định nguyên nhân cụ thể.
