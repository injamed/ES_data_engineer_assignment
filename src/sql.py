import sqlite3
from typing import List, Union

"""
This file contains helper functions to create the connection 
to the database and to query the database
"""


DATABASE_NAME = "epidemic.db"


def create_connection(db_file: str) -> sqlite3.Connection:
    """create a database connection to a SQLite database"""
    try:
        conn = sqlite3.connect(db_file)
    except sqlite3.Error as e:
        print(e)
    finally:
        if conn:
            return conn


def fetch_data(query: str) -> Union[List, None]:
    """fetch data by a query"""
    data = None
    try:
        conn = create_connection(DATABASE_NAME)
        c = conn.cursor()
        c.execute(query)
        data = c.fetchall()
        conn.commit()
        conn.close()
    except sqlite3.Error as e:
        print("SQLite error: %s" % " ".join(e.args))
    return data


def create_or_replace_table(name: str, query: str):
    """Create a new table based on a query"""
    try:
        statement = f"DROP TABLE IF EXISTS {name}"
        conn = create_connection(DATABASE_NAME)
        c = conn.cursor()
        c.execute(statement)
        conn.commit()
        conn.close()

        statement = f"CREATE TABLE {name} AS {query}"
        conn = create_connection(DATABASE_NAME)
        c = conn.cursor()
        c.execute(statement)
        conn.commit()
        conn.close()
    except sqlite3.Error as e:
        print(e)
