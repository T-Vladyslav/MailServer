# MySQL, Opendkim, Policyd for Mail Server
This project was created and tested for working with a mail server based on Postfix.

- OpenDKIM is used to implement DomainKeys Identified Mail (DKIM) for email, which allows you to sign your messages with a digital signature so that recipients can verify their authenticity.
- Policyd is used for managing and controlling mail servers, providing capabilities for filtering, rate limiting, spam prevention, and other email processing policies
- MySQL is used for centralized storage of OpenDKIM key information and for centralized storage of policies for Policyd

## Features

- Creating policies for mailboxes
- DKIM signing and verification
- Key and policies storage in database

## First steps

In this example, the MySQL Docker container connects to existing databases with pre-created users and does not require any additional configuration. If you do not have pre-created databases, you will need to create them and make changes to the docker-compose file to create the root user according to the official MySQL container [documentation](https://hub.docker.com/_/mysql).

You should also create a file with variables named .env in the root of the project, where you will need to fill in the values for the following variables:

| **Variable** | **Description** | **For Example** |
|------------|---------------|-----------------|
| `OPENDKIM_DB_SERVER` | The hostname or IP address of the database server. | `127.0.0.1` |
| `OPENDKIM_DB_NAME` | The name of the opendkim database.  | `opendkim` |
| `OPENDKIM_DB_USER` | The name of the database user. **Attention!** You shall not use an administrator account. | `opendkim` |
| `OPENDKIM_DB_PASS` | The password of the database user | `STRONGPASS` |
| `POLICYD_DB_SERVER` | The hostname or IP address of the database server. | `127.0.0.1` |
| `POLICYD_DB_NAME` | The name of the opendkim database.  | `opendkim` |
| `POLICYD_DB_USER` | The name of the database user. **Attention!** You shall not use an administrator account. | `opendkim` |
| `POLICYD_DB_PASS` | The password of the database user | `STRONGPASS` |

Here's an example of what the contents of your .env file might look like:
POLICYD_DB_SERVER=127.0.0.1
POLICYD_DB_NAME=policyd
POLICYD_DB_USER=policyd
POLICYD_DB_PASS=STRONGPASS

OPENDKIM_DB_SERVER=127.0.0.1
OPENDKIM_DB_NAME=opendkim
OPENDKIM_DB_USER=opendkim
OPENDKIM_DB_PASS=STRONGPASS

### OpenDKIM
Creating a database and user for OpenDKIM
```sh
mysql -h $mysql_host_addr -u root -p
CREATE DATABASE opendkim;
CREATE USER 'opendkim'@'any' IDENTIFIED BY '$your_password';
GRANT ALL PRIVILEGES ON opendkim.* TO 'opendkim'@'any';
FLUSH PRIVILEGES;
EXIT;
```
Prepare the MySQL template file (e.g., 'src/opendkim_tables.sql'):
```sh
mysql -u root -p opendkim_db < path/to/opendkim_tables.sql
```

Once you have started your OpenDKIM container successfully, it is now time to create your DKIM signing keys for each domain. This is what you need to do:

1. Login to the container by executing `/bin/bash` interactively on the container.
1. For each of your domains `DOMAIN` perform the following steps:
    - Create a temporary directory: `mkdir /etc/opendkim/keys/$DOMAIN`
    - Create the actual key: `opendkim-genkey -b 2048 -d $DOMAIN -D /etc/opendkim/keys/$DOMAIN -s default -v`. You will find public and private key in the temporary directory.
    - Insert public and private key into your database by signing in: `mysql -u opendkim -p opendkim` and enter your database password. Then enter these SQL statement and hit enter for each of them:

        ```
        INSERT INTO `dkim_keys` (`domain_name`, `selector`, `private_key`, `public_key`) VALUES ('$DOMAIN', 'default', '-----BEGIN RSA PRIVATE KEY-----\r\n***$YOUR_PRIVATE_KEY*** \r\n-----END RSA PRIVATE KEY-----', '-----BEGIN RSA PUBLIC KEY-----\r\n***$YOUR_PUBLIC_KEY***-----END RSA PUBLIC KEY-----');`
        SELECT `id` FROM `dkim_keys` WHERE `domain_name` = '$DOMAIN'; 
        INSERT INTO `dkim_signing` (`author`, `dkim_id`) VALUES ('$DOMAIN', $KEYID_FROM_SELECT);
        INSERT INTO `ignore_list` (`hostname`) VALUES ('*@$DOMAIN');
        INSERT INTO `internal_hosts` (`hostname`) VALUES ('*@$DOMAIN');
        ```

    4. Insert the *Public Key* as described by step 2 output into your DNS TXT record for the domain. It can look like this:

        ```
        v=DKIM1; h=sha256; k=rsa; p=***PUBLIC_KEY_WITHOUT_SPACE_OR_NEWLINE***
        ```

       The TXT record needs to be named `default._domainkey.$DOMAIN` - the `default` can be varied when using a different value in SQL statement in step 3. This would enable
       you to use different keys e.g. for subdomains and individual mail addresses. You would need to change the SQL commands accordingly (Table `dkim_keys` decides
       which key will be used. You can use full mail addresses in column `author` then.)

### Policyd
To create the database, you should follow the "Set up your database" section of the [official documentation](https://wiki.policyd.org/installing).

## Launch and Management

First run use:
```sh
docker-compose up
```

To stop and remove all containers:
```sh
docker-compose down
```

To stop all containers without removing them:
```sh
docker-compose stop
```

To start all containers:
```sh
docker-compose start
```

If you made changes to the docker-compose file, use:
```sh
docker-compose up --build
```