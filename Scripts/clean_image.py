import sys
from PIL import Image, ImageDraw

def remove_background(img_path):
    print(f"Processing {img_path}")
    try:
        img = Image.open(img_path).convert("RGBA")
        width, height = img.size
        
        mask_img = img.copy()
        
        # Flood fill from the 4 corners to catch all continuous dark background
        ImageDraw.floodfill(mask_img, (0, 0), (255, 0, 255, 255), thresh=45)
        ImageDraw.floodfill(mask_img, (width-1, 0), (255, 0, 255, 255), thresh=45)
        ImageDraw.floodfill(mask_img, (0, height-1), (255, 0, 255, 255), thresh=45)
        ImageDraw.floodfill(mask_img, (width-1, height-1), (255, 0, 255, 255), thresh=45)
        
        orig_data = img.getdata()
        mask_data = mask_img.getdata()
        
        new_data = []
        for i in range(len(orig_data)):
            orig = orig_data[i]
            m = mask_data[i]
            
            # If the mask image is magenta, it is the background
            if m[0] == 255 and m[1] == 0 and m[2] == 255 and m[3] == 255:
                new_data.append((0, 0, 0, 0))
            else:
                # AI generated pixel art has a dark halo around the edges on black background
                # Remove pixels that are very dark to clean the edge
                brightness = orig[0]*0.299 + orig[1]*0.587 + orig[2]*0.114
                if brightness < 35:
                    new_data.append((0, 0, 0, 0))
                else:
                    new_data.append(orig)
                    
        img.putdata(new_data)
        
        bbox = img.getbbox()
        if bbox:
            img = img.crop(bbox)
            
        img.save(img_path, "PNG")
        print(f"Successfully processed {img_path}")
    except Exception as e:
        print(f"Error processing {img_path}: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python clean_image.py <image_path>")
    else:
        for p in sys.argv[1:]:
            remove_background(p)
