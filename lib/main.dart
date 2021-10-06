import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluthereum',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Fluthereum'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client httpClient;
  Web3Client ethereumClient;
  TextEditingController controller = TextEditingController();

  String address = '0x26b9497F5E52FeacDf735d11656c9885eD483A2b';
  String ethereumClientUrl =
      'https://rinkeby.infura.io/v3/5494ea4b4d6f4fb1b61e611a5c78586b';
  String contractName = "Fluthereum";
  String private_key = "";

  int balance = 0;

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    List<dynamic> result = await ethereumClient.call(
        contract: contract, function: function, params: args);
    return result;
  }

  Future<String> transaction(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex(private_key);
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    dynamic result = await ethereumClient.sendTransaction(
      credential,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: args,
      ),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );

    return result;
  }

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xd55B64d9b7816f2e2D9be07CbC52303A77B7163b";

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  Future<void> getBalance() async {
    // EthereumAddress ethAddress = EthereumAddress.fromHex(address);
    List<dynamic> result = await query('balance', []);
    balance = int.parse(result[0].toString());
    print(balance.toString());
    setState(() {});
  }

  Future<void> deposit(int amount) async {
    BigInt parsedAmount = BigInt.from(amount);
    var result = await transaction("deposit", [parsedAmount]);
    print("deposited");
    print(result);
  }

  Future<void> withdraw(int amount) async {
    BigInt parsedAmount = BigInt.from(amount);
    var result = await transaction("withdraw", [parsedAmount]);
    print("withdraw done");
    print(result);
  }

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethereumClient = Web3Client(ethereumClientUrl, httpClient);
    getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Balance"),
            Text(balance.toString()),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(label: Text('amount')),
              ),
            ),
            TextButton(onPressed: getBalance, child: Text('Refresh')),
            TextButton(
                onPressed: () => deposit(int.parse(controller.text)),
                child: Text('Deposit')),
            TextButton(
                onPressed: () => withdraw(int.parse(controller.text)),
                child: Text('Withdraw'))
          ],
        ),
      ),
    );
  }
}
