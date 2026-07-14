enum ResourceType {
  physicalResource,
  softwareTool,
  referenceDocument,
  technicalSkill,
  softSkill,
  experienceRequirement,
  certification,
}

class PhysicalResource {
  final int? id;
  final int roleId;
  final String name;
  final String? description;
  final int quantity;
  final bool isAssigned;

  const PhysicalResource({
    this.id,
    required this.roleId,
    required this.name,
    this.description,
    this.quantity = 1,
    this.isAssigned = false,
  });

  factory PhysicalResource.fromJson(Map<String, dynamic> json) {
    return PhysicalResource(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      isAssigned: json['is_assigned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'role_id': roleId, 'name': name, 'description': description,
    'quantity': quantity, 'is_assigned': isAssigned,
  };
}

class SoftwareTool {
  final int? id;
  final int roleId;
  final String name;
  final String? vendor;
  final String? licenseType;

  const SoftwareTool({
    this.id,
    required this.roleId,
    required this.name,
    this.vendor,
    this.licenseType,
  });

  factory SoftwareTool.fromJson(Map<String, dynamic> json) {
    return SoftwareTool(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      vendor: json['vendor'],
      licenseType: json['license_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'role_id': roleId, 'name': name, 'vendor': vendor, 'license_type': licenseType,
  };
}

class ReferenceDocument {
  final int? id;
  final int roleId;
  final String title;
  final String? documentType;
  final String? filePath;

  const ReferenceDocument({
    this.id,
    required this.roleId,
    required this.title,
    this.documentType,
    this.filePath,
  });

  factory ReferenceDocument.fromJson(Map<String, dynamic> json) {
    return ReferenceDocument(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      documentType: json['document_type'],
      filePath: json['file_path'],
    );
  }

  Map<String, dynamic> toJson() => {
    'role_id': roleId, 'title': title, 'document_type': documentType, 'file_path': filePath,
  };
}

class TechnicalSkill {
  final int? id;
  final int roleId;
  final String name;
  final String? category;
  final String? proficiencyLevel;

  const TechnicalSkill({
    this.id,
    required this.roleId,
    required this.name,
    this.category,
    this.proficiencyLevel,
  });

  factory TechnicalSkill.fromJson(Map<String, dynamic> json) {
    return TechnicalSkill(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      category: json['category'],
      proficiencyLevel: json['proficiency_level'],
    );
  }

  Map<String, dynamic> toJson() => {
    'role_id': roleId, 'name': name, 'category': category, 'proficiency_level': proficiencyLevel,
  };
}

class SoftSkill {
  final int? id;
  final int roleId;
  final String name;
  final String? description;

  const SoftSkill({
    this.id,
    required this.roleId,
    required this.name,
    this.description,
  });

  factory SoftSkill.fromJson(Map<String, dynamic> json) {
    return SoftSkill(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'role_id': roleId, 'name': name, 'description': description,
  };
}

class ExperienceRequirement {
  final int? id;
  final int roleId;
  final String description;
  final int minYears;
  final String? experienceType;

  const ExperienceRequirement({
    this.id,
    required this.roleId,
    required this.description,
    this.minYears = 0,
    this.experienceType,
  });

  factory ExperienceRequirement.fromJson(Map<String, dynamic> json) {
    return ExperienceRequirement(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      description: json['description'] ?? '',
      minYears: int.tryParse(json['min_years']?.toString() ?? '0') ?? 0,
      experienceType: json['experience_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'role_id': roleId, 'description': description, 'min_years': minYears, 'experience_type': experienceType,
  };
}

class Certification {
  final int? id;
  final int roleId;
  final String name;
  final String? issuingBody;
  final bool isMandatory;

  const Certification({
    this.id,
    required this.roleId,
    required this.name,
    this.issuingBody,
    this.isMandatory = false,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      roleId: int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      issuingBody: json['issuing_body'],
      isMandatory: json['is_mandatory'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'role_id': roleId, 'name': name, 'issuing_body': issuingBody, 'is_mandatory': isMandatory,
  };
}
