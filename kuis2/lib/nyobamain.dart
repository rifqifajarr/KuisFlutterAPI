import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:kuis2/detilPinjaman.dart';

class Jenis {
  String nama = '';
  String id = '';

  Jenis({required this.nama, required this.id});
}

class JenisModel {
  List<Jenis> listJenis = <Jenis>[];

  JenisModel(dynamic json) {
    var data = json["data"];

    for (var val in data) {
      var nama = val["nama"];
      var id = val["id"];
      listJenis.add(Jenis(nama: nama, id: id));
    }
  }

  factory JenisModel.fromJson(dynamic json) {
    return JenisModel(json);
  }
}

class JenisCubit extends Cubit<JenisModel> {
  bool loading = true;
  String url = "http://178.128.17.76:8000/jenis_pinjaman/";
  String jenis = "1";

  JenisCubit() : super(JenisModel([])) {
    fetchData();
  }

  // JenisCubit() {}

  void setFromJson(dynamic json) {
    emit(JenisModel(json));
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url + jenis));
    if (response.statusCode == 200) {
      if (loading) loading = false;
      setFromJson(jsonDecode(response.body));
    } else {
      if (loading) loading = false;
      throw Exception('Gagal load data dari api');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nyobamain',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => JenisCubit(),
        child: PageJenis(),
      ),
    );
  }
}

class PageJenis extends StatelessWidget {
  const PageJenis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> jenisPinjaman = [];

    String pilihanPinjaman = "1";

    var itm1 = const DropdownMenuItem<String>(
      value: "1",
      child: Text("Jenis Pinjaman 1"),
    );
    var itm2 = const DropdownMenuItem<String>(
      value: "2",
      child: Text("Jenis Pinjaman 2"),
    );
    var itm3 = const DropdownMenuItem<String>(
      value: "3",
      child: Text("Jenis Pinjaman 3"),
    );

    jenisPinjaman.add(itm1);
    jenisPinjaman.add(itm2);
    jenisPinjaman.add(itm3);
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          DropdownButtonFormField(
            value: pilihanPinjaman,
            items: jenisPinjaman,
          ),
          BlocBuilder<JenisCubit, JenisModel>(
            builder: (context, aktivitas) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<JenisCubit>().fetchData();
                        },
                      ),
                    ),
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}
