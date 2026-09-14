import 'package:flutter/material.dart';

enum WorkRequestPriority {
  low,
  normal,
  high,
}

extension WorkRequestPriorityLabel on WorkRequestPriority {
  String get label {
    return switch (this) {
      WorkRequestPriority.low => 'Low',
      WorkRequestPriority.normal => 'Normal',
      WorkRequestPriority.high => 'High',
    };
  }

  static WorkRequestPriority fromName(String? value) {
    return WorkRequestPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => WorkRequestPriority.normal,
    );
  }
}

enum WorkRequestLabPreference {
  noPreference,
  ideaLab,
  fabLab,
}

extension WorkRequestLabPreferenceLabel on WorkRequestLabPreference {
  String get label {
    return switch (this) {
      WorkRequestLabPreference.noPreference => 'No preference',
      WorkRequestLabPreference.ideaLab => 'IDEA Lab',
      WorkRequestLabPreference.fabLab => 'Fab Lab',
    };
  }

  static WorkRequestLabPreference fromName(String? value) {
    return WorkRequestLabPreference.values.firstWhere(
      (lab) => lab.name == value,
      orElse: () => WorkRequestLabPreference.noPreference,
    );
  }
}

class WorkRequestCategoryOption {
  const WorkRequestCategoryOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.enabled,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool enabled;
}

class FabricationSubcategoryOption {
  const FabricationSubcategoryOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
}

class WorkRequestOptions {
  WorkRequestOptions._();

  static const categories = [
    WorkRequestCategoryOption(
      label: 'Fabrication',
      description: 'Laser, 3D print, PCB, CNC, and assembly requests.',
      icon: Icons.precision_manufacturing_rounded,
      enabled: true,
    ),
    WorkRequestCategoryOption(
      label: 'Technical Support',
      description: 'Debugging, electronics, firmware, and project guidance.',
      icon: Icons.support_agent_rounded,
      enabled: false,
    ),
    WorkRequestCategoryOption(
      label: 'Design Assistance',
      description: 'CAD, layout, mechanical review, and maker feedback.',
      icon: Icons.design_services_rounded,
      enabled: false,
    ),
    WorkRequestCategoryOption(
      label: 'Inventory Request',
      description: 'Components, tools, materials, and procurement support.',
      icon: Icons.inventory_2_rounded,
      enabled: false,
    ),
  ];

  static const fabricationSubcategories = [
    FabricationSubcategoryOption(
      id: 'laser_cutting',
      label: 'Laser Cutting',
      description: 'Acrylic, MDF, paper, and sheet cutting.',
      icon: Icons.content_cut_rounded,
    ),
    FabricationSubcategoryOption(
      id: '3d_printing',
      label: '3D Printing',
      description: 'Bambu, Snapmaker, Flashforge, and FDM prints.',
      icon: Icons.view_in_ar_rounded,
    ),
    FabricationSubcategoryOption(
      id: 'pcb_milling',
      label: 'PCB Milling',
      description: 'Prototype boards, traces, and drill passes.',
      icon: Icons.memory_rounded,
    ),
    FabricationSubcategoryOption(
      id: 'cnc_routing',
      label: 'CNC Routing',
      description: 'ShopBot, wood, foam, plastics, and panels.',
      icon: Icons.carpenter_rounded,
    ),
    FabricationSubcategoryOption(
      id: 'electronics_assembly',
      label: 'Electronics Assembly',
      description: 'Soldering, wiring, sensors, and bring-up help.',
      icon: Icons.electrical_services_rounded,
    ),
    FabricationSubcategoryOption(
      id: 'mechanical_assembly',
      label: 'Mechanical Assembly',
      description: 'Fitting, fastening, finishing, and test assembly.',
      icon: Icons.handyman_rounded,
    ),
  ];
}
