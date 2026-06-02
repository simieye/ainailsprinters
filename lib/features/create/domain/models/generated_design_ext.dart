import '../../../../core/services/nanobanana_service.dart';
import '../../../gallery/domain/models/nail_design.dart';

extension GeneratedDesignToNailDesign on GeneratedDesign {
  NailDesign toNailDesign() {
    return NailDesign(
      id: id,
      imageUrl: imageUrl,
      title: style,
      category: style,
      tags: tags,
      style: style,
      creatorId: 'ai',
      creatorName: 'nanobanana 3.0',
      likes: (score * 1000).toInt(),
      prints: 0,
      price: 0,
      isAIGenerated: true,
      createdAt: createdAt,
    );
  }
}
