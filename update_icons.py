from PIL import Image
import os
import shutil

def update_all_icons():
    """Yeni icon'u tüm boyutlarda oluştur ve yerleştir"""
    
    # Kaynak icon'u yükle
    source_icon = Image.open(r"C:\Users\Victus\Desktop\192_sismoalarm.png")
    
    # Android icon boyutları
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    # iOS icon boyutları
    ios_sizes = {
        'Icon-App-20x20@1x.png': 20,
        'Icon-App-20x20@2x.png': 40,
        'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29,
        'Icon-App-29x29@2x.png': 58,
        'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40,
        'Icon-App-40x40@2x.png': 80,
        'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120,
        'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76,
        'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167,
        'Icon-App-1024x1024@1x.png': 1024
    }
    
    print("🎨 Android icon'ları oluşturuluyor...")
    
    # Android icon'ları oluştur
    for folder, size in android_sizes.items():
        # Klasör yolu
        folder_path = f"android/app/src/main/res/{folder}"
        os.makedirs(folder_path, exist_ok=True)
        
        # Icon'u yeniden boyutlandır
        resized_icon = source_icon.resize((size, size), Image.Resampling.LANCZOS)
        
        # Kaydet
        icon_path = f"{folder_path}/ic_launcher.png"
        resized_icon.save(icon_path, "PNG")
        print(f"✅ {icon_path} ({size}x{size})")
    
    print("\n🍎 iOS icon'ları oluşturuluyor...")
    
    # iOS icon'ları oluştur
    ios_path = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_path, exist_ok=True)
    
    for filename, size in ios_sizes.items():
        # Icon'u yeniden boyutlandır
        resized_icon = source_icon.resize((size, size), Image.Resampling.LANCZOS)
        
        # Kaydet
        icon_path = f"{ios_path}/{filename}"
        resized_icon.save(icon_path, "PNG")
        print(f"✅ {filename} ({size}x{size})")
    
    print("\n🏪 Store icon'ları oluşturuluyor...")
    
    # Google Play Store hi-res icon (512x512)
    store_icon = source_icon.resize((512, 512), Image.Resampling.LANCZOS)
    store_icon.save("hi_res_icon_512x512.png", "PNG")
    print("✅ hi_res_icon_512x512.png (512x512)")
    
    print("\n🎉 Tüm icon'lar başarıyla güncellendi!")

if __name__ == "__main__":
    update_all_icons()
