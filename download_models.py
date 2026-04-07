import os
import urllib.request

models_dir = r"e:\Bomach Projects\Bomach OS\bomach_os\web\models"
os.makedirs(models_dir, exist_ok=True)

base_url = "https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights/"
models = [
    "tiny_face_detector_model-weights_manifest.json",
    "tiny_face_detector_model-shard1",
    "face_landmark_68_model-weights_manifest.json",
    "face_landmark_68_model-shard1"
]

for model in models:
    url = base_url + model
    file_path = os.path.join(models_dir, model)
    if not os.path.exists(file_path):
        print(f"Downloading {model}...")
        try:
            urllib.request.urlretrieve(url, file_path)
            print(f"Downloaded {model}")
        except Exception as e:
            print(f"Failed to download {model}: {e}")
    else:
        print(f"Already exists: {model}")
