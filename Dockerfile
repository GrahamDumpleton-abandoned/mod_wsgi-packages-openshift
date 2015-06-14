FROM centos:centos6

RUN curl -o epel-release-6-8.noarch.rpm \
    http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

RUN rpm -Uvh epel-release-6*.rpm

RUN yum -y install curl gcc file expat-devel pcre pcre-devel python-pip \
        python-virtualenv tar

WORKDIR /mod_wsgi-packages

RUN pip install zc.buildout boto
RUN pip install -U setuptools

RUN buildout init

COPY buildout.cfg /mod_wsgi-packages/

RUN buildout -v -v

ENV TARBALL mod_wsgi-packages-openshift-centos6-apache-2.4.12-1.tar.gz
ENV S3_BUCKET_NAME modwsgi.org

RUN tar cvfz $TARBALL apache apr-util apr

RUN ls -las $TARBALL

CMD s3put --access_key "$AWS_ACCESS_KEY_ID" \
          --secret_key "$AWS_SECRET_ACCESS_KEY" \
          --bucket "$S3_BUCKET_NAME" --prefix /mod_wsgi-packages/ $TARBALL
