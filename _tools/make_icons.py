"""生成占位应用图标（纯色底 + 简笔灯与档案轮廓），避免工程缺资源报错。"""
from PIL import Image, ImageDraw

def make(path: str, size: int) -> None:
    img = Image.new("RGB", (size, size), (28, 36, 56))
    d = ImageDraw.Draw(img)
    # 档案袋轮廓
    d.rounded_rectangle([size * 0.18, size * 0.30, size * 0.82, size * 0.80],
                        radius=size * 0.06, fill=(238, 232, 214))
    d.rectangle([size * 0.18, size * 0.30, size * 0.82, size * 0.40], fill=(200, 176, 122))
    # 灯光光晕
    d.ellipse([size * 0.40, size * 0.10, size * 0.60, size * 0.30], fill=(247, 206, 100))
    d.line([size * 0.50, size * 0.30, size * 0.50, size * 0.44], fill=(120, 96, 60), width=max(2, size // 90))
    # 档案线
    for i in range(3):
        y = size * (0.52 + i * 0.08)
        d.line([size * 0.28, y, size * 0.72, y], fill=(120, 110, 96), width=max(1, size // 160))
    img.save(path, "PNG")

base = r"C:\Users\30778\Doubao\chats\2026-11-20\new-chat\FogArchive"
make(base + r"\AppScope\resources\base\media\app_icon.png", 512)
make(base + r"\entry\src\main\resources\base\media\startIcon.png", 288)
make(base + r"\entry\src\main\resources\base\media\icon.png", 192)
print("icons done")
