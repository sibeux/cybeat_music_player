class MusicExtras {
  final int discNumber;
  final String index,
      musicId,
      musicUrl,
      musicPlaylistId,
      originalSource,
      uploader;
  final bool isFavorite,
      isCached,
      isLossless,
      isDownloaded,
      isSuspicious,
      isOffline;
  final MusicMetadata metadata;
  final MusicDominantColor dominantColor;

  const MusicExtras({
    required this.discNumber,
    required this.index,
    required this.musicId,
    required this.musicUrl,
    required this.isFavorite,
    required this.musicPlaylistId,
    required this.originalSource,
    required this.isCached,
    required this.isLossless,
    required this.metadata,
    required this.dominantColor,
    required this.uploader,
    required this.isDownloaded,
    required this.isSuspicious,
    required this.isOffline,
  });

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'music_id': musicId,
      'disc_number': discNumber,
      'url': musicUrl,
      'favorite': isFavorite,
      'id_playlist_music': musicPlaylistId,
      'original_source': originalSource,
      'is_cached': isCached,
      'is_lossless': isLossless,
      'metadata': {
        'metadata_id_music': metadata.musicMetadataId,
        'codec_name': metadata.codecName,
        'sample_rate': metadata.sampleRate,
        'bit_rate': metadata.bitRate,
        'bits_per_raw_sample': metadata.bitsPerSampleRaw
      },
      'dominant_color': {
        'bg_color': dominantColor.backgroundColor,
        'text_color': dominantColor.textColor
      },
      'is_downloaded': isDownloaded,
      'uploader': uploader,
      'is_suspicious': isSuspicious,
      'is_offline': isOffline,
    };
  }
}

class MusicMetadata {
  final String musicMetadataId,
      codecName,
      sampleRate,
      bitRate,
      bitsPerSampleRaw;

  const MusicMetadata({
    required this.musicMetadataId,
    required this.codecName,
    required this.sampleRate,
    required this.bitRate,
    required this.bitsPerSampleRaw,
  });
}

class MusicDominantColor {
  final String backgroundColor, textColor;

  const MusicDominantColor({
    required this.backgroundColor,
    required this.textColor,
  });
}
