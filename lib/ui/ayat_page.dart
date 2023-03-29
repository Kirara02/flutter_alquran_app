import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ahlul_quran_app/bloc/ayat/ayat_bloc.dart';
// import 'package:flutter_ahlul_quran_app/cubit/ayat/ayat_cubit.dart';

import 'package:flutter_ahlul_quran_app/data/models/surat_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/contants.dart';

class AyatPage extends StatefulWidget {
  const AyatPage({
    Key? key,
    required this.surat,
  }) : super(key: key);
  final SuratModel surat;

  @override
  State<AyatPage> createState() => _AyatPageState();
}

class _AyatPageState extends State<AyatPage> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int value = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    // context.read<AyatCubit>().getDetailSurat(widget.surat.nomor);
    context.read<AyatBloc>().add(AyatGetEvent(noSurat: widget.surat.nomor));

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onAudioPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.surat.namaLatin,
        ),
      ),
      body: BlocBuilder<AyatBloc, AyatState>(
        builder: (context, state) {
          if (state is AyatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is AyatLoaded) {
            return ListView.builder(
              itemBuilder: (context, index) {
                final ayat = state.detail.ayat![index];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '${ayat.nomorAyat}',
                            style: const TextStyle(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          '${ayat.teksArab}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('${ayat.teksIndonesia}'),
                        trailing: IconButton(
                          onPressed: () async {
                            if (isPlaying) {
                              await audioPlayer.pause();
                            } else {
                              setState(() {
                                value = ayat.nomorAyat! - 1;
                              });
                              await audioPlayer.play(ayat.audio!['02']!);
                            }
                          },
                          icon: Icon(
                            isPlaying && index == value
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: state.detail.ayat!.length,
            );
          }
          if (state is AyatError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const Center(
            child: Text('no data'),
          );
        },
      ),
    );
  }
}
