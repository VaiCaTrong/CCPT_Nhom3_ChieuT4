@echo off
chcp 65001 >nul
echo ========================================
echo   XEM LOG UPLOAD ẢNH REALTIME
echo ========================================
echo.
echo Đang theo dõi log...
echo Nhấn Ctrl+C để dừng
echo.
echo Hướng dẫn:
echo 1. Giữ cửa sổ này mở
echo 2. Vào app và thử upload ảnh
echo 3. Log sẽ hiện ở đây
echo.
echo ========================================
echo.

adb logcat -c
adb logcat -s flutter:V | findstr /I "UPLOAD SignIn Lỗi Error Exception"
