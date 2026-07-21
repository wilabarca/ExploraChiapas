class UserInterest {
  final String id;
  final String name;
  final String? icon;

  const UserInterest({
    required this.id,
    required this.name,
    this.icon,
  });
}

class UserInterests {
  final bool onboardingCompleted;
  final List<UserInterest> interests;

  const UserInterests({
    required this.onboardingCompleted,
    required this.interests,
  });
}