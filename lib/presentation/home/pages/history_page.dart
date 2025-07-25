import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/history/history_bloc.dart';
import '../widgets/history_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    context.read<HistoryBloc>().add(const HistoryEvent.getHistories());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return state.maybeWhen(
            success: (histories) {
              if (histories.isEmpty) {
                return const Center(
                  child: Text('No Data'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: histories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                    ),
                    child: HistoryCard(item: histories[index]),
                  );
                },
              );
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            orElse: () {
              return const Center(
                child: Text('No Data'),
              );
            },
          );
          // return ListView(
          //   padding: const EdgeInsets.all(16.0),
          //   children: List.generate(5, (index) => HistoryCard(item: null)),
          // );
        },
      ),
    );
  }
}
