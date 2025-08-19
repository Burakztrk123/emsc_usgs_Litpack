from PIL import Image, ImageDraw, ImageFont
import os

def create_feature_graphic():
    """1024x500 Feature Graphic oluştur"""
    width, height = 1024, 500
    
    # Gradient arka plan
    img = Image.new('RGB', (width, height), '#1976D2')
    draw = ImageDraw.Draw(img)
    
    # Gradient efekti
    for y in range(height):
        ratio = y / height
        r = int(25 + (244 - 25) * ratio)
        g = int(118 + (67 - 118) * ratio) 
        b = int(210 + (54 - 210) * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 72)
        subtitle_font = ImageFont.truetype("arial.ttf", 36)
        small_font = ImageFont.truetype("arial.ttf", 24)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Logo (sol taraf)
    logo_x, logo_y = 80, height//2 - 80
    logo_size = 160
    
    # Logo arka plan
    draw.ellipse([logo_x-10, logo_y-10, logo_x+logo_size+10, logo_y+logo_size+10], 
                 fill='white', outline='#FF5722', width=4)
    
    # Deprem dalgaları
    center_x, center_y = logo_x + logo_size//2, logo_y + logo_size//2
    for i in range(3):
        radius = 30 + i * 25
        draw.ellipse([center_x-radius, center_y-radius, center_x+radius, center_y+radius], 
                     outline='#FF5722', width=6-i*2)
    
    # Merkez nokta
    draw.ellipse([center_x-8, center_y-8, center_x+8, center_y+8], fill='#FF5722')
    
    # Ana başlık
    title_text = "Sismo Alarm"
    title_x = logo_x + logo_size + 60
    title_y = height//2 - 60
    
    draw.text((title_x+3, title_y+3), title_text, fill=(0,0,0,80), font=title_font)
    draw.text((title_x, title_y), title_text, fill='white', font=title_font)
    
    # Alt başlık
    subtitle_text = "Gerçek Zamanlı Deprem Takibi"
    subtitle_y = title_y + 80
    draw.text((title_x+2, subtitle_y+2), subtitle_text, fill=(0,0,0,80), font=subtitle_font)
    draw.text((title_x, subtitle_y), subtitle_text, fill='#FFE0B2', font=subtitle_font)
    
    # Powered by
    powered_text = "Powered by Litpack"
    powered_x = width - 250
    powered_y = height - 40
    draw.text((powered_x+1, powered_y+1), powered_text, fill=(0,0,0,100), font=small_font)
    draw.text((powered_x, powered_y), powered_text, fill=(255,255,255,200), font=small_font)
    
    img.save("feature_graphic_1024x500.png", "PNG", quality=95)
    print("✅ Feature graphic oluşturuldu: feature_graphic_1024x500.png")

def create_hi_res_icon():
    """512x512 Hi-res icon oluştur"""
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Arka plan daire
    margin = 20
    draw.ellipse([margin, margin, size-margin, size-margin], 
                 fill='#FF5722', outline='#D32F2F', width=8)
    
    # Deprem dalgaları
    center = size // 2
    for i in range(4):
        radius = 80 + i * 60
        if radius < center - margin:
            draw.ellipse([center-radius, center-radius, center+radius, center+radius], 
                         outline='white', width=12-i*2)
    
    # Merkez nokta
    draw.ellipse([center-20, center-20, center+20, center+20], fill='white')
    
    img.save("hi_res_icon_512x512.png", "PNG")
    print("✅ Hi-res icon oluşturuldu: hi_res_icon_512x512.png")

if __name__ == "__main__":
    create_feature_graphic()
    create_hi_res_icon()
    print("\n📱 Store asset'leri hazır!")
