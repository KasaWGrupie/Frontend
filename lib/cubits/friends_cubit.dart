import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_w_grupie/models/friend_request_user.dart';
import 'package:kasa_w_grupie/models/user.dart';
import 'package:kasa_w_grupie/services/friends_service.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<User> friends;
  final List<FriendRequestUser> friendRequests;
  final List<FriendRequestUser> sentRequests;

  FriendsLoaded({
    required this.friends,
    required this.friendRequests,
    required this.sentRequests,
  });
}

class FriendsError extends FriendsState {
  final String message;
  FriendsError(this.message);
}

class FriendsCubit extends Cubit<FriendsState> {
  final FriendsService friendsService;

  FriendsCubit({required this.friendsService}) : super(FriendsInitial());

  // Load friends, incoming and sent requests
  Future<void> loadFriends() async {
    emit(FriendsLoading());
    try {
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      final sentRequests = await friendsService.getSentRequests();

      if (!isClosed) {
        emit(FriendsLoaded(
          friends: friends,
          friendRequests: friendRequests,
          sentRequests: sentRequests,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(FriendsError("Failed to load data"));
      }
    }
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(int friendId) async {
    try {
      await friendsService.acceptFriendRequest(friendId);

      // After accepting the request, reload friends and requests
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      final sentRequests = await friendsService.getSentRequests();
      emit(FriendsLoaded(
          friends: friends,
          friendRequests: friendRequests,
          sentRequests: sentRequests));
    } catch (e) {
      emit(FriendsError("Failed to accept request"));
    }
  }

  // Decline a friend request
  Future<void> declineFriendRequest(int friendId) async {
    try {
      await friendsService.declineFriendRequest(friendId);

      // After declining the request, reload friends and requests
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      final sentRequests = await friendsService.getSentRequests();
      emit(FriendsLoaded(
          friends: friends,
          friendRequests: friendRequests,
          sentRequests: sentRequests));
    } catch (e) {
      emit(FriendsError("Failed to decline request"));
    }
  }

  // Send a friend request to a user by their email
  Future<void> sendFriendRequest(String email) async {
    emit(FriendsLoading());
    try {
      // Send friend request
      await friendsService.sendFriendRequest(email);

      // After sending the request, reload friends and friend requests
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      final sentRequests = await friendsService.getSentRequests();
      emit(FriendsLoaded(
          friends: friends,
          friendRequests: friendRequests,
          sentRequests: sentRequests));
    } catch (e) {
      emit(FriendsError("Failed to send friend request"));
    }
  }

  // Remove a friend
  Future<void> removeFriend(int friendId) async {
    try {
      await friendsService.removeFriend(friendId);

      // After removing the friend, reload the friends list
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      final sentRequests = await friendsService.getSentRequests();
      emit(FriendsLoaded(
          friends: friends,
          friendRequests: friendRequests,
          sentRequests: sentRequests));
    } catch (e) {
      emit(FriendsError("Failed to remove friend"));
    }
  }

  // Withdraw friend request sent by logged-in user
  Future<void> withdrawFriendRequest(int friendId) async {
    try {
      await friendsService.withdrawFriendRequest(friendId);

      // Reload updated sent requests
      final friends = await friendsService.getFriends();
      final friendRequests = await friendsService.getFriendRequests();
      final sentRequests = await friendsService.getSentRequests();

      emit(FriendsLoaded(
        friends: friends,
        friendRequests: friendRequests,
        sentRequests: sentRequests,
      ));
    } catch (e) {
      emit(FriendsError("Failed to withdraw friend request"));
    }
  }
}
