import psycopg2

def get_connection():
    return psycopg2.connect(
        host="localhost",
        database="shock_intelligence",
        user="postgres",
        password="cohle@1505",
        port="5432"
    )
