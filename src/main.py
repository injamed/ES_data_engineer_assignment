from pathlib import Path
from pprint import pprint

from sql import create_or_replace_table, fetch_data


def main():
    print("Creating fact_stream with the following query:")
    path = Path("src") / "queries" / "fact_stream.sql"
    query = path.read_text()
    print(query)
    create_or_replace_table("fact_stream", query)

    for i in range(1, 6):
        print()
        print(f"----- Question {i} ------")
        path = Path("src") / "queries" / f"question_{i}.sql"
        query = path.read_text()
        print(query)
        data = fetch_data(query)
        pprint(data)


if __name__ == "__main__":
    main()
