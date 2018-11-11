FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04


RUN apt-get clean && apt-get update

RUN apt-get install -yqq curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq build-essential libbz2-dev libssl-dev libreadline-dev \
                         libsqlite3-dev libffi-dev tk-dev libpng-dev libfreetype6-dev git \
                         cmake wget gfortran libatlas-base-dev libatlas-base-dev  \
                         libatlas3-base libhdf5-dev libxml2-dev libxslt-dev \
                         zlib1g-dev pkg-config graphviz liblapacke-dev \
                         locales nodejs

RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pyenv install 3.6.7
RUN pyenv global 3.6.7

RUN pip install -U pip
RUN python -m pip install -U cython
RUN python -m pip install -U numpy
RUN python -m pip install -U scipy pandas gensim sklearn tensorflow-gpu
RUN python -m pip install -U http://download.pytorch.org/whl/cu90/torch-0.3.1-cp36-cp36m-linux_x86_64.whl torchvision
RUN python -m pip install -U joblib tqdm pydot imbalanced-learn
RUN python -m pip install -U xgboost
RUN python -m pip install -U matplotlib plotly graphviz tensorboardX seaborn
RUN python -m pip install -U jupyter jupyterlab jupyter_nbextensions_configurator jupyter_contrib_nbextensions

RUN pyenv rehash

RUN jupyter nbextensions_configurator enable --system && \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN git clone --recursive https://github.com/Microsoft/LightGBM /tmp/lgbm && \
    cd /tmp/lgbm && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cd ../python-package && \
    python setup.py install && \
    cd /tmp && \
    rm -r /tmp/lgbm

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        dpkg-reconfigure --frontend=noninteractive locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

EXPOSE 8888
VOLUME ["/notebook", "/jupyter/certs"]
WORKDIR /notebook

ADD test_scripts /test_scripts
ADD jupyter /jupyter
COPY entrypoint.sh /entrypoint.sh
COPY hashpwd.py /hashpwd.py

ENV JUPYTER_CONFIG_DIR="/jupyter"

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "jupyter", "notebook", "--ip=0.0.0.0", "--allow-root" ]
