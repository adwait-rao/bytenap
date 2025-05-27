import os
import re
import shutil

# Paths
base_content_dir = "/home/adwaitrao/Documents/bytenap/content"
attachments_dir = "/home/adwaitrao/Documents/adwait-notes/assets"
static_images_dir = "/home/adwaitrao/Documents/bytenap/static/images"

# Directories and files to process
markdown_dirs = [
    os.path.join(base_content_dir, "posts"),  # directory
]

markdown_files = [
    os.path.join(base_content_dir, "projects.md"),
    os.path.join(base_content_dir, "about.md"),
    os.path.join(base_content_dir, "_index.md"),
]

# Function to process a single markdown file
def process_markdown_file(filepath):
    print(f"Processing: {filepath}")
    
    with open(filepath, "r") as file:
        content = file.read()

    # Match [[image.png]]
    images = re.findall(r'\[\[([^]]*\.png)\]\]', content)

    for image in images:
        markdown_image = f"![Image Description](/images/{image.replace(' ', '%20')})"
        content = content.replace(f"[[{image}]]", markdown_image)

        image_source = os.path.join(attachments_dir, image)
        if os.path.exists(image_source):
            shutil.copy(image_source, static_images_dir)
            print(f"Copied image: {image}")
        else:
            print(f"⚠️ Image not found: {image_source}")

    with open(filepath, "w") as file:
        file.write(content)

# Process markdown directories
for directory in markdown_dirs:
    if os.path.isdir(directory):
        for filename in os.listdir(directory):
            if filename.endswith(".md"):
                process_markdown_file(os.path.join(directory, filename))

# Process standalone markdown files
for filepath in markdown_files:
    if os.path.isfile(filepath):
        process_markdown_file(filepath)

print("✅ Markdown processing complete — images copied and links updated.")

