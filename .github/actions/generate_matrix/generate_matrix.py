from argparse import ArgumentParser
from pathlib import Path
import json


def get_latest_python_version(minor_version: str) -> str:
    """Get the latest patch version for a given minor version of Python."""
    return {"3.13": "3.13.0b3", "3.12": "3.12.4", "3.11": "3.11.9", "3.10": "3.10.14"}[minor_version]


def parse_base_image(base_image: dict[str, str]) -> tuple[str, str]:
    """Parse base image dict into tuple."""
    repo, tag = (base_image["repo"], base_image["tag"])
    # todo: check latest available version of base image
    return (repo, tag)


def generate_matrix_line(base_image, python_version: str) -> dict[str, str]:
    """Transform variant data into matrix include line."""
    repo, tag = parse_base_image(base_image)
    version = get_latest_python_version(python_version)

    return {
        "base_image_repo": repo,
        "base_image_tag": tag,
        "python_version": version,
    }


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("-i", "--variants-file", type=Path, required=True)
    parser.add_argument("-o", "--matrix-file", type=Path, required=True)
    args = parser.parse_args()

    with open(args.variants_file, mode="r") as vf, open(args.matrix_file, mode="w") as mf:
        variants = json.load(vf)
        json.dump(
            {
                "include": [
                    generate_matrix_line(base_image, python_version)
                    for base_image in variants["base_images"]
                    for python_version in variants["python_versions"]
                ]
            },
            mf,
        )
