from argparse import ArgumentParser
from pathlib import Path
import json


def get_python_patch(minor_version: str) -> str:
    """Get the latest patch version for a given minor version of Python."""
    # todo: navigate python ftp server to determine latest version
    # https://www.python.org/ftp/python/
    return {"3.13": "3.13.0b3", "3.12": "3.12.4", "3.11": "3.11.9", "3.10": "3.10.14"}[minor_version]


def parse_base_image(base_image: dict[str, str]) -> tuple[str, str]:
    """Parse base image dict into tuple."""
    repo, tag = (base_image["repo"], base_image["tag"])
    # todo: check latest available version of base image
    return (repo, tag)


def generate_matrix_line(base_image: dict[str, str], python_version: str, latest: dict[str, str]) -> dict[str, str]:
    """Transform variant data into matrix include line."""
    base_repo, base_tag = parse_base_image(base_image)
    patch_version = get_python_patch(python_version)
    tag = f"{base_tag}-{patch_version}"

    [major_version, minor_num, _] = patch_version.split(".")
    minor_version = f"{major_version}.{minor_num}"
    aliases = [f"{base_tag}-{minor_version}"]

    if minor_version == latest["python_version"] and base_tag == latest["base_tag"]:
        aliases.append("latest")
        aliases.append(major_version)

    if minor_version == latest["python_version"]:
        aliases.append(f"{base_tag}-{major_version}")

    if base_tag == latest["base_tag"]:
        aliases.append(minor_version)
        aliases.append(patch_version)

    return {
        "tag": tag,
        "aliases": sorted(aliases),
        "base_image_repo": base_repo,
        "base_image_tag": base_tag,
        "python_version": patch_version,
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
                    generate_matrix_line(base_image, python_version, variants["latest"])
                    for base_image in variants["base_images"]
                    for python_version in variants["python_versions"]
                ]
            },
            mf,
        )
