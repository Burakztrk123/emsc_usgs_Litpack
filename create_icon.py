from PIL import Image, ImageDraw, ImageFont
import os

# Create a 512x512 icon for Sismo Alarm
def create_sismo_alarm_icon():
    # Create a new image with transparent background
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background circle with gradient effect
    center = size // 2
    radius = size // 2 - 20
    
    # Red gradient background
    for i in range(radius):
        alpha = int(255 * (1 - i / radius))
        color = (220, 50, 50, alpha)
        draw.ellipse([center - radius + i, center - radius + i, 
                     center + radius - i, center + radius - i], 
                    fill=color)
    
    # Main red circle
    draw.ellipse([center - radius, center - radius, 
                 center + radius, center + radius], 
                fill=(200, 30, 30, 255), outline=(150, 20, 20, 255), width=4)
    
    # Warning triangle in center
    triangle_size = 120
    triangle_points = [
        (center, center - triangle_size//2),  # top
        (center - triangle_size//2, center + triangle_size//2),  # bottom left
        (center + triangle_size//2, center + triangle_size//2)   # bottom right
    ]
    draw.polygon(triangle_points, fill=(255, 255, 255, 255), outline=(200, 200, 200, 255), width=3)
    
    # Exclamation mark
    # Main line
    draw.rectangle([center - 8, center - 40, center + 8, center + 10], fill=(200, 30, 30, 255))
    # Dot
    draw.ellipse([center - 8, center + 20, center + 8, center + 36], fill=(200, 30, 30, 255))
    
    # Save the icon
    output_path = 'assets/images/sismo_alarm_logo.png'
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, 'PNG')
    print(f"Icon created: {output_path}")
    
    return output_path

if __name__ == "__main__":
    create_sismo_alarm_icon()
