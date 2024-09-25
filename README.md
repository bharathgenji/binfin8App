# **Asset Management and Tokenization Platform**

A Flutter-based asset management platform leveraging blockchain technology for secure and efficient asset management, token creation, and user interaction through an integrated chatbot. The application is built using Flutter and connects with the Avalanche Fuji Testnet for smart contract deployment and asset tokenization.

## **Features**

- **User Authentication and Onboarding**
  - Secure login using email/password authentication via Firebase.
  - Biometric authentication (fingerprint or face recognition) for enhanced security.

- **Asset Dashboard**
  - Displays user's asset information fetched from the Avalanche Fuji Testnet.
  - Real-time updates on MAT token balances with accurate decimal formatting.
  - Easy-to-use interface with a chatbot button for seamless user interaction.

- **Tokenization and Smart Contract Integration**
  - Create and manage tokens directly from the app using deployed smart contracts on Avalanche Fuji Testnet.
  - User-friendly input validation for asset name, symbol, and initial supply during token creation.
  - Backend smart contract deployments handled through Truffle, with dynamic generation of ABI files.

- **Chatbot Integration**
  - Integrated chatbot using Hugging Face and Anthropic Claude for personalized asset-related interactions.
  - The chatbot assists users in managing their portfolio and answers queries based on the user’s asset profile.

- **Voice Command Feature (Partially Implemented)**
  - Initial development started to allow voice command navigation.
  - Encountered challenges with device permissions and recognition initialization, leading to deprioritization.

## **Screenshots**

![Asset Dashboard](path_to_screenshot_dashboard.png)  
![Token Creation](path_to_screenshot_token_creation.png)  
![Chatbot Interaction](path_to_screenshot_chatbot.png)

## **Technologies Used**

- **Flutter:** For building cross-platform mobile and web applications.
- **Firebase Authentication:** Secure user authentication via email and password.
- **Avalanche Fuji Testnet:** Blockchain network for deploying and interacting with smart contracts.
- **Truffle:** Development framework for deploying smart contracts.
- **Hugging Face & Anthropic Claude:** AI-powered chatbot integrations for enhanced user interaction.

## **Getting Started**

### **Prerequisites**

- **Flutter SDK**: Version 3.24.3 or later
- **Node.js**: Version 20.16.0 or later
- **Truffle**: Version 5.11.5 or later
- **MetaMask**: For interacting with the Avalanche Fuji Testnet

### **Installation**

1. **Clone the Repository**
    ```bash
    git clone https://github.com/your_username/asset-token-app.git
    cd asset-token-app
    ```

2. **Install Dependencies**
    ```bash
    flutter pub get
    npm install -g truffle
    ```

3. **Set Up Environment Variables**
   - Create a `.env` file in the root directory.
   - Add the following environment variables:
     ```plaintext
     PRIVATE_KEY=<your_private_key>
     RPC_URL=<your_avalanche_fuji_testnet_rpc_url>
     INFURA_API_KEY=<your_infura_api_key>
     ```
   - For Firebase configuration, update the relevant API keys in `firebase_options.dart`.

4. **Deploy Smart Contracts**
    - Ensure your MetaMask is connected to the Avalanche Fuji Testnet.
    - Compile and deploy contracts using Truffle:
      ```bash
      truffle compile
      truffle migrate --network fuji
      ```

5. **Run the Application**
    ```bash
    flutter run
    ```

## **Usage**

- **Login:** Start by logging in or signing up with your email and password.
- **Onboarding:** Complete biometric authentication to access the asset dashboard.
- **Asset Dashboard:** View your assets, including token balances fetched from the blockchain.
- **Token Creation:** Create new tokens using smart contracts directly from the app.
- **Chatbot:** Click the floating chatbot icon for personalized guidance on managing your assets.

## **Project Structure**

- **/lib**: Contains all Flutter source code.
  - **/screens**: Flutter screens (e.g., AssetDashboardScreen, ChatbotScreen).
  - **/services**: Contains business logic and services for interacting with web3 and APIs.
  - **/models**: Data models for handling API and blockchain responses.
- **/contracts**: Smart contracts written in Solidity.
- **/assets**: Contains images, ABI files, and other static resources.

## **Contributing**

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.


## **Future Enhancements**

- Complete the voice command integration for a fully hands-free experience.
- Implement a more sophisticated chatbot with fine-tuned models for advanced asset suggestions.
- Add support for multi-chain asset management.
