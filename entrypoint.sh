#!/bin/bash
#set -e -x

if [ ! -z "$INPUT_PRE_BUILD" ]; then
    eval "${INPUT_PRE_BUILD}"  || { echo "Evaluating pre-build script failed."; exit 1; }
fi

# Compile wheels
arrPY_VERSIONS=(${INPUT_PYTHON_VERSIONS// / })
for PY_VER in "${arrPY_VERSIONS[@]}"; do
    echo "Now processing $PY_VER..."

    # Update pip
    /opt/python/${PY_VER}/bin/pip install --upgrade pip

    # Check if requirements were passed
    if [ ! -z "$BUILD_REQUIREMENTS" ]; then
        /opt/python/${PY_VER}/bin/pip install "${INPUT_BUILD_REQUIREMENTS}" || { echo "Installing requirements failed."; exit 1; }
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
