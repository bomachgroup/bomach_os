import '../../pages/hr/models/training_program_model.dart';

class RoleTrainingProgramSummary {
  final int id;
  final String programName;
  final String provider;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  const RoleTrainingProgramSummary({
    required this.id,
    required this.programName,
    required this.provider,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory RoleTrainingProgramSummary.fromJson(Map<String, dynamic> json) {
    return RoleTrainingProgramSummary(
      id: _toInt(json['id']),
      programName: json['program_name']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startDate: _toDate(json['start_date']),
      endDate: _toDate(json['end_date']),
    );
  }
}

class RoleTrainingRequirement {
  final int id;
  final int roleId;
  final int trainingProgramId;
  final RoleTrainingProgramSummary trainingProgram;
  final String requirementType;
  final int sequence;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleTrainingRequirement({
    required this.id,
    required this.roleId,
    required this.trainingProgramId,
    required this.trainingProgram,
    required this.requirementType,
    required this.sequence,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleTrainingRequirement.fromJson(Map<String, dynamic> json) {
    final rawProgram = json['training_program'];
    final program = rawProgram is Map
        ? RoleTrainingProgramSummary.fromJson(
            Map<String, dynamic>.from(rawProgram))
        : const RoleTrainingProgramSummary(
            id: 0,
            programName: '',
            provider: '',
            status: '',
          );

    return RoleTrainingRequirement(
      id: _toInt(json['id']),
      roleId: _toInt(json['role_id']),
      trainingProgramId: _toInt(json['training_program_id']),
      trainingProgram: program,
      requirementType: json['requirement_type']?.toString() ?? '',
      sequence: _toInt(json['sequence'], fallback: 0),
      isActive: json['is_active'] == true,
      createdAt: _toDate(json['created_at']),
      updatedAt: _toDate(json['updated_at']),
    );
  }

  bool get isMandatory => requirementType.toLowerCase() == 'mandatory';

  TrainingProgram toTrainingProgram() {
    return TrainingProgram(
      id: trainingProgram.id.toString(),
      programName: trainingProgram.programName,
      provider: trainingProgram.provider,
      description: '',
      startDate: trainingProgram.startDate,
      endDate: trainingProgram.endDate,
      cost: 0,
      targetAudience: '',
      durationDays: 0,
      status: trainingProgram.status,
      isMandatory: isMandatory,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _toDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString());
