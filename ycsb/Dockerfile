FROM debian:bookworm

WORKDIR /app

RUN apt-get update && apt-get install -y gpg wget curl python3.11 python3-pip java-common

RUN wget https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.deb && \
    dpkg -i amazon-corretto-8-x64-linux-jdk.deb


RUN curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz
RUN tar xfvz ycsb-0.17.0.tar.gz
RUN rm ycsb-0.17.0.tar.gz

COPY . .

RUN ln -s /usr/bin/python3 /usr/bin/python

ENTRYPOINT ["/bin/bash", "./run_ycsb.sh"]
# CMD database, ip_address, workload, threads
CMD ["postgres", "localhost", "workloada", "4"]
