## Overview
The [Snowflake](https://www.snowflake.com/) is a cloud-based data platform that provides a data warehouse as a service designed for the cloud, providing a single integrated platform with a single SQL-based data warehouse for all data workloads.
The Snowflake data warehouse uses a new SQL database engine with a unique architecture designed for the cloud. It provides operations to execute a wide range of standard DDL Commands, SQL Commands, and SQL Functions for querying data sources.
You can find reference information for all the Snowflake SQL commands (DDL, DML, and query syntax) [here](https://docs.snowflake.com/en/sql-reference-commands.html).

The `ballerinax/snowflake` package allows you to access the Snowflake database via the Ballerina SQL APIs and manage data persistent in the Snowflake database.

## Setup guide

To use the Snowflake connector, you must have a valid Snowflake account. If you do not have an account, you can sign up for a account [here](https://signup.snowflake.com/).

### Create a warehouse and database

1. Log in to your Snowflake account.
2. Go to the **Warehouses** tab under the **Admin** section, as shown below.
   ![Snowflake Warehouse](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-snowflake/main/docs/setup/resources/snowflakes_create_warehouse.png)

3. Click **+ Warehouse** and select a name and type for a new warehouse, as shown below.
   ![Snowflake Create Warehouse](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-snowflake/main/docs/setup/resources/snowflakes_create_warehouse_2.png)

4. Optional - You can set the created warehouse as the default warehouse for the account by editing the profile settings, as shown below.
   ![Snowflake Edit Profile](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-snowflake/main/docs/setup/resources/snokeflakes_user_profile.png)
   ![Snowflake set default warehouse](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-snowflake/main/docs/setup/resources/snowflakes_set_default_warehouse.png)

*NOTE* If you do not set a default warehouse, you must specify the warehouse name when you create a connection to the Snowflake database.

5. Go to the **Databases** tab under the **Data** section and click **+ Database** to create a new database, as shown below.
   ![Snowflake Database](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-snowflake/main/docs/setup/resources/snowflakes_create_database.png)

*NOTE* Create a database can either be created using the Snowflake web interface or using the SQL command with the Snowflake connector.

### Configure key-pair authentication

To use the Snowflake connector with key-pair authentication, you must have a public/private key pair. You can generate a key pair using the following command:

1. Generate the private key using the following command:
```shell
openssl genrsa 2048 | openssl pkcs8 -topk8 -v2 aes256 -inform PEM -out key-aes256.p8
```
*NOTE* 3DES is not supported by the Ballerina Snowflake connector. Therefore, you must use the `-v2 aes256` option to generate the private key.

2. Generate the public key using the following command:
```shell
openssl rsa -in key-aes256.p8 -pubout -out key-aes256.pub
```

3. Copy the public and private key files to a local directory for storage. Record the path to the files. Note that the private key is stored using the PKCS#8 (Public Key Cryptography Standards) format and is encrypted using the passphrase you specified in the previous step.

4. Assign the public key to a Snowflake user by executing the following an ALTER USER command:
```sql
ALTER USER example_user SET RSA_PUBLIC_KEY='MIIBIjANBgkqh...';
```

## Quickstart

To use the snowflake connector in your Ballerina application, modify the .bal file as follows:

### Step 1: Import the connector

Import the `ballerinax/snowflake` package into your Ballerina project.
```ballerina
import ballerinax/snowflake;
```

### Step 2: Import the Snowflake driver into your Ballerina project

```ballerina
import ballerinax/snowflake.driver as _;
```

### Step 3: Instantiate a new connector

*NOTE:* Snowflake driver fails with Java 16 and above because starting with JDK 16, strong encapsulation was turned on by default and one of the driver dependencies have employed the use of sun.misc.Unsafe along with reflection. This is not allowed in Java 16 and above. Therefore, to run this example, you need to use Java 15 or below. For more information, see [here](https://community.snowflake.com/s/article/JDBC-Driver-Compatibility-Issue-With-JDK-16-and-Later). If you are using Java 16 or above, you can use the following workaround to work with the Snowflake connector:

* Export the following environment variable:
  ```shell
  export JDK_JAVA_OPTIONS="--add-opens java.base/java.nio=ALL-UNNAMED"
  ```
* Set Snowflake property `JDBC_QUERY_RESULT_FORMAT` to `JSON` as follows:
  ```ballerina
  snowflake:Options options = {
      properties: {
          "JDBC_QUERY_RESULT_FORMAT": "JSON"
      }
  };
  ```

Create a Snowflake client endpoint by giving authentication details in the Snowflake configuration.
```ballerina
snowflake:Client snowflakeClient = check new(accountIdentifier, user, password);
```

If you are using key-pair authentication, you can create a Snowflake client endpoint as follows:
```ballerina
AuthConfig authConfig = {
    user: "ballerina"
    privateKeyPath: "path/to/privatekey.p8"
    privateKeyPassphrase: "ballerina"
};
snowflake:AdvancedClient snowflakeKeyBasedClient = check new (accountIdentifier, authConfig, options);
```

### Step 4: Invoke the connector operation
Now, utilize the available connector operations.

#### Execute a DDL command
```ballerina
sql:ExecutionResult result = check snowflakeClient->execute(`CREATE TABLE COMPANY_DB.PUBLIC.EMPLOYEES (
        ID INT NOT NULL AUTOINCREMENT,
        FirstName VARCHAR(255),
        LastName VARCHAR(255),
        BusinessUnit VARCHAR(255),
        PRIMARY KEY (ID)
    )`);
```

#### Execute a DML command
```ballerina
sql:ExecutionResult result = check snowflakeClient->execute(`INSERT INTO COMPANY_DB.PUBLIC.EMPLOYEES (FirstName,
        LastName, BusinessUnit) VALUES ('Shawn', 'Jerome', 'Integration')`);
```

#### Execute a query
```ballerina
type Employee record {
    int id;
    string firstName;
    string lastName;
    string businessUnit;
};
...

stream<Employee, error?> resultStream = check snowflakeClient->query(`SELECT * FROM COMPANY_DB.PUBLIC.EMPLOYEES`);
```

#### Execute a query returning a single row
```ballerina
type Employee record {
    int id;
    string firstName;
    string lastName;
    string businessUnit;
};
...

Employee|error result = check snowflakeClient->queryRow(`SELECT * FROM COMPANY_DB.PUBLIC.EMPLOYEES WHERE ID = 1`);
```

#### Execute batch DML commands
```ballerina
sql:ExecutionResult[] result = check snowflakeClient->batchExecute([
    `INSERT INTO COMPANY_DB.PUBLIC.EMPLOYEES (FirstName, LastName, BusinessUnit) VALUES ('Shawn', 'Jerome', 'Integration')`,
    `INSERT INTO COMPANY_DB.PUBLIC.EMPLOYEES (FirstName, LastName, BusinessUnit) VALUES ('John', 'Doe', 'Integration')`
]);
```

#### Call a stored procedure
```ballerina
sql:ProcedureCallResult ret = check snowflakeClient->call(`{call PROCEDURES_DB.PUBLIC.SELECT_EMPLOYEE_DATA(1)}`, [Employee]);
stream<record {}, sql:Error?>? qResult = ret.queryResult;
```

### Examples

The following example shows how to use the Snowflake connector to create a table, insert data, and query data from the Snowflake database.

[Employees Data Management Example](https://github.com/ballerina-platform/module-ballerinax-snowflake/tree/master/examples/employees-db) - Manages employee data in a Snowflake database and exposes an HTTP service to interact with the database.
