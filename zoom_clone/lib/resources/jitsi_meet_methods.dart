import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:zoom_clone/resources/auth_methods.dart';
import 'package:zoom_clone/resources/firestore_methods.dart';

class JitsiMeetMethods {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  void createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
  }) async {
    try {
      String name;
      if (username.isEmpty) {
        name = _authMethods.user.displayName ?? 'Anonymous';
      } else {
        name = username;
      }

      var options = JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        isAudioMuted: isAudioMuted,
        isVideoMuted: isVideoMuted,
        userDisplayName: name,
        userEmail: _authMethods.user.email,
        // If there's no userAvatarURL parameter, you might have to handle avatars differently or remove this line
        // userAvatarURL: _authMethods.user.photoURL,
      );

      _firestoreMethods.addToMeetingHistory(roomName);

      await JitsiMeetWrapper.joinMeeting(
        options: options,
        listener: JitsiMeetingListener(
          onOpened: () => print("Meeting opened"),
          onConferenceWillJoin: (url) => print("Will join: $url"),
          onConferenceJoined: (url) => print("Joined: $url"),
          onConferenceTerminated: (url, error) => print("Terminated: $url, error: $error"),
          onAudioMutedChanged: (isMuted) => print("Audio Muted: $isMuted"),
          onVideoMutedChanged: (isMuted) => print("Video Muted: $isMuted"),
          onScreenShareToggled: (participantId, isSharing) => print("Screen Share: $isSharing"),
          onParticipantJoined: (email, name, role, participantId) => print("Participant Joined: $name"),
          onParticipantLeft: (participantId) => print("Participant Left: $participantId"),
          onParticipantsInfoRetrieved: (participantsInfo, requestId) => print("Participants Info: $participantsInfo"),
          onChatMessageReceived: (senderId, message, isPrivate) => print("Chat Message: $message"),
          onChatToggled: (isOpen) => print("Chat Toggled: $isOpen"),
          onClosed: () => print("Meeting closed"),
        ),
      );
    } catch (error) {
      print("Error: $error");
    }
  }
}
