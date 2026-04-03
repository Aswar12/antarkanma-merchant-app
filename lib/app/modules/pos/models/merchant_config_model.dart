class MerchantConfigModel {
  final String paymentFlow;
  final bool autoReleaseTable;
  final int defaultDineDuration;

  MerchantConfigModel({
    required this.paymentFlow,
    required this.autoReleaseTable,
    required this.defaultDineDuration,
  });

  static const String payFirst = 'PAY_FIRST';
  static const String payLast = 'PAY_LAST';

  bool get isPayFirst => paymentFlow == payFirst;
  bool get isPayLast => paymentFlow == payLast;
  bool get shouldAutoRelease => autoReleaseTable && isPayFirst;

  String get paymentFlowDisplay => isPayFirst ? 'Bayar Duluan' : 'Bayar Nanti';

  String get dineDurationDisplay {
    if (defaultDineDuration >= 60) {
      final hours = defaultDineDuration ~/ 60;
      final mins = defaultDineDuration % 60;
      if (mins == 0) return '$hours jam';
      return '$hours jam $mins menit';
    }
    return '$defaultDineDuration menit';
  }

  factory MerchantConfigModel.fromJson(Map<String, dynamic> json) {
    return MerchantConfigModel(
      paymentFlow: json['payment_flow'] ?? payFirst,
      autoReleaseTable: json['auto_release_table'] ?? false,
      defaultDineDuration: json['default_dine_duration'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_flow': paymentFlow,
      'auto_release_table': autoReleaseTable,
      'default_dine_duration': defaultDineDuration,
    };
  }

  MerchantConfigModel copyWith({
    String? paymentFlow,
    bool? autoReleaseTable,
    int? defaultDineDuration,
  }) {
    return MerchantConfigModel(
      paymentFlow: paymentFlow ?? this.paymentFlow,
      autoReleaseTable: autoReleaseTable ?? this.autoReleaseTable,
      defaultDineDuration: defaultDineDuration ?? this.defaultDineDuration,
    );
  }
}
