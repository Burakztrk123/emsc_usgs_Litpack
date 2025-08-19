from PIL import Image, ImageDraw, ImageFont
import os

def create_feature_graphic():
    # Feature graphic boyutları (Google Play Store)
    width, height = 1024, 500
    
    # Gradient arka plan oluştur
    img = Image.new('RGB', (width, height), '#1976D2')
    draw = ImageDraw.Draw(img)
    
    # Gradient efekti
    for y in range(height):
        ratio = y / height
        r = int(25 + (244 - 25) * ratio)  # 25 -> 244
        g = int(118 + (67 - 118) * ratio)  # 118 -> 67
        b = int(210 + (54 - 210) * ratio)  # 210 -> 54
        color = (r, g, b)
        draw.line([(0, y), (width, y)], fill=color)
    
    try:
        # Büyük font için system font kullan
        title_font = ImageFont.truetype("arial.ttf", 72)
        subtitle_font = ImageFont.truetype("arial.ttf", 36)
        small_font = ImageFont.truetype("arial.ttf", 24)
    except:
        # Fallback font
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Logo alanı (sol taraf)
    logo_x, logo_y = 80, height//2 - 80
    logo_size = 160
    
    # Logo arka plan (beyaz daire)
    draw.ellipse([logo_x-10, logo_y-10, logo_x+logo_size+10, logo_y+logo_size+10], 
                 fill='white', outline='#FF5722', width=4)
    
    # Logo içi (deprem simgesi)
    center_x, center_y = logo_x + logo_size//2, logo_y + logo_size//2
    
    # Deprem dalgaları
    for i in range(3):
        radius = 30 + i * 25
        draw.ellipse([center_x-radius, center_y-radius, center_x+radius, center_y+radius], 
                     outline='#FF5722', width=6-i*2)
    
    # Merkez nokta
    draw.ellipse([center_x-8, center_y-8, center_x+8, center_y+8], fill='#FF5722')
    
    # Ana başlık
    title_text = "Sismo Alarm"
    title_bbox = draw.textbbox((0, 0), title_text, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = logo_x + logo_size + 60
    title_y = height//2 - 60
    
    # Başlık gölgesi
    draw.text((title_x+3, title_y+3), title_text, fill='rgba(0,0,0,0.3)', font=title_font)
    # Ana başlık
    draw.text((title_x, title_y), title_text, fill='white', font=title_font)
    
    # Alt başlık
    subtitle_text = "Gerçek Zamanlı Deprem Takibi"
    subtitle_y = title_y + 80
    draw.text((title_x+2, subtitle_y+2), subtitle_text, fill='rgba(0,0,0,0.3)', font=subtitle_font)
    draw.text((title_x, subtitle_y), subtitle_text, fill='#FFE0B2', font=subtitle_font)
    
    # Özellikler
    features = [
        "• USGS & EMSC Verileri",
        "• Harita & Liste Görünümü", 
        "• Gerçek Zamanlı Bildirimler",
        "• Deprem Raporlama"
    ]
    
    feature_y = subtitle_y + 60
    for feature in features:
        draw.text((title_x+2, feature_y+2), feature, fill='rgba(0,0,0,0.3)', font=small_font)
        draw.text((title_x, feature_y), feature, fill='white', font=small_font)
        feature_y += 30
    
    # Sağ alt köşe - Powered by Litpack
    powered_text = "Powered by Litpack"
    powered_bbox = draw.textbbox((0, 0), powered_text, font=small_font)
    powered_width = powered_bbox[2] - powered_bbox[0]
    powered_x = width - powered_width - 30
    powered_y = height - 40
    
    draw.text((powered_x+1, powered_y+1), powered_text, fill='rgba(0,0,0,0.4)', font=small_font)
    draw.text((powered_x, powered_y), powered_text, fill='rgba(255,255,255,0.8)', font=small_font)
    
    # Kaydet
    output_path = "feature_graphic_1024x500.png"
    img.save(output_path, "PNG", quality=95)
    print(f"Feature graphic oluşturuldu: {output_path}")
    
    return output_path

if __name__ == "__main__":
    create_feature_graphic()
