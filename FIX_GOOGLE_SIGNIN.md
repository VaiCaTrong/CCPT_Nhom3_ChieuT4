# Fix Google Sign-In Error 10

## Lỗi hiện tại:
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:)
```

Error code 10 = DEVELOPER_ERROR - OAuth Client ID chưa được cấu hình đúng.

## SHA-1 của bạn:
```
E7:66:F1:7B:E2:3F:65:23:AC:27:C4:6F:72:4D:2C:37:34:9D:29:61
```

## Package name:
```
com.example.chat_app_final
```

## Các bước fix:

### Bước 1: Vào Google Cloud Console
1. Truy cập: https://console.cloud.google.com/apis/credentials?project=chatappfinal-620d3
2. Đăng nhập với tài khoản Firebase

### Bước 2: Tạo OAuth 2.0 Client ID mới
1. Click **"+ CREATE CREDENTIALS"** ở trên
2. Chọn **"OAuth client ID"**
3. Application type: **Android**
4. Name: `My Chat Android`
5. Package name: `com.example.chat_app_final`
6. SHA-1 certificate fingerprint: `E7:66:F1:7B:E2:3F:65:23:AC:27:C4:6F:72:4D:2C:37:34:9D:29:61`
7. Click **"CREATE"**

### Bước 3: Copy Client ID
Sau khi tạo, copy **Client ID** (dạng: `xxxxx.apps.googleusercontent.com`)

### Bước 4: Cập nhật google-services.json
Thay thế `PLACEHOLDER` trong file `android/app/google-services.json` bằng Client ID vừa copy.

### Bước 5: Chạy lại app
```bash
flutter clean
flutter pub get
flutter run
```

## Hoặc làm nhanh hơn:

### Xóa OAuth Client cũ và tạo lại:
1. Vào Google Cloud Console Credentials
2. Xóa tất cả OAuth Client IDs cũ (nếu có)
3. Tạo mới với SHA-1 đúng như trên
4. Download google-services.json mới từ Firebase
5. Copy vào `android/app/`
6. Run app

## Link hữu ích:
- Google Cloud Console: https://console.cloud.google.com/apis/credentials?project=chatappfinal-620d3
- Firebase Console: https://console.firebase.google.com/project/chatappfinal-620d3/settings/general
