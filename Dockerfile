FROM python:3.6

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
    telnet

RUN pip3 install pip --upgrade

RUN pip3 install ansible

RUN pip3 install netaddr

RUN pip3 install pexpect

RUN pip3 install gns3fy==0.8.0

RUN pip3 install pydantic==1.9.2

RUN pip3 install mazer
