#!/bin/bash

if [ $(id -u) -ne 0 ]; then
	printf "Script must be run as root. Try 'sudo ./backup_manage.sh'\n"
	exit 1
fi

script=$(readlink -f "$0")
local_path=$(dirname "$script")

source "$local_path/inc/functions.sh"

LoadEnv

pid_file="$local_path/script_tmp/backup_manage.pid"

if [ -e $pid_file ]; then
	echo "this task is already running"
	exit
fi

touch $pid_file

echo "======================================================"
echo
echo $(date '+%d-%b-%Y %H:%M:%S')": Begin Backup...."
echo

HOUR=$(date "+%k")

if (( $HOUR >= 2 && $HOUR <= 7 )); then
	echo "It's night time"
else
	CreateMySQLConfig

	if [ -f "$local_path/script_tmp/mysql-config.cnf" ]; then

		mysql_backup_dir="$BACKUP_DIR/$MYSQL_BACKUP_DIR/$(date +%Y)/$(date +%m)/$(date +%d)"
		mysql_backup_file_name="$MYSQL_DB_NAME-$(date +'%d-%b-%Y_%H-%M-%S')"

		#Create dir
		mkdir -p "$mysql_backup_dir"

		if [ "$COMPRESSION_BACKUP" == "Y" -o "$COMPRESSION_BACKUP" == "y" ] || [ "$ENCRYPTION_BACKUP" == "Y" -o "$ENCRYPTION_BACKUP" == "y" ]; then
			mysqldump "--defaults-extra-file=$local_path/script_tmp/mysql-config.cnf" $MYSQL_DB_NAME > "$TMP_DIR/$mysql_backup_file_name.sql"
			echo "File dumped to: $TMP_DIR/$mysql_backup_file_name.sql"
		else
			mysqldump "--defaults-extra-file=$local_path/script_tmp/mysql-config.cnf" $MYSQL_DB_NAME > "$mysql_backup_dir/$mysql_backup_file_name.sql"
			echo "File dumped to: $mysql_backup_dir/$mysql_backup_file_name.sql"
		fi

		if [ "$COMPRESSION_BACKUP" == "Y" -o "$COMPRESSION_BACKUP" == "y" ]; then
			if [ "$ENCRYPTION_BACKUP" == "Y" -o "$ENCRYPTION_BACKUP" == "y" ]; then
				tar -zcvf "$TMP_DIR/$mysql_backup_file_name.tar.gz" "$TMP_DIR/$mysql_backup_file_name.sql" --absolute-names &>/dev/null
				echo "File compressed to: $TMP_DIR/$mysql_backup_file_name.tar.gz"
			else
				tar -zcvf "$mysql_backup_dir/$mysql_backup_file_name.tar.gz" "$TMP_DIR/$mysql_backup_file_name.sql" --absolute-names &>/dev/null
				echo "File compressed to: $mysql_backup_dir/$mysql_backup_file_name.tar.gz"
			fi

			rm "$TMP_DIR/$mysql_backup_file_name.sql"
		fi

		if [ "$ENCRYPTION_BACKUP" == "Y" -o "$ENCRYPTION_BACKUP" == "y" ]; then
			if [ "$COMPRESSION_BACKUP" == "Y" -o "$COMPRESSION_BACKUP" == "y" ]; then
				gpg --yes --batch --passphrase=$ENCRYPTION_PASSPHRASE --output="$mysql_backup_dir/$mysql_backup_file_name.tar.gz.gpg" -c "$TMP_DIR/$mysql_backup_file_name.tar.gz"
				rm "$TMP_DIR/$mysql_backup_file_name.tar.gz"
			else
				gpg --yes --batch --passphrase=$ENCRYPTION_PASSPHRASE --output="$mysql_backup_dir/$mysql_backup_file_name.sql.gpg" -c "$TMP_DIR/$mysql_backup_file_name.sql"
				rm "$TMP_DIR/$mysql_backup_file_name.sql"
			fi

			echo "File encrypted to: $mysql_backup_dir/$mysql_backup_file_name.gpg"
		fi

	fi
fi

echo
echo $(date '+%d-%b-%Y %H:%M:%S')": End Backup...."
echo "======================================================"
echo

rm $pid_file
