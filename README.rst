====================
MOD_WSGI (OPENSHIFT)
====================

The ``mod_wsgi-packages-openshift`` package is a companion package for
Apache/mod_wsgi. It provides a means of building Apache binaries using
Docker which can be posted up to S3 and then pulled down when deploying
sites to OpenShift. This then permits the running of a custom installation
of Apache/mod_wsgi on OpenShift sites, overriding the default version which
is supplied with the OpenShift Python cartridges.

Building Apache/mod_wsgi
------------------------

Check out this repository from github and run within it::

    docker build -t mod_wsgi-packages-openshift .

This will create a Docker image with a prebuilt installation of Apache
within it.

Once built you need to upload that prebuilt Apache installation up to an
S3 bucket you control. To do that run::

    docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
               -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
               -e S3_BUCKET_NAME=YOUR-BUCKET-NAME \
               mod_wsgi-packages-openshift

This assumes you have your AWS access and secret key defined in environment
variables of the user you are running the command as.

You should also replace ``YOUR-BUCKET-NAME`` with the actual name of the S3
bucket you have and which you are going to use to hold the tar ball for the
prebuilt version of Apache.

Using prebuilt binaries
-----------------------

Although this package provides the means to build up the Apache binaries,
you don't actually need do this yourself. This is because when you install
the mod_wsgi package from PyPi it will automatically install a set of
prebuilt binaries to OpenShift for you automatically.

So if you are not concerned that you are installing binaries built by
someone else, simply install the mod_wsgi package from PyPi by listing the
``mod_wsgi`` package as a dependency in your ``setup.py`` file or in your
``requirements.txt`` file.

Using your own binaries
-----------------------

If wish to use this package to compile and host your own binaries, you will
need to configure the ``mod_wsgi`` package when installed to use your
versions.

To do that, if using the same name for the prebuilt binary tarball as the
``mod_wsgi`` package is expecting to find, all you need do is override the
name of the S3 bucket from which the binaries will be pulled. This is done
by setting an environment variable using the ``rhc set-env`` command.

For example, if the name of your OpenShift application is ``myapp`` and the
name of your S3 bucket is ``mybucket``, use::

    rhc set-env -a myapp MOD_WSGI_REMOTE_S3_BUCKET_NAME=mybucket

Once this is done you can then deploy your web application to OpenShift.

If you wanted to change the name of the tarball file, you can also set::

    rhc set-env -a myapp MOD_WSGI_REMOTE_PACKAGES_NAME=mypackages.tar.gz

Running mod_wsgi-express
------------------------

With the ``mod_wsgi`` package and the Apache binaries being installed, then
you only need to override the standard way that OpenShift starts up the web
server so that ``mod_wsgi-express`` is used.

To do that, create the file ``app.py`` containing::

    import os

    import mod_wsgi.server

    OPENSHIFT_DATA_DIR = os.environ['OPENSHIFT_DATA_DIR']
    OPENSHIFT_PYTHON_DIR = os.environ['OPENSHIFT_PYTHON_DIR']

    SERVER_ROOT = os.path.join(OPENSHIFT_PYTHON_DIR, 'run/mod_wsgi')

    HOST = os.environ['OPENSHIFT_PYTHON_IP']
    PORT = os.environ['OPENSHIFT_PYTHON_PORT']

    mod_wsgi.server.start('--server-root', SERVER_ROOT, '--log-to-terminal',
            '--host', HOST, '--port', PORT, 'wsgi.py')

where ``wsgi.py`` is the relative file system path to the WSGI script file
containing the WSGI application entry point.

For further details on other options for referring to a WSGI application
see the ``mod_wsgi-express`` documentation as all arguments passed to
``start()`` are passed directly to ``mod_wsgi-express``.
