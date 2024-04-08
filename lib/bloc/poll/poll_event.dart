abstract class PollEvent {}

class AddPollEvent extends PollEvent {
  final List<String> options;
  final String question;
  final String userId;

  AddPollEvent({required this.question, required this.options, required this.userId});
}

class LoadPolls extends PollEvent {
  final String netaId;

  LoadPolls({required this.netaId});
}

class UpdatePollResponse extends PollEvent  {
  final String pollId;
  final String option;
  final String karyakartaId;
  final String netaId;

  UpdatePollResponse({
    required this.pollId,
    required this.option,
    required this.karyakartaId,
    required this.netaId
  });
}