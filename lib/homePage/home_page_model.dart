
enum VaultItemType {
  note,
  file,
  steganography,
}

class VaultItem {
  final String id;
  final String title;
  final VaultItemType type;
  final DateTime lastModified;

  VaultItem({
    required this.id,
    required this.title,
    required this.type,
    required this.lastModified,
  });
}