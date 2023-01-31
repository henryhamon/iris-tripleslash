ARG IMAGE=intersystemsdc/irishealth-community
ARG IMAGE=intersystemsdc/iris-community
ARG IMAGE=intersystemsdc/iris-community:preview
FROM $IMAGE

WORKDIR /irisrun/repo

ARG TESTS=0
ARG MODULE="iris-beaker"
ARG NAMESPACE="IRISAPP"

# create Python env
ENV PYTHON_PATH=/usr/irissys/bin/irispython
ENV SRC_PATH=/irisrun/repo
ENV IRISUSERNAME "SuperUser"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE $NAMESPACE

## Start IRIS

RUN --mount=type=bind,src=.,dst=. \
    pip3 install -r requirements.txt && \
    iris start IRIS && \
	iris session IRIS < iris.script && \
    ([ $TESTS -eq 0 ] || iris session iris -U $NAMESPACE "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1,1)") && \
    iris stop IRIS quietly

WORKDIR /home/irisowner/irisdev