import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // For connecting to an Ethereum client
import 'dart:convert'; // For JSON decoding


class Web3Service {
  final String _rpcUrl = 'https://api.avax-test.network/ext/bc/C/rpc'; // Avalanche Fuji Testnet RPC URL
  final String _privateKey = ''; // Replace with your private key for signing transactions
  final String _contractAddress = ''; // Address of your deployed MAT token contract

  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;
  late ContractFunction _balanceOf;
  late ContractFunction _decimals;

  bool _isContractLoaded = false;

  Web3Service() {
    _client = Web3Client(_rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  // Load the MAT token contract
  Future<void> loadContract() async {
    print('Loading contract...'); // Debug log
    if (_isContractLoaded) {
      print('Contract already loaded.');
      return;
    }
    try {
      final String abiString = await rootBundle.loadString('lib/assets/AssetToken.json');
      final abiJson = jsonDecode(abiString);
      final abi = abiJson is Map<String, dynamic> && abiJson.containsKey('abi') ? abiJson['abi'] : abiJson;

      _contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abi), 'AssetToken'),
        EthereumAddress.fromHex(_contractAddress),
      );
      _balanceOf = _contract.function('balanceOf');
      _decimals = _contract.function('decimals');
      _isContractLoaded = true;
      print('Contract loaded successfully.');
    } catch (e) {
      print('Error loading contract: $e');
      _isContractLoaded = false;
      throw Exception('Failed to load contract. Please check the ABI path and contract address.');
    }
  }


  // Deploy a new ERC20 token contract
  Future<void> deployToken(String name, String symbol, BigInt initialSupply) async {
    try {
      // Load the ABI and bytecode for the ERC20 contract
      final abiCode = await rootBundle.loadString('lib/assets/AssetToken.json');
      final jsonAbi = jsonDecode(abiCode);
      final abi = jsonAbi['abi'] as List<dynamic>;
      final bytecode = jsonAbi['bytecode'] as String;

      // Create a contract deployment transaction
      final contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abi), 'AssetToken'),
        EthereumAddress.fromHex('0x0000000000000000000000000000000000000000'),
      );

      final transaction = Transaction(
        from: _credentials.address,
        data: hexToBytes(bytecode),
        maxGas: 1000000,
        value: EtherAmount.zero(),
      );

      final deployFunction = contract.function('constructor');

      // Encode deployment data with user inputs
      final deployData = deployFunction.encodeCall([name, symbol, initialSupply]);

      // Send transaction to deploy the contract
      final txHash = await _client.sendTransaction(
        _credentials,
        transaction.copyWith(data: deployData),
        chainId: 43113, // Chain ID for Avalanche Fuji Testnet
      );

      print('Token deployment transaction sent: $txHash');
    } catch (e) {
      print('Error deploying token: $e');
      throw Exception('Failed to deploy token. Please check your inputs and try again.');
    }
  }

  // Fetch MAT token balance
  Future<BigInt> getMATBalance(String address) async {
    print('Fetching MAT balance for address: $address'); // Debug log
    if (!_isContractLoaded) {
      await loadContract();
    }

    try {
      final result = await _client.call(
        contract: _contract,
        function: _balanceOf,
        params: [EthereumAddress.fromHex(address)],
      );
      print('Fetched balance result: $result'); // Debug log
      return result.first as BigInt;
    } catch (e) {
      print('Error fetching MAT balance: $e');
      throw Exception('Failed to fetch MAT balance. Please try again.');
    }
  }

  // Fetch token decimals
  Future<int> getDecimals() async {
    print('Fetching token decimals...'); // Debug log
    if (!_isContractLoaded) {
      await loadContract();
    }

    try {
      final result = await _client.call(
        contract: _contract,
        function: _decimals,
        params: [],
      );
      print('Fetched decimals result: $result'); // Debug log
      final BigInt decimalsBigInt = result.first as BigInt;
      return decimalsBigInt.toInt();
    } catch (e) {
      print('Error fetching decimals: $e');
      throw Exception('Failed to fetch token decimals.');
    }
  }
}