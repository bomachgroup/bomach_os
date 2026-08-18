import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';

/// Centralized icon choices for Bomach OS modules.
///
/// Prefer these named constants over raw `Iconsax.*` references for
/// module-level icons — renames land in a single file. Ad-hoc icons inside
/// one page can continue to reference `Iconsax.*` directly.
class AppIcons {
  AppIcons._();

  // ─── Modules / sidebar ──────────────────────────────────────────────────
  static const IconData dashboard = Iconsax.element_4;
  static const IconData company = Iconsax.building;
  static const IconData hr = Iconsax.people;
  static const IconData operations = Iconsax.briefcase;
  static const IconData services = Iconsax.box;
  static const IconData marketingCrm = Iconsax.chart_2;
  static const IconData marketing = Iconsax.lamp_charge;
  static const IconData crm = Iconsax.profile_2user;
  static const IconData finance = Iconsax.wallet_3;
  static const IconData events = Iconsax.calendar_1;
  static const IconData analytics = Iconsax.chart_square;
  static const IconData legal = Iconsax.shield_tick;
  static const IconData clientsPortal = Iconsax.folder_open;
  static const IconData security = Iconsax.security_safe;
  static const IconData workspace = Iconsax.layer;
  static const IconData settings = Iconsax.setting_2;
  static const IconData profile = Iconsax.user;
  static const IconData logout = Iconsax.logout;

  // ─── Common actions ─────────────────────────────────────────────────────
  static const IconData add = Iconsax.add_circle;
  static const IconData edit = Iconsax.edit;
  static const IconData delete = Iconsax.trash;
  static const IconData search = Iconsax.search_normal_1;
  static const IconData filter = Iconsax.filter;
  static const IconData sort = Iconsax.sort;
  static const IconData refresh = Iconsax.refresh;
  static const IconData close = Iconsax.close_circle;
  static const IconData check = Iconsax.tick_circle;
  static const IconData more = Iconsax.more;
  static const IconData download = Iconsax.document_download;
  static const IconData upload = Iconsax.document_upload;
  static const IconData export = Iconsax.export_1;

  // ─── Entities / content types ───────────────────────────────────────────
  static const IconData document = Iconsax.document_text;
  static const IconData folder = Iconsax.folder_2;
  static const IconData image = Iconsax.image;
  static const IconData attachment = Iconsax.attach_circle;
  static const IconData note = Iconsax.note_2;
  static const IconData task = Iconsax.task_square;
  static const IconData project = Iconsax.briefcase;
  static const IconData contract = Iconsax.document_text;
  static const IconData compliance = Iconsax.verify;
  static const IconData audit = Iconsax.clipboard_text;
  static const IconData case_ = Iconsax.judge; // legal case
  static const IconData employee = Iconsax.user_square;
  static const IconData client = Iconsax.user_octagon;
  static const IconData lead = Iconsax.flash_1;
  static const IconData invoice = Iconsax.receipt_2_1;
  static const IconData payment = Iconsax.money_send;

  // ─── Status / feedback ──────────────────────────────────────────────────
  static const IconData success = Iconsax.tick_circle;
  static const IconData warning = Iconsax.warning_2;
  static const IconData danger = Iconsax.danger;
  static const IconData info = Iconsax.info_circle;

  // ─── Navigation ─────────────────────────────────────────────────────────
  static const IconData arrowLeft = Iconsax.arrow_left_2;
  static const IconData arrowRight = Iconsax.arrow_right_3;
  static const IconData arrowUp = Iconsax.arrow_up_3;
  static const IconData arrowDown = Iconsax.arrow_down_1;
  static const IconData chevronDown = Iconsax.arrow_down_1;
  static const IconData chevronRight = Iconsax.arrow_right_3;
  static const IconData menu = Iconsax.menu_1;
  static const IconData notification = Iconsax.notification;
  static const IconData message = Iconsax.message;

  // ─── Empty state defaults ───────────────────────────────────────────────
  static const IconData emptyBox = Iconsax.box;
  static const IconData emptySearch = Iconsax.search_zoom_out;
  static const IconData emptyInbox = Iconsax.message_square;

  // ─── Auth / form field ornaments ────────────────────────────────────────
  static const IconData user = Iconsax.user;
  static const IconData email = Iconsax.sms;
  static const IconData lock = Iconsax.lock;
  static const IconData eye = Iconsax.eye;
  static const IconData eyeSlash = Iconsax.eye_slash;
  static const IconData key = Iconsax.key;
}
