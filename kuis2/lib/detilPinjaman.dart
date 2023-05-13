import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class DetilModel {
  String id;
  String nama;
  String bunga;
  String isSyariah;

  DetilModel(
      {required this.id,
      required this.nama,
      required this.bunga,
      required this.isSyariah});
}

class DetilCubit extends Cubit<DetilModel> {
  String url = "https://www.boredapi.com/api/activity";
  DetilCubit() : super(DetilModel(id: "", nama: "", bunga: "", isSyariah: ""));

  void setFromJson(Map<String, dynamic> json) {
    String id = json['id'];
    String nama = json['nama'];
    String bunga = json['bunga'];
    String isSyariah = json['is_syariah'];

    emit(DetilModel(id: id, nama: nama, bunga: bunga, isSyariah: isSyariah));
  }

  void fetchData() async {
    String idJenis = "1";
    url += idJenis;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      //sukses
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class PageDetil extends StatelessWidget {
  const PageDetil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => DetilCubit(),
        child: const DetilJenis(),
      ),
    );
  }
}

class DetilJenis extends StatelessWidget {
  const DetilJenis({Key? key}) : super(key: key);

  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('Detail Pinjaman')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlocBuilder<DetilCubit, DetilModel>(
            builder: (context, detil) {
              context.read<DetilCubit>().fetchData();
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                    ),
                    Text("Id : ${detil.id}"), //data terupdate di sini
                    Text("Nama : ${detil.nama}"), //data terupdate di sini
                    Text("Bunga : ${detil.bunga}"), //data terupdate di sini
                    Text("Syariah : ${detil.isSyariah}"),
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}
