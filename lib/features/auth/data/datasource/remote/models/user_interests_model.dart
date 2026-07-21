import '../../../../domain/entities/user_interests.dart';

class UserInterestModel extends UserInterest {
  const UserInterestModel({
    required super.id,
    required super.name,
    super.icon,
  });

  factory UserInterestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserInterestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
    );
  }
}

class UserInterestsModel extends UserInterests {
  const UserInterestsModel({
    required super.onboardingCompleted,
    required super.interests,
  });

  factory UserInterestsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawInterests =
        json['interests'] as List<dynamic>? ?? [];

    return UserInterestsModel(
      onboardingCompleted:
          json['onboardingCompleted'] as bool? ?? false,

      interests: rawInterests
          .map(
            (item) => UserInterestModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}