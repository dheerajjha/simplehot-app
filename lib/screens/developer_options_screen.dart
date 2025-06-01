// Input: None
// Output: Developer options screen with server URL configuration

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../constants/theme_constants.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../services/auth_service.dart';

class DeveloperOptionsScreen extends StatefulWidget {
  const DeveloperOptionsScreen({Key? key}) : super(key: key);

  @override
  State<DeveloperOptionsScreen> createState() => _DeveloperOptionsScreenState();
}

class _DeveloperOptionsScreenState extends State<DeveloperOptionsScreen> {
  final _urlController = TextEditingController();
  final _authService = AuthService();
  bool _isSaving = false;
  bool _isCheckingHealth = false;
  String _statusMessage = '';
  bool _isSuccess = false;
  String _healthStatus = '';

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConfig.gatewayUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isCheckingHealth = true;
      _healthStatus = '';
    });

    try {
      final isHealthy = await _authService.healthCheck();
      setState(() {
        _healthStatus = isHealthy
            ? 'API is healthy and responding'
            : 'API is not responding or unhealthy';
        _isSuccess = isHealthy;
      });
    } catch (e) {
      setState(() {
        _healthStatus = 'Health check failed: ${e.toString()}';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isCheckingHealth = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _statusMessage = '';
    });

    try {
      final url = _urlController.text.trim();
      await AppConfig.setGatewayUrl(url);

      setState(() {
        _statusMessage = 'Server URL updated successfully!';
        _isSuccess = true;
      });

      // Copy to clipboard for convenience
      await Clipboard.setData(ClipboardData(text: url));
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to update server URL: ${e.toString()}';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _isSaving = true;
      _statusMessage = '';
    });

    try {
      await AppConfig.resetToDefaultUrl();
      _urlController.text = AppConfig.gatewayUrl;

      setState(() {
        _statusMessage = 'Reset to default URL';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to reset: ${e.toString()}';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Developer Options'),
        backgroundColor: AppColors.cardBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Server Configuration',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Change the server URL for API requests',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Gateway URL',
              hint: 'http://20.193.143.179:5050',
              controller: _urlController,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Default: ${AppConfig.defaultGatewayUrl}',
                    style: const TextStyle(
                      color: AppColors.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _resetToDefault,
                  child: const Text('Reset to Default'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_statusMessage.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.mediumPadding),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? AppColors.gainColor.withOpacity(0.1)
                      : AppColors.lossColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.smallRadius),
                  border: Border.all(
                    color:
                        _isSuccess ? AppColors.gainColor : AppColors.lossColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _isSuccess
                          ? AppColors.gainColor
                          : AppColors.lossColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _isSuccess
                              ? AppColors.gainColor
                              : AppColors.lossColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            CustomButton(
              text: 'Save Settings',
              onPressed: _saveSettings,
              isLoading: _isSaving,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Test API Connection',
              onPressed: _checkHealth,
              isLoading: _isCheckingHealth,
              backgroundColor: AppColors.primaryColor.withOpacity(0.8),
            ),
            if (_healthStatus.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(AppSizes.mediumPadding),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? AppColors.gainColor.withOpacity(0.1)
                      : AppColors.lossColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.smallRadius),
                  border: Border.all(
                    color:
                        _isSuccess ? AppColors.gainColor : AppColors.lossColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _isSuccess
                          ? AppColors.gainColor
                          : AppColors.lossColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _healthStatus,
                        style: TextStyle(
                          color: _isSuccess
                              ? AppColors.gainColor
                              : AppColors.lossColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
            const Divider(color: AppColors.dividerColor),
            const SizedBox(height: 16),
            const Text(
              'API Endpoints',
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Authentication Endpoints
            _buildSectionHeader('Authentication'),
            _buildEndpointItem('Login', AppConfig.loginEndpoint),
            _buildEndpointItem('Register', AppConfig.registerEndpoint),
            _buildEndpointItem('Verify Token', AppConfig.verifyEndpoint),

            // User Endpoints
            _buildSectionHeader('User Management'),
            _buildEndpointItem('User Profile', AppConfig.userProfileEndpoint),
            _buildEndpointItem('User by ID', '${AppConfig.usersEndpoint}/{id}'),
            _buildEndpointItem('Follow User',
                '${AppConfig.usersEndpoint}/{id}${AppConfig.followEndpoint}'),
            _buildEndpointItem('User Followers',
                '${AppConfig.usersEndpoint}/{id}${AppConfig.followersEndpoint}'),
            _buildEndpointItem('User Following',
                '${AppConfig.usersEndpoint}/{id}${AppConfig.followingEndpoint}'),

            // Posts Endpoints
            _buildSectionHeader('Posts & Social'),
            _buildEndpointItem('Create/List Posts', AppConfig.postsEndpoint),
            _buildEndpointItem(
                'Posts by User', '${AppConfig.userPostsEndpoint}/{userId}'),
            _buildEndpointItem('Like Post',
                '${AppConfig.postsEndpoint}/{id}${AppConfig.likeEndpoint}'),
            _buildEndpointItem('Post Comments',
                '${AppConfig.postsEndpoint}/{id}${AppConfig.commentsEndpoint}'),

            // Stock Endpoints
            _buildSectionHeader('Stock Data'),
            _buildEndpointItem(
                'Trending Stocks', AppConfig.trendingStocksEndpoint),
            _buildEndpointItem(
                'Stock Details', '${AppConfig.stocksEndpoint}/{symbol}'),
            _buildEndpointItem('Search Stocks', AppConfig.stockSearchEndpoint),
            _buildEndpointItem('Stock History',
                '${AppConfig.stocksEndpoint}/{symbol}${AppConfig.stockHistoryEndpoint}'),

            // Prediction Endpoints
            _buildSectionHeader('Stock Predictions'),
            _buildEndpointItem(
                'Create Prediction', AppConfig.predictionsEndpoint),
            _buildEndpointItem(
                'Trending Predictions', AppConfig.trendingPredictionsEndpoint),
            _buildEndpointItem('Stock Predictions',
                '${AppConfig.stockPredictionsEndpoint}/{symbol}'),
            _buildEndpointItem('User Predictions',
                '${AppConfig.userPredictionsEndpoint}/{userId}'),
            _buildEndpointItem('Like Prediction',
                '${AppConfig.predictionsEndpoint}/{id}${AppConfig.likeEndpoint}'),
            _buildEndpointItem('Prediction Comments',
                '${AppConfig.predictionsEndpoint}/{id}${AppConfig.commentsEndpoint}'),

            // News Endpoints
            _buildSectionHeader('News Feed'),
            _buildEndpointItem('Stock News', AppConfig.newsEndpoint),

            // Health Check
            _buildSectionHeader('System'),
            _buildEndpointItem('Health Check', AppConfig.healthEndpoint),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEndpointItem(String title, String endpoint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppConfig.gatewayUrl}$endpoint',
                    style: const TextStyle(
                      color: AppColors.secondaryTextColor,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  color: AppColors.primaryColor,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: '${AppConfig.gatewayUrl}$endpoint'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
