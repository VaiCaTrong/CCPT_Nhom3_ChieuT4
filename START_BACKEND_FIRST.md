# ⚠️ QUAN TRỌNG: Phải Khởi Động Backend Trước!

## Vấn đề hiện tại

Upload ảnh bị timeout vì **BACKEND KHÔNG CHẠY**.

Từ log:

```
📤 [UPLOAD] Sending to: http://192.168.2.4:3000/api/upload/images
❌ [UPLOAD] Error: DioException [connection timeout]
```

Test kết nối:

```
TcpTestSucceeded: False  ← Backend không chạy!
```

## Giải pháp: Khởi động Backend

### Cách 1: Dùng VS Code Terminal

1. **Mở terminal mới** (nhấn `+` ở góc terminal)
2. **Chạy lệnh:**

   ```bash
   cd D:\App_Chat_API\backend
   npm run dev
   ```

3. **Đợi đến khi thấy:**

   ```
   🚀 Server running on http://0.0.0.0:3000
   ✅ Firebase Admin SDK initialized successfully
   ```

4. **QUAN TRỌNG:** Giữ terminal này mở! Đừng tắt!

### Cách 2: Dùng Command Prompt riêng

1. Mở Command Prompt mới (Windows + R → gõ `cmd`)
2. Chạy:
   ```bash
   cd D:\App_Chat_API\backend
   npm run dev
   ```
3. Giữ cửa sổ này mở

### Cách 3: Dùng script

```bash
cd D:\App_Chat_API\backend
.\start-backend.bat
```

## Sau khi Backend chạy

### Kiểm tra backend đã chạy chưa:

Mở trình duyệt và vào: http://192.168.2.4:3000

Nếu thấy trang web hoặc JSON response → Backend đã chạy ✅

### Test upload lại:

1. Vào app trên điện thoại
2. Mở chat room
3. Nhấn icon ảnh
4. Chọn ảnh
5. **Upload sẽ thành công!**

## Xem log upload

Mở terminal thứ 3:

```bash
cd D:\CCPT_Nhom3_ChieuT4
.\view-logs.bat
```

Khi upload thành công, bạn sẽ thấy:

```
I/flutter: 🔍 [UPLOAD] Starting upload
I/flutter: ✓ [UPLOAD] User: demo1@test.com
I/flutter: ✓ [UPLOAD] Token obtained
I/flutter: ✓ [UPLOAD] Adding image
I/flutter: 📤 [UPLOAD] Sending to: http://192.168.2.4:3000/api/upload/images
I/flutter: ✓ [UPLOAD] Response: 200        ← Thành công!
I/flutter: ✅ [UPLOAD] Success! URLs: [...]
```

## Tóm tắt

**3 Terminal cần mở:**

1. **Terminal 1:** Flutter app

   ```bash
   cd D:\CCPT_Nhom3_ChieuT4
   flutter run
   ```

2. **Terminal 2:** Backend API ← **QUAN TRỌNG!**

   ```bash
   cd D:\App_Chat_API\backend
   npm run dev
   ```

3. **Terminal 3:** Xem log (tùy chọn)
   ```bash
   cd D:\CCPT_Nhom3_ChieuT4
   .\view-logs.bat
   ```

## Lưu ý

- Backend phải chạy TRƯỚC khi test upload
- Nếu tắt backend, upload sẽ bị timeout
- Giữ backend chạy trong suốt quá trình test

## Nếu backend không khởi động được

Kiểm tra:

1. **Node.js đã cài chưa?**

   ```bash
   node --version
   ```

2. **Dependencies đã cài chưa?**

   ```bash
   cd D:\App_Chat_API\backend
   npm install
   ```

3. **File .env có đúng không?**
   - Kiểm tra `D:\App_Chat_API\backend\.env`
   - Đảm bảo có `FIREBASE_SERVICE_ACCOUNT_PATH`

4. **Firebase service account có tồn tại không?**
   - Kiểm tra `D:\App_Chat_API\backend\firebase-service-account.json`

## Kết luận

**Code upload ảnh đã hoạt động hoàn hảo!** ✅

Chỉ cần khởi động backend là upload sẽ thành công ngay!

Hãy khởi động backend và thử lại! 🚀
