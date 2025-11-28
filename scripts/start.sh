#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

# Start jupyter lab
start_jupyter() {
    if [[ $JUPYTER_PASSWORD ]]; then
        echo "Starting Jupyter Lab..."
        mkdir -p /workspace && \
        cd /workspace && \
        nohup jupyter lab --allow-root --no-browser --port=8888 --ip=* --FileContentsManager.delete_to_trash=False --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace &> /jupyter.log &
        echo "Jupyter Lab started"
    fi
}

start_jupyter

echo "Start script(s) finished, pod is ready to use."

sleep infinity