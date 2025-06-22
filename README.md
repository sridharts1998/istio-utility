# Istio Bootstrap with Bookinfo App

This repo contains a ready-to-use script to install Istio using Helm and deploy the popular **Bookinfo** sample application for Istio traffic management practice.

## Features

- Installs Istio (base, control plane, ingress gateway) using Helm
- Sets up istioctl command-line tool
- Deploys the Bookinfo demo app
- Configures gateway and routing
- Enables access logs via a custom Telemetry resource

## How to Use

1. Clone this repo into your CloudAcademy or test environment.
2. Run the script:
   ```bash
   chmod +x istio-setup.sh
   ./istio-setup.sh
