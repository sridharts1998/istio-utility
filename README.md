# Istio Bootstrap with Bookinfo App

This repository provides a ready-to-use script to install Istio using Helm and deploy the popular **Bookinfo** sample application for hands-on Istio traffic management practice.

It is especially useful in **vanilla Kubernetes clusters** or **time-limited lab environments** , where fast and repeatable setup is essential. The script automates installation of the Istio control plane, ingress gateway, and a demo application, making it ideal for experimentation with features like traffic shifting, fault injection, circuit breaking, and observability.

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
