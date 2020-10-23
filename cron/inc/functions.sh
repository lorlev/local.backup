#!/bin/sh

LoadEnv(){
	# Check .env file exist
	if [ ! -f "$local_path/.env" ]; then
		cp "$local_path/.env.example" "$local_path/.env"
		echo "$(tput setaf 1) .env file was moved from the example file! $(tput sgr 0)"
		echo "$(tput setaf 1) Don't forget to configure the .env file! $(tput sgr 0)"
	fi

	if [ ! -d "$local_path/script_tmp" ]; then
		mkdir "$local_path/script_tmp"
	fi

	## Clear spaces, tabs, empty lines & comments in config file
	sed "s/ *= */=/g; s/	//g; s/[#].*$//; /^$/d;" "$local_path/.env" > "$local_path/script_tmp/.build_env"

	# Check script_tmp .env file exist
	if [ ! -f "$local_path/script_tmp/.build_env" ]; then
		echo ".build_env file not found!"
		exit
	fi

	source "$local_path/script_tmp/.build_env"
}

CreateMySQLConfig(){
	printf "[client]\nuser = $MYSQL_USER_NAME\npassword = $MYSQL_PASSWORD\nhost = $MYSQL_HOST\n" > "$local_path/script_tmp/mysql-config.cnf"
}