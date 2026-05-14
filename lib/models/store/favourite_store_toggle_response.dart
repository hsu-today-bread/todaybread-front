class FavouriteStoreToggleResponse {
  final bool added;

  const FavouriteStoreToggleResponse({required this.added});

  factory FavouriteStoreToggleResponse.fromJson(Map<String, dynamic> json) {
    return FavouriteStoreToggleResponse(added: json['added'] as bool? ?? false);
  }
}
