import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<User> friends;
  final List<User> friendRequests;

  FriendsLoaded({required this.friends, required this.friendRequests});
}

class FriendsError extends FriendsState {
  final String message;
  FriendsError(this.message);
}

class FriendsCubit extends Cubit<FriendsState> {
  final FriendsService friendsService;
  final String currentUserId;

  FriendsCubit({required this.friendsService, required this.currentUserId})
      : super(FriendsInitial());

  // Load both friends and incoming requests
  Future<void> loadFriends() async {
    emit(FriendsLoading());
    try {
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      emit(FriendsLoaded(friends: friends, friendRequests: friendRequests));
    } catch (e) {
      emit(FriendsError("Failed to load data"));
    }
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(String friendId) async {
    try {
      await friendsService.acceptFriendRequest(friendId);

      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      emit(FriendsLoaded(friends: friends, friendRequests: friendRequests));
    } catch (e) {
      emit(FriendsError("Failed to accept request"));
    }
  }

  // Decline a friend request
  Future<void> declineFriendRequest(String friendId) async {
    try {
      await friendsService.declineFriendRequest(friendId);

      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      emit(FriendsLoaded(friends: friends, friendRequests: friendRequests));
    } catch (e) {
      emit(FriendsError("Failed to decline request"));
    }
  }
}
