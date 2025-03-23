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

  FriendsCubit({required this.friendsService}) : super(FriendsInitial());

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

      // After accepting the request, reload friends and requests
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

      // After declining the request, reload friends and requests
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      emit(FriendsLoaded(friends: friends, friendRequests: friendRequests));
    } catch (e) {
      emit(FriendsError("Failed to decline request"));
    }
  }

  // Send a friend request to a user by their email
  Future<void> sendFriendRequest(String email) async {
    emit(FriendsLoading());
    try {
      // Send friend request through service
      await friendsService.sendFriendRequest(email);

      // After sending the request, reload friends and friend requests
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      emit(FriendsLoaded(friends: friends, friendRequests: friendRequests));
    } catch (e) {
      emit(FriendsError("Failed to send friend request"));
    }
  }

  // Remove a friend (unfriend)
  Future<void> removeFriend(String friendId) async {
    try {
      await friendsService.removeFriend(friendId);

      // After removing the friend, reload the friends list
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      emit(FriendsLoaded(friends: friends, friendRequests: friendRequests));
    } catch (e) {
      emit(FriendsError("Failed to remove friend"));
    }
  }
}
