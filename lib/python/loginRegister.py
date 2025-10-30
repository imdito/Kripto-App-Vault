import mysql.connector
from mysql.connector import Error
from flask import Flask

app = Flask(__name__)
host = "localhost"
user = "root"
password = ""
database = "test"
port = 3306


def connection_db():
    """ create a database connection to the MySQL database """
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database,
            port=port
        )
        print("Connection to MySQL DB successful")
    except Error as e:
        print(f"The error '{e}' occurred")

    return connection

query ="SELECT * FROM users"
def execute_read_query(connection, query):
    cursor = connection.cursor()
    result = None
    try:
        cursor.execute(query)
        result = cursor.fetchall()
        return result
    except Error as e:
        print(f"The error '{e}' occurred")
connection = connection_db()
results = execute_read_query(connection, query)
for result in results:
    print(result)
def execute_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        print("Query executed successfully")
    except Error as e:
        print(f"The error '{e}' occurred")


@app.route('/tes/<koneksi>')
def index(koneksi):

    return f"Hello, {koneksi}!"


if __name__ == '__main__':
    app.run(debug=True)