#!/bin/bash
# Start JupyterLab with GPU conda environment

ENV_PATH="/opt/miniforge3/envs/PureComputePython313GPU"
export PATH="$ENV_PATH/bin:$PATH"
export CUDA_PATH="$ENV_PATH"
export SSL_CERT_FILE="$ENV_PATH/lib/python3.13/site-packages/certifi/cacert.pem"
export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"

# Fix CuPy CUDA headers if symlinks are missing
if [ ! -f "$ENV_PATH/include/cuda_fp16.h" ]; then
    sudo ln -sf "$ENV_PATH/targets/x86_64-linux/include/"* "$ENV_PATH/include/" 2>/dev/null
fi

# Open firewall port 8888 (resets on reboot)
if ! sudo iptables -L INPUT -n | grep -q "dpt:8888"; then
    MY_IP=$(ss -tnp | grep ":22" | grep ESTAB | head -1 | awk '{print $5}' | cut -d: -f1)
    if [ -n "$MY_IP" ]; then
        sudo iptables -A INPUT -p tcp -s "$MY_IP" --dport 8888 -j ACCEPT
        echo "Firewall: opened port 8888 for $MY_IP"
    else
        sudo iptables -A INPUT -p tcp --dport 8888 -j ACCEPT
        echo "Firewall: opened port 8888 for all (couldn't detect client IP)"
    fi
fi

cd /home/azureuser/nvidia

echo "Starting JupyterLab..."
echo "Access at: http://$(curl -s ifconfig.me):8888/lab"
echo ""

jupyter lab --no-browser --ip=0.0.0.0 --port=8888 \
    --ServerApp.token='' --ServerApp.password=''
