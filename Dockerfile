FROM adoptopenjdk:8-jdk-hotspot as builder

RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update \
    && apt-get -y install git maven python

ENV HOME /home/konduit
WORKDIR ${HOME}

ENV MAVEN_OPTS -Denforcer.skip=true
RUN mkdir ${HOME}/build \
    && cd ${HOME}/build \
    && git clone --single-branch --branch "sa/grafana_demo" https://github.com/KonduitAI/konduit-serving \
    && cd konduit-serving \
    && python build_jar.py --os linux-x86_64 \
    && cd ..

ADD . konduit-serving-metrics-demo

RUN cd ${HOME}/konduit-serving-metrics-demo \
    && mvn -Plinux clean install \
    && cp target/konduit-metrics-demo-1.0-SNAPSHOT.jar /srv/konduit-metrics-demo.jar \
    && cd ..

FROM adoptopenjdk:8-jdk-hotspot
WORKDIR /srv/
COPY --from=builder /srv/konduit-metrics-demo.jar .

EXPOSE 9008

CMD ["java","-cp","/srv/konduit-metrics-demo.jar","konduit.demo.metrics.App"]
