#!/bin/zsh
# =============================== 🚀 Tensor Node Setup ===============================
# macOS Automated Validator Setup | Version 2025.02.06
# Steps: 1-7 Setup | 8-9 Node Config | 10 Validator (in background) | 11 Activation Command

# --- 1. 🍺 Homebrew Check ---
echo "\n🔍 Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
    echo "🛠️  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed"
fi

# --- 2. 🐍 Python 3.11 Setup ---
echo "\n🐍 Installing Python 3.11..."
brew update
brew install python@3.11
echo "🔍 Python version: $(python3.11 --version)"

# --- 3. 🔀 Git Check ---
echo "\n🔍 Checking Git..."
if ! command -v git >/dev/null 2>&1; then
    echo "🛠️  Installing Git..."
    brew install git
fi
echo "✅ Git version: $(git --version)"

# --- 4. 📂 Project Setup ---
echo "\n📁 Setting up project..."
mkdir -p ~/tensor && cd ~/tensor
if [ ! -d "dsn" ]; then
    echo "⏬ Cloning repository..."
    git clone https://github.com/hypertensor-blockchain/dsn.git
else
    echo "✅ Repository exists"
fi
cd dsn || { echo "❌ Failed entering dsn directory"; exit 1; }

# --- 5. 🐍 Virtual Environment ---
echo "\n🐍 Creating Python 3.11 virtual environment..."
python3.11 -m venv .venv
source .venv/bin/activate
echo "✅ Virtual Env: $(python --version)"

# --- 6. 🔧 Environment Config ---
echo "\n🔧 Configuring environment variables..."
RAND_PHRASE="//$(( RANDOM % 99 + 1 ))"
cat > .env <<EOL
PHRASE="$RAND_PHRASE"
LOCAL_RPC="ws://127.0.0.1:9944"
DEV_RPC="wss://rpc.hypertensor.org:443"
LIVE_RPC="wss://rpc.hypertensor.org:443"
EOL
echo "🔑 Using test phrase: $RAND_PHRASE"

# --- 7. 📦 Install Package ---
echo "\n📦 Installing Tensor package..."
python -m pip install . --no-cache-dir

# --- 8. 🔑 Key Generation ---
echo "\n🔑 Generating keypair..."
KEYGEN_OUTPUT=$(python -m subnet.cli.crypto.keygen 2>&1)
echo "$KEYGEN_OUTPUT"
PEER_ID=$(echo "$KEYGEN_OUTPUT" | grep "Peer ID" | awk '{print $NF}')

if [ -z "$PEER_ID" ]; then
    echo "❌ Peer ID extraction failed!"
    echo "🔍 Raw output:"
    echo "$KEYGEN_OUTPUT"
    exit 1
fi
echo "✅ Peer ID: $PEER_ID"

# --- 9. 📝 Node Registration ---
echo "\n📝 Registering node..."
python -m subnet.cli.hypertensor.subnet_node.register \
    --subnet_id 1 \
    --peer_id "$PEER_ID" \
    --stake_to_be_added 1000.00

# --- 10. 🖥️ Start Validator (Background) ---
echo "\n🖥️  Starting validator node..."
echo "💡 First run may take time to download models (5-15 mins)"
echo "🚨 Keep this terminal open!"

VALIDATOR_CMD="python -m subnet.cli.subnet.run_server_validator Orenguteng/Llama-3.1-8B-Lexi-Uncensored-V2 --public_ip 127.0.0.1 --port 33130 --identity_path private_key.key"
# Run validator in background and log its output to 'validator.log'
eval "$VALIDATOR_CMD" > validator.log 2>&1 &

# --- 11. Wait for 'Started' Indicator ---
echo "\n⏳ Waiting for validator to show 'Started' in the log..."
while true; do
    if grep -q "Started" validator.log; then
        echo "✅ Validator has started!"
        break
    fi
    sleep 5
done

# --- 12. Activation Command ---
ACTIVATION_CMD="cd $(pwd) && source .venv/bin/activate && python -m subnet.cli.hypertensor.subnet_node.activate --subnet_id 1"

echo "\n🌈 Validator is running. To activate the node, open a NEW Terminal tab and COPY–PASTE the command below:"
echo "--------------------------------------------------------------------------------"
echo "$ACTIVATION_CMD"
echo "--------------------------------------------------------------------------------"

echo "\n✅ Setup complete. Check dashboard: https://dash.hypertensor.org"
