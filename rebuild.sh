export PATH=$PATH:/mnt/bin/
git pull && \
	cd dss.web && git pull && cd .. && \
	cd dss.api && git pull && cd .. && \
	cd dss.radio && git radio && cd .. && \
	docker-compose build && docker-compose up $1
