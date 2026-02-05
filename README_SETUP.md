# Hướng dẫn Setup Ứng dụng Chat

## Yêu cầu
- Flutter SDK
- Node.js (cho backend)
- Firebase account

## Bước 1: Clone project

```bash
git clone <your-repo-url>
cd CCPT_Nhom3_ChieuT4
```

## Bước 2: Cấu hình Backend

### 2.1. Cài đặt dependencies

```bash
cd ../App_Chat_API/backend
npm install
```

### 2.2. Cấu hình .env

Copy file `.env.example` thành `.env` và điền thông tin:

```bash
cp .env.example .env
```

### 2.3. Chạy backend

```bash
npm start
```

Backend sẽ chạy tại `http://localhost:3000`

## Bước 3: Cấu hình Flutter App

### 3.1. Cài đặt dependencies

```bash
cd ../../CCPT_Nhom3_ChieuT4
flutter pub get
```

### 3.2. Cấu hình .env

Copy file `.env.example` thành `.env`:

```bash
cp .env.example .env
```

### 3.3. Chỉnh sửa file .env

#### Nếu chạy trên Emulator/Simulator:

```env
API_BASE_URL=http://localhost:3000/api
ZEGO_APP_ID=872327054
ZEGO_APP_SIGN=9f51b89db7cefc82a011d91e70a7596314f199e4623f9e9dc6b70697989c0711
```

#### Nếu chạy trên điện thoại thật:

1. Tìm địa chỉ IP của máy tính:
   - **Windows**: Mở CMD và chạy `ipconfig`, tìm "IPv4 Address"
   - **Mac/Linux**: Mở Terminal và chạy `ifconfig`, tìm "inet"

2. Thay đổi `.env`:

```env
API_BASE_URL=http://192.168.x.x:3000/api
ZEGO_APP_ID=872327054
ZEGO_APP_SIGN=9f51b89db7cefc82a011d91e70a7596314f199e4623f9e9dc6b70697989c0711
```

Thay `192.168.x.x` bằng IP máy tính của bạn.

3. **Quan trọng**: Đảm bảo điện thoại và máy tính cùng mạng WiFi!

## Bước 4: Chạy ứng dụng

```bash
flutter run
```

## Lưu ý

- File `.env` không được commit lên Git (đã có trong `.gitignore`)
- Mỗi người cần tạo file `.env` riêng dựa trên `.env.example`
- Nếu backend không chạy, app vẫn hoạt động với Firebase nhưng không có API features

## Troubleshooting

### Lỗi: "Failed to connect to backend"

- Kiểm tra backend đang chạy: `http://localhost:3000`
- Kiểm tra IP address trong `.env` đúng chưa
- Kiểm tra firewall có block port 3000 không

### Lỗi: "Zego not initialized"

- Kiểm tra `ZEGO_APP_ID` và `ZEGO_APP_SIGN` trong `.env`
- Chạy lại `flutter pub get`
- Restart app

## Production Deployment

Để deploy production, thay đổi `.env`:

```env
API_BASE_URL=https://your-production-api.com/api
```
