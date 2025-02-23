#
//  pythonAI.py
//  HelloPhotogrammetry
//
//  Created by Ritvik Gupta on 2/22/25.
//  Copyright © 2025 Apple. All rights reserved.
//

from openai import OpenAI
import os
import random
from pillow_heif import register_heif_opener
from PIL import Image
import base64

register_heif_opener()


client = OpenAI(api_key="")

def run(folder_name):
    image_dir = "/Users/mahadfaruqi/Desktop/BoilermakeXcode/BoilermakeXcode/" + folder_name

    def convert_heic_to_jpeg(heic_path):
        jpeg_path = heic_path.replace(".HEIC", ".jpeg").replace(".heic", ".jpeg")
        image = Image.open(heic_path)
        image = image.convert("RGB")
        image.save(jpeg_path, "JPEG")
        # delete heic file
        if os.path.exists(heic_path):
            os.remove(heic_path)
        return jpeg_path

    image_paths = []
    for filename in os.listdir(image_dir):
        # print(filename)
        if filename.lower().endswith((".heic", ".jpeg")):
            # print('here')
            image_path = os.path.join(image_dir, filename)
            # print(image_path)
            if filename.lower().endswith(".heic"):
                image_path = convert_heic_to_jpeg(image_path)
            image_paths.append(image_path)

    # randomly select 5 images
    selected_images = random.sample(image_paths, min(5, len(image_paths)))
    # print(selected_images)
    image_contents = []
    for image_path in selected_images:
        with open(image_path, "rb") as image_file:
            image_data = image_file.read()
            image_contents.append({"type": "image", "image": image_data})


    def encode_image(image_path):
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode("utf-8")

    image_contents = [
        {
            "type": "image_url",
            "image_url": {"url": f"data:image/jpeg;base64,{encode_image(image_path)}"},
        }
        for image_path in selected_images
    ]

    response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": (
                        "Describe the object shown in these images as a single item. "
                        "Do not refer to the images separately; provide a concise identification and description. \n\n"
                        "Please format your answer exactly as follows:\n\n"
                        "[Object Name]\n"
                        "Description: [Description (once sentence)]\n"
                        "Bold important words in the description"
                    )}
                ] + image_contents,
            }
        ],
        max_tokens=50
    )

    return response.choices[0].message.content


######################### END OF CODE ##########################

# image_path = "images/cup.jpeg"
# base64_image = encode_image(image_path)

# with open(image_path, "rb") as image_file:
#     image_data = image_file.read()

# response = client.chat.completions.create(
#     model="gpt-4o-mini",
#     messages=[
#         {
#             "role": "user",
#             "content": [
#                 {
#                     "type": "text",
#                     "text": "What is in this image?",
#                 },
#                 {
#                     "type": "image_url",
#                     "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"},
#                 },
#             ],
#         }
#     ],
#     max_tokens=50
# )

# print("Caption:", response.choices[0].message.content)

# response = client.chat.completions.create(
#     model="gpt-4-vision-preview",
#     messages=[
#         {"role": "system", "content": "You are an AI that provides captions for objects based on multiple images."},
#         {"role": "user", "content": [
#             {"role": "user", "content": [{"type": "text", "text": "Describe the object in these 5 images:"}] + image_contents}
#         ]}
#     ],
#     max_tokens=50
# )

