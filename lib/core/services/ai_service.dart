import 'package:flutter_riverpod/flutter_riverpod.dart';

class NextActionSuggestion {
  NextActionSuggestion({
    required this.actionType,
    this.targetTaskId,
    this.targetUid,
    required this.rationale,
  });

  final String actionType;
  final String? targetTaskId;
  final String? targetUid;
  final String rationale;
}

abstract class AiService {
  Future<String> fetchManagerBriefing(String teamId);
  Future<List<NextActionSuggestion>> fetchNextBestActions(String teamId);
}

class StubAiService implements AiService {
  @override
  Future<String> fetchManagerBriefing(String teamId) async {
    // Deterministic stub keeps demo flow unblocked before API keys exist.
    return 'Team $teamId snapshot: 2 tasks done, 1 overdue, 1 blocked. Employee1 is active; Employee2 idle. Top risks: overdue SLA, blocked dependency.';
  }

  @override
  Future<List<NextActionSuggestion>> fetchNextBestActions(String teamId) async {
    return [
      NextActionSuggestion(
        actionType: 'PING_EMPLOYEE',
        targetUid: 'employee1',
        rationale: 'Waiting for acknowledgment past SLA. Send a quick ping.',
      ),
      NextActionSuggestion(
        actionType: 'REASSIGN_TASK',
        targetTaskId: 'task-blocked',
        rationale: 'Blocked for 30m; reassign to keep momentum.',
      ),
      NextActionSuggestion(
        actionType: 'CLARIFY_TASK',
        targetTaskId: 'task-overdue',
        rationale: 'Due today with silence for 40m; add clarification.',
      ),
    ];
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return StubAiService();
});
