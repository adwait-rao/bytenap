import os
import re
import shutil

# Paths
base_content_dir = "/home/adwaitrao/Documents/bytenap/content"
attachments_dir = "/home/adwaitrao/Documents/adwait-notes/assets"
static_images_dir = "/home/adwaitrao/Documents/bytenap/static/images"

# Directories to process
markdown_dirs = [
    os.path.join(base_content_dir, "posts"),
    os.path.join(base_content_dir, "projects")
]

# Function to process markdown files in a given directory
def process_markdown_files(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".md"):
            filepath = os.path.join(directory, filename)
            
            with open(filepath, "r") as file:
                content = file.read()
            
            # Find all image links in the format [[image.png]]
            images = re.findall(r'\[\[([^]]*\.png)\]\]', content)
            
            for image in images:
                markdown_image = f"![Image Description](/images/{image.replace(' ', '%20')})"
                content = content.replace(f"[[{image}]]", markdown_image)
                
                image_source = os.path.join(attachments_dir, image)
                if os.path.exists(image_source):
                    shutil.copy(image_source, static_images_dir)

            with open(filepath, "w") as file:
                file.write(content)

# Process all markdown directories
for md_dir in markdown_dirs:
    process_markdown_files(md_dir)

print("Markdown files in 'posts' and 'projects' processed and images copied successfully.")
