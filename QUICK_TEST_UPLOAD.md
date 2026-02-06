# Test Upload Ảnh Nhanh

## Vấn đề: Debug Console bị đứng

Khi chạy bằng F5 (Debug mode), app có thể bị chậm hoặc đứng do debugger.

**Giải pháp: Dùng terminal thay vì Debug Console**

## Cách test upload ảnh (NHANH NHẤT)

### Bước 1: Chạy app bình thường

Trong terminal VS Code:

```bash
cd D:\CCPT_Nhom3_ChieuT4
flutter run
```

Hoặc nếu app đang chạy rồi thì bỏ qua bước này.

### Bước 2: Mở terminal thứ 2 để xem log

1. Nhấn `Ctrl + Shift + ` (backtick) để mở terminal mới
2. Hoặc: Terminal → New Terminal
3. Chạy:
   ```bash
   cd D:\CCPT_Nhom3_ChieuT4
   .\view-logs.bat
   ```

### Bước 3: Test upload

1. Vào app trên điện thoại
2. Mở một chat room
3. Nhấn icon ảnh (📷)
4. Chọn ảnh từ thư viện
5. Xem log trong terminal thứ 2

## Log thành công sẽ như thế này:

```
I/flutter: 🔍 [UPLOAD] Starting upload - Room: abc123, Images: 1
I/flutter: ✓ [UPLOAD] User: demo1@test.com
I/flutter: ✓ [UPLOAD] Token obtained
I/flutter: ✓ [UPLOAD] Adding image: IMG_001.jpg, MIME: image/jpeg, Size: 123456
I/flutter: 📤 [UPLOAD] Sending to: http://192.168.2.4:3000/api/upload/images
I/flutter: ✓ [UPLOAD] Response: 200
I/flutter: ✓ [UPLOAD] Data: {success: true, data: {urls: [...], count: 1}}
I/flutter: ✅ [UPLOAD] Success! URLs: [https://storage.googleapis.com/...]
```

## Nếu có lỗi:

### Lỗi: "User not logged in"

```
I/flutter: ❌ [UPLOAD] User not logged in
```

**Giải pháp:** Đăng nhập lại vào app

### Lỗi: "DioException"

```
I/flutter: ❌ [UPLOAD] Error: DioException [connection timeout]
```

**Giải pháp:**

- Kiểm tra backend có chạy không
- Kiểm tra IP trong `.env` có đúng không

### Lỗi: "No images provided"

```
I/flutter: ❌ [UPLOAD] Error: Exception: No images provided
```

**Giải pháp:** ImagePicker không chọn được ảnh, thử lại

## Kiểm tra backend

Mở terminal thứ 3:

```bash
cd D:\App_Chat_API\backend
npm run dev
```

Backend phải chạy và hiện:

```
🚀 Server running on http://0.0.0.0:3000
✅ Firebase Admin SDK initialized successfully
```

## Tóm tắt

1. ✅ **Terminal 1:** Chạy app Flutter (`flutter run`)
2. ✅ **Terminal 2:** Xem log (`.\view-logs.bat`)
3. ✅ **Terminal 3:** Chạy backend (`npm run dev`)
4. ✅ **App:** Test upload ảnh

**KHÔNG CẦN dùng Debug Console (F5)** - nó chậm và hay bị đứng!

## Nếu muốn dùng Debug Console

Nếu bạn vẫn muốn dùng Debug Console:

1. **Tắt tất cả breakpoints** (Ctrl + Shift + F9)
2. **Chạy ở chế độ Profile thay vì Debug:**
   ```bash
   flutter run --profile
   ```
3. Hoặc dùng **Release mode:**
   ```bash
   flutter run --release
   ```

Nhưng cách tốt nhất vẫn là dùng terminal như hướng dẫn ở trên!
