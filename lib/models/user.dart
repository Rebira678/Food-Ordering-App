class AppUser {
  final String? id;
  final String name;
  final String email;
  final String role; // 'customer' | 'restaurant' | 'superadmin'
  final String? address;
  final String? avatarUrl;
  final String? referralCode;
  final List<int> availableDiscounts;
  final bool pushEnabled;
  final bool emailEnabled;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    this.role = 'customer',
    this.address,
    this.avatarUrl,
    this.referralCode,
    this.availableDiscounts = const [],
    this.pushEnabled = true,
    this.emailEnabled = false,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? address,
    String? avatarUrl,
    String? referralCode,
    List<int>? availableDiscounts,
    bool? pushEnabled,
    bool? emailEnabled,
  }) =>
      AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        address: address ?? this.address,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        referralCode: referralCode ?? this.referralCode,
        availableDiscounts: availableDiscounts ?? this.availableDiscounts,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        emailEnabled: emailEnabled ?? this.emailEnabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'address': address,
        'avatarUrl': avatarUrl,
        'referralCode': referralCode,
        'availableDiscounts': availableDiscounts,
        'pushEnabled': pushEnabled,
        'emailEnabled': emailEnabled,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String?,
        name: json['full_name'] as String? ?? json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        address: json['address'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        referralCode: json['referral_code'] as String?,
        availableDiscounts: json['availableDiscounts'] != null
            ? List<int>.from(json['availableDiscounts'] as List)
            : [],
        pushEnabled: json['push_enabled'] as bool? ?? true,
        emailEnabled: json['email_enabled'] as bool? ?? false,
      );
}
