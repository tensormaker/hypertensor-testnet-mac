# Tensor Node Setup Script

This repository contains an automated setup script for deploying a Tensor Node validator on macOS. The script streamlines the process by:

- Checking for and installing prerequisites (Homebrew, Python 3.11, Git)
- Cloning the necessary repository
- Setting up a Python virtual environment
- Configuring environment variables with a random test phrase
- Installing the Tensor package
- Generating a validator keypair and registering your node
- Starting the validator node in the background and waiting until it is fully started
- Displaying an activation command that you can copy–paste into a new Terminal tab

## Features

- **Automated Prerequisite Installation:** Installs Homebrew (if missing), Python 3.11, and Git.
- **Project Setup:** Clones the Hypertensor `dsn` repository and sets up a virtual environment.
- **Node Configuration:** Generates a keypair, extracts the Peer ID, and registers your node.
- **Background Validator Startup:** Runs the validator node in the background and monitors its log for the "Started" indicator.
- **Easy Activation:** Once the validator is live, the script displays the activation command for you to run in a new terminal tab.

## Prerequisites

- **Operating System:** macOS (tested on recent versions)
- **Shell:** zsh (recommended)
- **Internet Connection:** Required for cloning repositories and installing packages

## Installation and Usage

1. **Clone this Repository:**

   ```bash
   git clone https://github.com/tensormaker/hypertensor-testnet-mac.git
   cd yourrepo
