// Input: Prediction model, onTap callback, onLike callback
// Output: A card displaying prediction information with interactions

import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../constants/theme_constants.dart';

class PredictionCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback onTap;
  final Function(bool) onLike;

  const PredictionCard({
    Key? key,
    required this.prediction,
    required this.onTap,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: AppSizes.smallPadding,
          horizontal: AppSizes.mediumPadding,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info and timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // User avatar (placeholder)
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            prediction.username.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.smallPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prediction.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                prediction.formattedCreatedDate,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.smallPadding),
                  _buildStatusBadge(),
                ],
              ),

              // Prediction content
              const SizedBox(height: AppSizes.mediumPadding),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${prediction.stockSymbol} • ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                prediction.stockName,
                                style: const TextStyle(
                                  color: AppColors.secondaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.smallPadding),
                        _buildPriceRow(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.smallPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Target Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      Text(
                        prediction.formattedTargetDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prediction.timeLeft,
                        style: TextStyle(
                          fontSize: 12,
                          color: prediction.isPending
                              ? AppColors.primaryColor
                              : AppColors.secondaryTextColor,
                          fontWeight: prediction.isPending
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Prediction description
              if (prediction.description != null &&
                  prediction.description!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.mediumPadding),
                Text(
                  prediction.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryTextColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Interaction buttons
              const SizedBox(height: AppSizes.mediumPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Like button
                      InkWell(
                        onTap: () => onLike(!prediction.isLikedByUser),
                        child: Row(
                          children: [
                            Icon(
                              prediction.isLikedByUser
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: prediction.isLikedByUser
                                  ? AppColors.primaryColor
                                  : AppColors.iconColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              prediction.likes.toString(),
                              style: TextStyle(
                                color: prediction.isLikedByUser
                                    ? AppColors.primaryColor
                                    : AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.mediumPadding),
                      // Comment count
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: AppColors.iconColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            prediction.comments.toString(),
                            style: const TextStyle(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Share button
                  const Icon(Icons.share, size: 20, color: AppColors.iconColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (prediction.status) {
      case PredictionStatus.pending:
        color = AppColors.secondaryColor;
        text = 'Pending';
        break;
      case PredictionStatus.success:
        color = AppColors.gainColor;
        text = 'Success';
        break;
      case PredictionStatus.failed:
        color = AppColors.lossColor;
        text = 'Failed';
        break;
      case PredictionStatus.cancelled:
        color = AppColors.dividerColor;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSizes.smallRadius),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    final Color directionColor = prediction.direction == PredictionDirection.up
        ? AppColors.gainColor
        : prediction.direction == PredictionDirection.down
            ? AppColors.lossColor
            : AppColors.primaryTextColor;

    final String directionIcon = prediction.direction == PredictionDirection.up
        ? '↑'
        : prediction.direction == PredictionDirection.down
            ? '↓'
            : '→';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Current price
        Text(
          '₹${prediction.originalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primaryTextColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        // Direction arrow
        Text(
          ' $directionIcon ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: directionColor,
          ),
        ),

        // Target price
        Text(
          '₹${prediction.targetPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: directionColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        // Percentage
        Text(
          ' (${prediction.percentageDifference >= 0 ? '+' : ''}${prediction.percentageDifference.toStringAsFixed(2)}%)',
          style: TextStyle(
            fontSize: 12,
            color: directionColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
