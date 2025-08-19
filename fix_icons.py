from PIL import Image
import os

def create_android_icons():
    # Load the original logo
    logo_path = 'assets/images/sismo_alarm_logo.png'
    
    # Icon sizes for different densities
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192
    }
    
    try:
        # Open the original image
        original = Image.open(logo_path)
        print(f"Original image size: {original.size}")
        print(f"Original image mode: {original.mode}")
        
        # Convert to RGBA if needed
        if original.mode != 'RGBA':
            original = original.convert('RGBA')
        
        for folder, size in sizes.items():
            # Create the directory if it doesn't exist
            output_dir = f'android/app/src/main/res/{folder}'
            os.makedirs(output_dir, exist_ok=True)
            
            # Resize the image
            resized = original.resize((size, size), Image.Resampling.LANCZOS)
            
            # Save as PNG
            output_path = f'{output_dir}/ic_launcher.png'
            resized.save(output_path, 'PNG', optimize=True)
            print(f"Created: {output_path} ({size}x{size})")
            
        print("All Android icons created successfully!")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    create_android_icons()
