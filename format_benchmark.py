import fileinput


OVERVIEW = \
    "## Benchmark\n" \
    "This file is automatically generated by a [GitHub Action](/actions/workflows/benchmark.yml). " \
    "The latest image for ndunnett/python and the official Python Docker image are pulled " \
    "and used to run PyPerformance, with the results then compared and formatted into this document."


def format_detail(lines):
    """Format details into valid markdown"""
    detail = [f"## {lines[0]}"]
    detail.extend([f"- {line}" for line in lines[1:]])
    return "\n".join(detail)


def format_table(lines):
    """Format table into valid markdown"""
    table = filter(lambda x: not x.startswith("+--"), lines)
    table = [line.replace("=", "-").replace("+", "|") for line in table]
    table = ["## Comparison"] + table
    return "\n".join(table)


def process_results(input):
    """Filter out and format PyPerformance output"""
    # replace "===" bars
    input = input.replace("====================\n\n", "")

    # replace filenames with identifiers
    input = input.replace("ndunnett-python.json", "ndunnett/python")
    input = input.replace("official-python.json", "Official Python")

    # split out and format sections
    sections = input.split("\n\n")
    detail_1 = format_detail(sections[0].split("\n"))
    detail_2 = format_detail(sections[1].split("\n"))
    table = format_table(sections[2].split("\n"))

    return "\n\n".join([OVERVIEW, detail_1, detail_2, table])


if __name__ == "__main__":
    lines = fileinput.input()
    with open("BENCHMARK.md", mode="w") as file:
        file.write(process_results("".join(lines)))
