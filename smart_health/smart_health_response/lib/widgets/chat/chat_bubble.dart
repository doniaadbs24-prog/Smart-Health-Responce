import 'package:flutter/material.dart';
import '../../core/configuration/colors.dart';
import '../../core/configuration/dimensions.dart';
import '../../core/configuration/text_styles.dart';
import '../../models/communication_model.dart';
import '../../utils/formatters.dart';

class ChatBubble extends StatelessWidget {
  final CommunicationRecord message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = isMe ? AppColors.primary : AppColors.surface;
    final textColor = isMe ? AppColors.textOnPrimary : AppColors.textPrimary;
    final align = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: align,
        children: [
          if (!isMe)
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.surfaceAlt,
              child: Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
          const SizedBox(width: AppDimensions.paddingS),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppDimensions.radiusL),
                  topRight: const Radius.circular(AppDimensions.radiusL),
                  bottomLeft: Radius.circular(isMe ? AppDimensions.radiusL : 4),
                  bottomRight: Radius.circular(isMe ? 4 : AppDimensions.radiusL),
                ),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.messageContent,
                      style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
                  const SizedBox(height: 4),
                  Text(Formatters.time(message.sentAt),
                      style: AppTextStyles.caption.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
