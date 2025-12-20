
enum AttachmentType { image, video }

class Attachment {
  final AttachmentType type;
  final String url;
  final String? thumbnailUrl; // Opcional, para miniaturas de vídeo

  Attachment({required this.type, required this.url, this.thumbnailUrl});
}
