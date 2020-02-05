#!/bin/bash
#set -e -x

# CLI arguments
PY_VERSIONS=$1
BUILD_REQUIREMENTS=$2
PRE_BUILD=$3

if [ ! -z "$PRE_BUILD" ]; then
    eval "${PRE_BUILD}"  || { echo "Evaluating pre-build script failed."; exit 1; }
fi

# Compile wheels
arrPY_VERSIONS=(${PY_VERSIONS// / })
for PY_VER in "${arrPY_VERSIONS[@]}"; do
    # Update pip
    /opt/python/${PY_VER}/bin/pip install --upgrade pip

    # Check if requirements were passed
    if [ ! -z "$BUILD_REQUIREMENTS" ]; then
        /opt/python/${PY_VER}/bin/pip install ${BUILD_REQUIREMENTS} || { echo "Installing requirements failed."; exit 1; }
    fi
    
    # Build wheels
    /opt/python/${PY_VER}/bin/pip wheel /github/workspace/ -w /github/workspace/wheelhouse/ || { echo "Building wheels failed."; exit 1; }
done

# Bundle external shared libraries into the wheels
for whl in /github/workspace/wheelhouse/*.whl; do
    auditwheel repair "$whl" --plat manylinux1_x86_64 -w /github/workspace/wheelhouse/
done

echo "Succesfully build wheels:"
ls /github/workspace/wheelhouse
