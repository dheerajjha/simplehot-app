// Input: Stock model, onTap callback
// Output: A card displaying stock information with tap functionality

import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../constants/theme_constants.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;
  final bool showDetailedInfo;

  const StockCard({
    Key? key,
    required this.stock,
    required this.onTap,
    this.showDetailedInfo = false,
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
              // Stock header with symbol and current price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Stock icon (placeholder)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius:
                                BorderRadius.circular(AppSizes.smallRadius),
                          ),
                          child: Center(
                            child: Text(
                              stock.symbol.substring(0, 1),
                              style: const TextStyle(
                                color: AppColors.primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.mediumPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stock.symbol,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                stock.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.smallPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${stock.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            stock.isPositiveChange
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 14,
                            color: stock.isPositiveChange
                                ? AppColors.gainColor
                                : AppColors.lossColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${stock.isPositiveChange ? '+' : ''}${stock.change.toStringAsFixed(2)} (${stock.changePercentage.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              fontSize: 14,
                              color: stock.isPositiveChange
                                  ? AppColors.gainColor
                                  : AppColors.lossColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Show additional info if detailed view is requested
              if (showDetailedInfo) ...[
                const SizedBox(height: AppSizes.mediumPadding),
                const Divider(color: AppColors.dividerColor),
                const SizedBox(height: AppSizes.smallPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                          'Day High', '₹${stock.dayHigh.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                          'Day Low', '₹${stock.dayLow.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child:
                          _buildInfoItem('Volume', _formatVolume(stock.volume)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.mediumPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                          '52w High', '₹${stock.yearHigh.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                          '52w Low', '₹${stock.yearLow.toStringAsFixed(2)}'),
                    ),
                    Expanded(
                      child: _buildInfoItem('Sector', stock.sector),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 10000000) {
      return '${(volume / 10000000).toStringAsFixed(2)}Cr';
    } else if (volume >= 100000) {
      return '${(volume / 100000).toStringAsFixed(2)}L';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    } else {
      return volume.toString();
    }
  }
}
