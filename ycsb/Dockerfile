FROM debian:bookworm

WORKDIR /app

# Install Amazon Corretto JDK 8 and other dependencies
RUN apt-get update && apt-get install -y gpg wget curl && \
    wget -O - https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | tee /etc/apt/sources.list.d/corretto.list && \
    apt-get update && \
    apt-get install -y java-1.8.0-amazon-corretto-jdk python3.11 python3-pip

RUN curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz
RUN tar xfvz ycsb-0.17.0.tar.gz
RUN rm ycsb-0.17.0.tar.gz

COPY . .

RUN ln -s /usr/bin/python3 /usr/bin/python

ENTRYPOINT ["/bin/bash", "./run_ycsb.sh"]
CMD ["postgres", "workloada"]
