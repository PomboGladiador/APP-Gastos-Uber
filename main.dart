// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Gastos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NameScreen(),
    );
  }
}

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  _NameScreenState createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController nameController = TextEditingController();

  Future<void> _saveName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', nameController.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CarSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insira seu Nome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveName,
              child: const Text('Salvar Nome'),
            ),
          ],
        ),
      ),
    );
  }
}

class CarSelectionScreen extends StatelessWidget {
  const CarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione o Tipo de Carro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarroAlugadoScreen()),
                );
              },
              child: const Text('Carro Alugado'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarroQuitadoScreen()),
                );
              },
              child: const Text('Carro Quitado'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CarroFinanciadoScreen()),
                );
              },
              child: const Text('Carro em Financiamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class CarroAlugadoScreen extends StatelessWidget {
  const CarroAlugadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carro Alugado'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: CarroAlugadoForm(),
      ),
    );
  }
}

class CarroAlugadoForm extends StatefulWidget {
  const CarroAlugadoForm({super.key});

  @override
  _CarroAlugadoFormState createState() => _CarroAlugadoFormState();
}

class _CarroAlugadoFormState extends State<CarroAlugadoForm> {
  final TextEditingController kmController = TextEditingController();
  final TextEditingController gasolinaController = TextEditingController();
  final TextEditingController litrosController = TextEditingController();
  final TextEditingController diariaController = TextEditingController();

  Future<void> calcularGasto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String nome = prefs.getString('userName') ?? '';
    final double km = double.tryParse(formatInput(kmController.text)) ?? 0.0;
    final double custoGasolina = double.tryParse(formatInput(gasolinaController.text)) ?? 0.0;
    final double litros = double.tryParse(formatInput(litrosController.text)) ?? 0.0;
    final double diaria = double.tryParse(formatInput(diariaController.text)) ?? 0.0;

    if (km > 0 && custoGasolina > 0 && litros > 0 && diaria > 0) {
      final double autonomia = km / litros;
      final double custoPorKm = custoGasolina / autonomia;
      final double resultado = km * custoPorKm;
      final double custoTotalDiario = resultado + diaria;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resultados'),
          content: Text(
            'Olá, $nome!\n\n'
            'Seu gasto total é: R\$ ${resultado.toStringAsFixed(2)}\n'
            'Autonomia do veículo: ${autonomia.toStringAsFixed(2)} km/L\n'
            'Custo por quilômetro: R\$ ${custoPorKm.toStringAsFixed(2)}\n'
            'Custo Total por Dia: R\$ ${custoTotalDiario.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Por favor, insira valores válidos para todos os campos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String formatInput(String input) {
    return input.replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: kmController,
            decoration: const InputDecoration(labelText: 'Quilômetros Rodados (use vírgula para decimais)'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: gasolinaController,
            decoration: const InputDecoration(
              labelText: 'Custo da Gasolina',
              prefixText: 'R\$ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: litrosController,
            decoration: const InputDecoration(labelText: 'Litros de Gasolina'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: diariaController,
            decoration: const InputDecoration(
              labelText: 'Valor da Diária do Carro',
              prefixText: 'R\$ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: calcularGasto,
              child: const Text('Calcular Gasto'),
            ),
          ),
        ],
      ),
    );
  }
}

class CarroQuitadoScreen extends StatelessWidget {
  const CarroQuitadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carro Quitado'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: CarroQuitadoForm(),
      ),
    );
  }
}

class CarroQuitadoForm extends StatefulWidget {
  const CarroQuitadoForm({super.key});
  @override
  _CarroQuitadoFormState createState() => _CarroQuitadoFormState();
}

class _CarroQuitadoFormState extends State<CarroQuitadoForm> {
  final TextEditingController kmController = TextEditingController();
  final TextEditingController gasolinaController = TextEditingController();
  final TextEditingController litrosController = TextEditingController();
  final TextEditingController seguroController = TextEditingController();
  final TextEditingController valorVeiculoController = TextEditingController();


  Future<void> calcularGasto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String nome = prefs.getString('userName') ?? '';
    final double km = double.tryParse(formatInput(kmController.text)) ?? 0.0;
    final double custoGasolina = double.tryParse(formatInput(gasolinaController.text)) ?? 0.0;
    final double litros = double.tryParse(formatInput(litrosController.text)) ?? 0.0;
    final double seguro = double.tryParse(formatInput(seguroController.text)) ?? 0.0;
    final double valorVeiculo = double.tryParse(formatInput(valorVeiculoController.text)) ?? 0.0;

