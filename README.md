# Docker instances for composer projects


	$ docker run --name projectName -di -p 8080:80 docker-composer-project
	$ docker exec -i projectName -c "cd /var/www/html && git clone https://github.com/sdiaz/FOSRestBundleByExample.git && cd FOSRestBundleByExample && composer install"

These two commands have been added to the executable file add-server which
	 1. Asks the git repository url to clone
	 2. Find an available port to run the application
	 3. Creates the docker container
	 4. Configures the container (clone the repository, check into and launch composer install)

## Installation / Usage


	$ git clone git@github.com:JeanBaptisteWATENBERG/docker-composer-project.git
	$ docker build -t docker-composer-project
	$ cd docker-composer-project
	$ sudo chmod +x add-server.sh
	$ sudo chmod +x add-server-zip-file.sh

If you want to start from a git repository :

	$ ./add-server.sh

Or mount a zip file containing sources :
	
	$ ./add-server-zip-file.sh
	
