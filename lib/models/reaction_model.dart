enum ReactionType {
  like,
  gas,   // 🏍️ La exclusiva de Motos
  love,
  haha,
  wow,
  sad,
  angry
}

class ReactionConverter {
  static ReactionType fromString(String type) {
    switch (type) {
      case 'gas': return ReactionType.gas;
      case 'love': return ReactionType.love;
      case 'haha': return ReactionType.haha;
      case 'wow': return ReactionType.wow;
      case 'sad': return ReactionType.sad;
      case 'angry': return ReactionType.angry;
      default: return ReactionType.like;
    }
  }
}