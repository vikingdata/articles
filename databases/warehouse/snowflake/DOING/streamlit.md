

Make database and schema on snowflake
Load titanic file

pip install snowflake-snowpark-python

write out streamlit file

[connections.snowflake]
account = "hxeabcd-uzb5abcd"
user = "GOD"
password = "password"
role = "ACCOUNTADMIN"
warehouse = "COMPUTER_WH"
database = "ML"
schema = "ML"
client_session_keep_alive = true

pip install any modules used
from snowflake.ml.registry import Registry