    if (km > 0 && custoGasolina > 0 && litros > 0 && seguro > 0 && valorVeiculo > 0) {
      final double autonomia = km / litros;
      final double custoPorKm = custoGasolina / autonomia;
      final double custoDepreciacaoPorKm = valorVeiculo / 100000;  // Exemplo de cálculo de depreciação por km
      final double resultado = km * (custoPorKm + custoDepreciacaoPorKm + (seguro / 365));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resultados'),
          content: Text(
            'Olá, $nome!\n\n'
            'Seu gasto total é: R\$ ${resultado.toStringAsFixed(2)}\n'
            'Autonomia do veículo: ${autonomia.toStringAsFixed(2)} km/L\n'
            'Custo por quilômetro: R\$ ${custoPorKm.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Por favor, insira valores válidos para todos os campos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String formatInput(String input) {
    return input.replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: kmController,
            decoration: const InputDecoration(labelText: 'Quilômetros Rodados (use vírgula para decimais)'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: gasolinaController,
            decoration: const InputDecoration(
              labelText: 'Custo da Gasolina',
              prefixText: 'R\$ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: litrosController,
            decoration: const InputDecoration(labelText: 'Litros de Gasolina'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: seguroController,
            decoration: const InputDecoration(
              labelText: 'Valor do Seguro',
              prefixText: 'R\$ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: valorVeiculoController,
            decoration: const InputDecoration(
              labelText: 'Valor do Veículo',
              prefixText: 'R\$ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: calcularGasto,
              child: const Text('Calcular Gasto'),
            ),
          ),
        ],
      ),
    );
  }
}

class CarroFinanciadoScreen extends StatelessWidget {
  const CarroFinanciadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carro em Financiamento'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: CarroFinanciadoForm(),
      ),
    );
  }
}

class CarroFinanciadoForm extends StatefulWidget {
  const CarroFinanciadoForm({super.key});

  @override
  _CarroFinanciadoFormState createState() => _CarroFinanciadoFormState();
}

class _CarroFinanciadoFormState extends State<CarroFinanciadoForm> {
  final TextEditingController kmController = TextEditingController();
  final TextEditingController gasolinaController = TextEditingController();
  final TextEditingController litrosController = TextEditingController();
  final TextEditingController seguroController = TextEditingController();
  final TextEditingController parcelaController = TextEditingController();
  final TextEditingController parcelasRestantesController = TextEditingController();

  Future<void> calcularGasto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String nome = prefs.getString('userName') ?? '';
    final double km = double.tryParse(formatInput(kmController.text)) ?? 0.0;
    final double custoGasolina = double.tryParse(formatInput(gasolinaController.text)) ?? 0.0;
    final double litros = double.tryParse(formatInput(litrosController.text)) ?? 0.0;
    final double seguro = double.tryParse(formatInput(seguroController.text)) ?? 0.0;
    final double parcela = double.tryParse(formatInput(parcelaController.text)) ?? 0.0;
    final int parcelasRestantes = int.tryParse(formatInput(parcelasRestantesController.text)) ?? 0;

    if (km > 0 && custoGasolina > 0 && litros > 0 && seguro > 0 && parcela > 0 && parcelasRestantes > 0) {
      final double autonomia = km / litros;
      final double custoPorKm = custoGasolina / autonomia;
      final double custoMensalFinanciamento = parcela * parcelasRestantes / 12;
      final double resultado = km * (custoPorKm + (seguro / 365) + (custoMensalFinanciamento / 30));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Resultados'),
          content: Text(
            'Olá, $nome!\n\n'
            'Seu gasto total é: R\$ ${resultado.toStringAsFixed(2)}\n'
            'Autonomia do veículo: ${autonomia.toStringAsFixed(2)} km/L\n'
            'Custo por quilômetro: R\$ ${custoPorKm.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Por favor, insira valores válidos para todos os campos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String formatInput(String input) {
    return input.replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: kmController,
            decoration: const InputDecoration(labelText: 'Quilômetros Rodados (use vírgula para decimais)'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: gasolinaController,
            decoration: const InputDecoration(
              labelText: 'Custo da Gasolina',
              prefixText: 'R\$ ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
          ),
          TextField(
            controller: litrosController,
            decoration: const InputDecoration(labelText: 'Litros de Gasolina'),
            keyboardType: TextInputType.number,
            inputFormatters: [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
],
),
TextField(
  controller: seguroController,
  decoration: const InputDecoration(
    labelText: 'Valor do Seguro',
    prefixText: 'R\$ ',
  ),
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
  ],
),
TextField(
  controller: parcelaController,
  decoration: const InputDecoration(
    labelText: 'Valor da Parcela do Financiamento',
    prefixText: 'R\$ ',
  ),
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
  ],
),
TextField(
  controller: parcelasRestantesController,
  decoration: const InputDecoration(labelText: 'Parcelas Restantes (em Meses)'),
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
  ],
),
const SizedBox(height: 20),
Center(
  child: ElevatedButton(
    onPressed: calcularGasto,
    child: const Text('Calcular Gasto'),
  ),
),
],
),
);
}
}
