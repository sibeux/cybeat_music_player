import os


INPUT_FILES = [
    ".env.development",
    ".env.staging",
    ".env.production",
]

OUTPUT_FILES = [
    ".github/secrets/ENV_VARS_DEV.json",
    ".github/secrets/ENV_VARS_STAGE.json",
    ".github/secrets/ENV_VARS_PROD.json",
]


def convert_env_to_secret(input_file, output_file):
    entries = []

    with open(input_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()

            if not line or line.startswith("#"):
                continue

            if "=" not in line:
                continue

            key, value = line.split("=", 1)

            key = key.strip()
            value = value.strip()

            # Format secret:
            # "\"KEY\"": "\"VALUE\""
            entry = f'"\\\"{key}\\\"": "\\\"{value}\\\""'

            entries.append(entry)

    output = "{\n\n" + ",\n\n".join(entries) + "\n\n}"

    # Pastikan folder output sudah ada
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(output)

    print(f"Generated: {output_file}")


if __name__ == "__main__":
    for input_file, output_file in zip(INPUT_FILES, OUTPUT_FILES):
        convert_env_to_secret(input_file, output_file)