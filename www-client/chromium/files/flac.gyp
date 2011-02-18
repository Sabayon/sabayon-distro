{
  'targets': [
    {
      'target_name': 'libflac',
      'type': 'settings',
      'direct_dependent_settings': {
        'defines': [
          'USE_SYSTEM_FLAC',
        ],
      },
      'link_settings': {
        'ldflags': [
          '<!@(pkg-config --libs-only-L --libs-only-other flac)',
        ],
        'libraries': [
          '<!@(pkg-config --libs-only-l flac)',
        ],
      },
    },
  ],
}
