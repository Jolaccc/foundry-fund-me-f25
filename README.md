# Foundry Fund Me F23

## 📌 Overview
Welcome to the **Foundry Fund Me F23** project! This repository contains a smart contract project built using [Foundry](https://book.getfoundry.sh/) for deploying and managing funding campaigns on Ethereum.

## 📜 Table of Contents
- [Foundry Fund Me F23](#foundry-fund-me-f23)
  - [📌 Overview](#-overview)
  - [📜 Table of Contents](#-table-of-contents)
  - [🛠 Installation](#-installation)
  - [🚀 Usage](#-usage)
  - [📝 Project Structure](#-project-structure)
  - [🔬 Testing](#-testing)
  - [📄 License](#-license)

---

## 🛠 Installation
Ensure you have [Foundry](https://book.getfoundry.sh/getting-started/installation.html) installed.

```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Clone the repository:

```sh
git clone https://github.com/YOUR_GITHUB_USERNAME/foundry-fund-me-f23.git
cd foundry-fund-me-f23
```

Install dependencies:

```sh
forge install
```

---

## 🚀 Usage
Compile the contracts:

```sh
forge build
```

Deploy the contracts:

```sh
forge create --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> src/FundMe.sol:FundMe
```

---

## 📝 Project Structure
```plaintext
foundry-fund-me-f23/
│── src/            # Smart contracts
│── test/           # Test scripts
│── script/         # Deployment scripts
│── foundry.toml    # Foundry configuration
└── README.md       # This file
```

---

## 🔬 Testing
Run tests using Foundry:

```sh
forge test
```

To get more detailed logs:

```sh
forge test -vvv
```

---

## 📄 License
This project is licensed under the MIT License.

---

Made with ❤️ using Foundry
