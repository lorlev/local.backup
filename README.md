# local.backup
Linux local backup script

## Backup User
```shell
useradd backup.manager -d /datastore/local.backup
passwd backup.manager
chown backup.manager:backup.manager mysql
chown backup.manager:backup.manager web
mkdir /datastore/local.backup/.ssh
chown backup.manager:backup.manager .ssh
```

## Unachive
```shell
tar -xvf db_name-2020-06-11_01-11-34.sql.gz
```

## Encryption Usage
### Encrypt file
```shell
gpg --yes --batch --passphrase=pass -c db_name-11-Jun-2020_23-19-03.sql
```

### Decrypt file
```shell
gpg db_name-11-Jun-2020_23-19-03.sql
```

## Crontab
```shell
0 */2 * * *    sh /datastore/local.backup/cron/backup_manage.sh >> "/datastore/local.backup/cron/logs/backup_$(date +\%d-\%b-\%Y).log"

#Tmp watch
*/60 * * * *    /usr/sbin/tmpwatch -mc 14d /datastore/local.backup/mysql
*/60 * * * *    /usr/sbin/tmpwatch -mc 14d /datastore/local.backup/cron/logs
```

## Install mysqldump
Visit and find lates version of "Red Hat Enterprise Linux 7 / Oracle Linux 7 (Architecture Independent), RPM Package" rpm
https://dev.mysql.com/downloads/repo/yum/

### Download rpm
```shell
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
```

### Install rpm
```shell
rpm -ivh mysql80-community-release-el7-3.noarch.rpm
```

### Install server
```shell
yum install mysql -y
```
