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
      title: 'Kuis Flutter 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => JenisCubit(),
        child: const MyHomePage(title: "My App P2P"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> jenisPinjaman = [];

    String pilihanPinjaman = "1";

    var itm1 = DropdownMenuItem<String>(
      value: "1",
      child: Text("Jenis Pinjaman 1"),
    );
    var itm2 = DropdownMenuItem<String>(
      value: "2",
      child: Text("Jenis Pinjaman 2"),
    );
    var itm3 = DropdownMenuItem<String>(
      value: "3",
      child: Text("Jenis Pinjaman 3"),
    );

    jenisPinjaman.add(itm1);
    jenisPinjaman.add(itm2);
    jenisPinjaman.add(itm3);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              "2101103, 2108938; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang"),
          Text("Pilihan Pinjaman: " + pilihanPinjaman),
          DropdownButtonFormField(
              value: pilihanPinjaman,
              items: jenisPinjaman,
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) pilihanPinjaman = newValue;
                  final listJenis = BlocProvider.of<JenisCubit>(context);
                  listJenis.loading = true;
                  listJenis.jenis = newValue!;
                  listJenis.fetchData();
                });
              }),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PageDetil()));
              },
              child: Text('Pindah Page')),
          Container(
              child: BlocBuilder<JenisCubit, JenisModel>(
            buildWhen: (previousState, state) {
              return true;
            },
            builder: (context, jenis) {
              final listJenisCubit = BlocProvider.of<JenisCubit>(context);
              if (listJenisCubit.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (jenis.listJenis.isNotEmpty) {
                // gunakan listview builder
                return ListView.builder(
                    itemCount: jenis.listJenis.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: Row(children: [
                        Image.asset(
                          "foto.jpeg",
                          height: 60,
                        ),
                        const Padding(padding: EdgeInsets.all(7)),
                        Column(
                          children: [
                            Text(jenis.listJenis[index].nama),
                            Text("id " + jenis.listJenis[index].id),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(left: 375)),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {},
                        )
                      ]));
                    });
              }
              return const Text('Data tidak ada');
            },
          ))
        ],
      )),
    );
  }
}
