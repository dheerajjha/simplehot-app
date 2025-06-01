// Input: None
// Output: Stock model with properties and methods

class Stock {
  final String symbol;
  final String name;
  final String exchange;
  final double currentPrice;
  final double change;
  final double changePercentage;
  final double dayHigh;
  final double dayLow;
  final double yearHigh;
  final double yearLow;
  final int volume;
  final String sector;
  final String logoUrl;

  Stock({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.currentPrice,
    required this.change,
    required this.changePercentage,
    required this.dayHigh,
    required this.dayLow,
    required this.yearHigh,
    required this.yearLow,
    required this.volume,
    required this.sector,
    required this.logoUrl,
  });

  bool get isPositiveChange => change >= 0;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      exchange: json['exchange'] ?? 'NSE',
      currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      changePercentage: (json['changePercentage'] ?? 0.0).toDouble(),
      dayHigh: (json['dayHigh'] ?? 0.0).toDouble(),
      dayLow: (json['dayLow'] ?? 0.0).toDouble(),
      yearHigh: (json['yearHigh'] ?? 0.0).toDouble(),
      yearLow: (json['yearLow'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0) as int,
      sector: json['sector'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  // Factory method to create from API response (matches backend API format)
  factory Stock.fromApiJson(Map<String, dynamic> json) {
    return Stock(
      symbol: (json['symbol'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      exchange: 'NSE', // Default to NSE for Indian stocks
      currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      changePercentage: (json['changePercent'] ?? 0.0)
          .toDouble(), // Note: API uses 'changePercent'
      dayHigh: (json['dayHigh'] ?? 0.0).toDouble(),
      dayLow: (json['dayLow'] ?? 0.0).toDouble(),
      yearHigh: (json['yearHigh'] ?? 0.0).toDouble(),
      yearLow: (json['yearLow'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0) as int,
      sector: (json['sector'] ?? 'Unknown')
          .toString(), // Default sector if not provided
      logoUrl: (json['logoUrl'] ?? '')
          .toString(), // Logo URL might not be in API response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'exchange': exchange,
      'currentPrice': currentPrice,
      'change': change,
      'changePercentage': changePercentage,
      'dayHigh': dayHigh,
      'dayLow': dayLow,
      'yearHigh': yearHigh,
      'yearLow': yearLow,
      'volume': volume,
      'sector': sector,
      'logoUrl': logoUrl,
    };
  }

  // Factory method to create a demo stock
  factory Stock.demo({
    String symbol = 'RELIANCE',
    String name = 'Reliance Industries',
  }) {
    return Stock(
      symbol: symbol,
      name: name,
      exchange: 'NSE',
      currentPrice: 2500.75,
      change: 25.50,
      changePercentage: 1.05,
      dayHigh: 2520.30,
      dayLow: 2480.15,
      yearHigh: 2750.00,
      yearLow: 2100.00,
      volume: 3500000,
      sector: 'Oil & Gas',
      logoUrl: 'https://example.com/logos/reliance.png',
    );
  }
}
