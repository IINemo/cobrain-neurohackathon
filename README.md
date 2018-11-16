# Cobrain-neurohachathon container.

Dockerized version of Jupyter with installed Keras, TensorFlow, PyTorch, Sklearn, Gensim, Pandas, XGBosot, LightGBM, etc.

## Run

### It's better to use nvidia-docker

First, install nvidia-docker: https://github.com/NVIDIA/nvidia-docker

Then, run the container:

    nvidia-docker run -ti --rm \
        -v `pwd`:/notebook \
        -p 8888:8888 \
        inemo/cobrain-neurohackathon

Or, with full options and authentication (for copy-paste convenience :)):

    nvidia-docker run -ti --rm \
        -e "HASHED_PASSWORD=$YOUR_HASHED_PASSWORD" \
        -e "SSL=1" \
        -v /folder/with/your/certs:/jupyter/certs \
        -v `pwd`:/notebook \
        -p 8888:8888 \
        inemo/cobrain-neurohackathon

You may want to add something like **--shm-size=1024m** to the commands above, because sklearn.grid_search.GridSearchCV may fail if you train large models.


### Without nvidia-docker (may or may not work)

This by default enables all the devices.

    docker run -ti --rm \
        $(for d in /dev/nvidia* ; do echo -n "--device=$d " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcuda.* ; do echo -n "-v $f:$f " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcudnn.* ; do echo -n "-v $f:$f " ; done) \
        -v `pwd`:/notebook \
        -p 8888:8888 \
        inemo/cobrain-neurohackathon

After that, jupyter notebook will be available at http://<hostname>:8888/.

Or, with full options and authentication (for copy-paste convenience :)):

    docker run -ti --rm \
        $(for d in /dev/nvidia* ; do echo -n "--device=$d " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcuda.* ; do echo -n "-v $f:$f " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcudnn.* ; do echo -n "-v $f:$f " ; done) \
        -e "HASHED_PASSWORD=$YOUR_HASHED_PASSWORD" \
        -e "SSL=1" \
        -v /folder/with/your/certs:/jupyter/certs \
        -v `pwd`:/notebook \
        -p 8888:8888 \
        inemo/cobrain-neurohackathon

## Test

### TensorFlow

    nvidia-docker run -ti --rm \
        cobrain-neurohackathon \
        /test_scripts/test_tensorflow.py


## Build from Scratch

    git clone https://github.com/iinemo/cobrain-neurohackathon.git
    cd cobrain-neurohackathon
    docker build -t inemo/cobrain-neurohackathon .


## Authentication

You may want to run this container on a server which is accessible via Internet. To protect it, you'd better provide a password and SSL certificate and key.

### 1. Create certificates

Use openssl to generate a self-signed certificate. If you always forget how to do this (like I do), you can use a simple utility: https://github.com/windj007/ssl-utils


### 2. Make a hashed password

Jupyter does not store plain password. It uses a hashed version instead. To make a hashed version of you password, please run:

    $ docker run -ti --rm inemo/cobrain-neurohackathon /hashpwd.py
    Enter password: 
    Verify password: 
    <your hashed password>
    $ YOUR_HASHED_PASSWORD="<your hashed password>" # save it to a variable for convenience

### 3. Run the container

You have to pass the hashed password and tell jupyter to enable SSL and mount a volume with your cert and key. A sample command to run protected notebook (cuda-related options ommitted for conciseness):

    docker run -ti --rm \
        -e "HASHED_PASSWORD=$YOUR_HASHED_PASSWORD" \
        -e "SSL=1" \
        -v /folder/with/your/certs:/jupyter/certs \
        inemo/cobrain-neurohackathon

After that, you will have to access Jupyter with explicit https:// in address (Jupyter does not have automatic redirect, AFAIK, maybe I'm wrong).
