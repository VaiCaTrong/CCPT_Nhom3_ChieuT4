# Sửa lỗi DEBUG CONSOLE không hiện gì

## Nguyên nhân thường gặp

### 1. App chưa chạy ở chế độ Debug

**Kiểm tra:**

- Xem góc dưới bên phải VS Code có dòng chữ màu cam "Flutter (xxx)" không?
- Nếu không có → app chưa chạy hoặc đang chạy ở chế độ Release

**Giải pháp:**

```bash
# Dừng app hiện tại
Ctrl + C trong terminal

# Chạy lại ở chế độ debug
flutter run
```

### 2. Chọn sai Debug Console

**Kiểm tra:**

- Mở tab "DEBUG CONSOLE" (không phải "TERMINAL")
- Nếu có nhiều debug session, chọn đúng session Flutter

**Giải pháp:**

1. Nhấn `Ctrl + Shift + Y` để mở Debug Console
2. Hoặc: View → Debug Console

### 3. Log bị filter

**Kiểm tra:**

- Xem có icon filter (phễu) ở góc phải Debug Console không?
- Nếu có màu xanh → đang bật filter

**Giải pháp:**

- Nhấn vào icon filter và tắt đi
- Hoặc xóa text trong ô filter

### 4. Flutter chưa kết nối với device

**Kiểm tra:**

```bash
flutter devices
```

Phải thấy device của bạn trong danh sách.

**Giải pháp:**

- Nếu không thấy device:

  ```bash
  # Với Android
  adb devices

  # Nếu không thấy, restart adb
  adb kill-server
  adb start-server
  ```

### 5. App đang chạy từ Android Studio

**Kiểm tra:**

- Nếu bạn đã chạy app từ Android Studio, log sẽ hiện ở đó, không phải VS Code

**Giải pháp:**

- Dừng app trong Android Studio
- Chạy lại từ VS Code: `flutter run`

## Cách xem log đúng

### Trong VS Code:

1. **Chạy app:**

   ```bash
   flutter run
   ```

2. **Mở Debug Console:**
   - Nhấn `Ctrl + Shift + Y`
   - Hoặc: View → Debug Console

3. **Xem log:**
   - Log Flutter sẽ hiện ở đây
   - Bao gồm cả `print()` statements

### Trong Terminal (Android logcat):

Nếu Debug Console vẫn không hoạt động, xem log trực tiếp:

```bash
# Xem tất cả log
adb logcat

# Chỉ xem log của app Flutter
adb logcat | findstr "flutter"

# Xem log upload
adb logcat | findstr "UPLOAD"

# Xem log với tag cụ thể
adb logcat -s flutter:V
```

### Trong Android Studio:

1. Mở Android Studio
2. View → Tool Windows → Logcat
3. Chọn device và app
4. Filter: "flutter" hoặc "UPLOAD"

## Test xem log có hoạt động không

Thêm code test vào `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TEST LOG
  print('========================================');
  print('🚀 APP STARTING - LOG TEST');
  print('========================================');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

Nếu bạn thấy dòng "🚀 APP STARTING - LOG TEST" → log đang hoạt động.

## Cách chạy app đúng trong VS Code

### Cách 1: Dùng F5

1. Mở file `main.dart`
2. Nhấn `F5`
3. Chọn "Dart & Flutter"
4. Debug Console sẽ tự động mở

### Cách 2: Dùng Command Palette

1. Nhấn `Ctrl + Shift + P`
2. Gõ: "Flutter: Select Device"
3. Chọn device của bạn
4. Nhấn `F5` để chạy

### Cách 3: Dùng Terminal

```bash
cd D:\CCPT_Nhom3_ChieuT4
flutter run -v
```

Flag `-v` (verbose) sẽ hiện nhiều log hơn.

## Kiểm tra cấu hình VS Code

Tạo/kiểm tra file `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Debug",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "flutterMode": "debug"
    }
  ]
}
```

## Nếu vẫn không được

### Restart VS Code:

1. Đóng VS Code hoàn toàn
2. Mở lại
3. Chạy `flutter run` lại

### Restart Flutter:

```bash
flutter clean
flutter pub get
flutter run
```

### Kiểm tra extension:

1. Mở Extensions (Ctrl + Shift + X)
2. Tìm "Flutter" và "Dart"
3. Đảm bảo đã cài đặt và enabled
4. Nếu cần, uninstall và install lại

## Xem log upload ảnh

Sau khi sửa xong, khi upload ảnh bạn sẽ thấy:

**Trong Debug Console (VS Code):**

```
🔍 [UPLOAD] Starting upload - Room: xxx, Images: 1
✓ [UPLOAD] User: email@example.com
✓ [UPLOAD] Token obtained
✓ [UPLOAD] Adding image: image.jpg, MIME: image/jpeg, Size: 123456
📤 [UPLOAD] Sending to: http://192.168.2.4:3000/api/upload/images
✓ [UPLOAD] Response: 200
✅ [UPLOAD] Success! URLs: [https://...]
```

**Trong Terminal (adb logcat):**

```
I/flutter (12345): 🔍 [UPLOAD] Starting upload...
I/flutter (12345): ✓ [UPLOAD] User: email@example.com
...
```

## Tóm tắt

1. ✅ Chạy app bằng `flutter run` hoặc `F5`
2. ✅ Mở Debug Console: `Ctrl + Shift + Y`
3. ✅ Nếu không thấy log, dùng `adb logcat | findstr "flutter"`
4. ✅ Test bằng cách thêm `print()` vào code
