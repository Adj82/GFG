import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// One place that maps data to icons, so the same thing always looks the same.
abstract final class AppIcons {
  static IconData domain(String key) => switch (key) {
    'memory' => Icons.memory_rounded,
    'cloud' => Icons.cloud_rounded,
    'phone' => Icons.phone_android_rounded,
    'web' => Icons.language_rounded,
    'code' => Icons.code_rounded,
    'link' => Icons.link_rounded,
    'brain' => Icons.psychology_rounded,
    'shield' => Icons.shield_rounded,
    'game' => Icons.sports_esports_rounded,
    'admin' => Icons.assignment_ind_rounded,
    'campaign' => Icons.campaign_rounded,
    'handshake' => Icons.handshake_rounded,
    'palette' => Icons.palette_rounded,
    'mic' => Icons.mic_rounded,
    'share' => Icons.share_rounded,
    _ => Icons.workspaces_rounded,
  };

  static IconData event(EventType t) => switch (t) {
    EventType.workshop => Icons.construction_rounded,
    EventType.hackathon => Icons.bolt_rounded,
    EventType.contest => Icons.emoji_events_rounded,
    EventType.talk => Icons.record_voice_over_rounded,
    EventType.bootcamp => Icons.school_rounded,
    EventType.meetup => Icons.groups_rounded,
    EventType.orientation => Icons.waving_hand_rounded,
  };

  static IconData notice(NoticeKind k) => switch (k) {
    NoticeKind.task => Icons.task_alt_rounded,
    NoticeKind.event => Icons.event_rounded,
    NoticeKind.finance => Icons.receipt_long_rounded,
    NoticeKind.announcement => Icons.campaign_rounded,
    NoticeKind.people => Icons.person_add_alt_1_rounded,
    NoticeKind.meeting => Icons.groups_2_rounded,
    NoticeKind.system => Icons.info_rounded,
  };

  static IconData expense(ExpenseCategory c) => switch (c) {
    ExpenseCategory.venue => Icons.location_city_rounded,
    ExpenseCategory.food => Icons.restaurant_rounded,
    ExpenseCategory.printing => Icons.print_rounded,
    ExpenseCategory.prizes => Icons.emoji_events_rounded,
    ExpenseCategory.swag => Icons.checkroom_rounded,
    ExpenseCategory.travel => Icons.directions_car_rounded,
    ExpenseCategory.software => Icons.dns_rounded,
    ExpenseCategory.logistics => Icons.inventory_2_rounded,
    ExpenseCategory.other => Icons.more_horiz_rounded,
  };

  static IconData income(IncomeSource s) => switch (s) {
    IncomeSource.sponsorship => Icons.handshake_rounded,
    IncomeSource.grant => Icons.account_balance_rounded,
    IncomeSource.membershipFee => Icons.badge_rounded,
    IncomeSource.ticketSales => Icons.confirmation_number_rounded,
    IncomeSource.other => Icons.savings_rounded,
  };

  static IconData vault(VaultCategory c) => switch (c) {
    VaultCategory.brand => Icons.auto_awesome_rounded,
    VaultCategory.templates => Icons.dashboard_customize_rounded,
    VaultCategory.eventAssets => Icons.photo_library_rounded,
    VaultCategory.docs => Icons.description_rounded,
    VaultCategory.learning => Icons.menu_book_rounded,
  };

  static IconData priority(TaskPriority p) => switch (p) {
    TaskPriority.high => Icons.keyboard_double_arrow_up_rounded,
    TaskPriority.medium => Icons.drag_handle_rounded,
    TaskPriority.low => Icons.keyboard_arrow_down_rounded,
  };
}
