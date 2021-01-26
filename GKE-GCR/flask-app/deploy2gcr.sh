docker build -t webapp .
docker tag webapp:latest eu.gcr.io/robotic-jet-301718/webapp
docker push eu.gcr.io/robotic-jet-301718/webapp