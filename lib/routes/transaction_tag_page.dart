import "dart:io";

import "package:flow/constants.dart";
import "package:flow/data/flow_icon.dart";
import "package:flow/data/string_multi_filter.dart";
import "package:flow/data/transaction_filter.dart";
import "package:flow/entity/transaction/tag_type.dart";
import "package:flow/entity/transaction_tag.dart";
import "package:flow/entity/transaction_type/payload.dart";
import "package:flow/form_validators.dart";
import "package:flow/l10n/flow_localizations.dart";
import "package:flow/objectbox.dart";
import "package:flow/objectbox/objectbox.g.dart";
import "package:flow/services/transactions.dart";
import "package:flow/main.dart";
import "package:flow/services/user_preferences.dart";
import "package:flow/theme/color_themes/registry.dart";
import "package:flow/theme/flow_color_scheme.dart";
import "package:flow/theme/flow_theme_group.dart";
import "package:flow/theme/helpers.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/extensions/transaction_tag_type.dart";
import "package:flow/utils/optional.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/account/account_delete_styled_button.dart";
import "package:flow/widgets/general/directional_chevron.dart";
import "package:flow/widgets/general/flow_icon.dart";
import "package:flow/widgets/general/form_close_button.dart";
import "package:flow/widgets/general/frame.dart";
import "package:flow/widgets/general/info_text.dart";
import "package:flow/widgets/location_picker_sheet.dart";
import "package:flow/widgets/open_street_map.dart";
import "package:flow/widgets/sheets/select_color_scheme_sheet.dart";
import "package:flow/widgets/sheets/select_contact_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet/select_char_flow_icon_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet/select_icon_flow_icon_sheet.dart";
import "package:flow/widgets/sheets/select_flow_icon_sheet/select_image_flow_icon_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:flutter/scheduler.dart";
import "package:flutter_contacts/contact.dart";
import "package:flutter_map/flutter_map.dart";
import "package:geolocator/geolocator.dart";
import "package:go_router/go_router.dart";
import "package:latlong2/latlong.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:permission_handler/permission_handler.dart";

/// Fallback accent picker plate when tag has no theme yet.
const Color _kTagAccentPlateBgNeutral = Color(0xFFF3F4F6);
const Color _kTagAccentPlateFgNeutral = Color(0xFF6B7280);

class TransactionTagPage extends StatefulWidget {
  final int tagId;

  bool get isNewTag => tagId == 0;

  const TransactionTagPage({super.key, required this.tagId});
  const TransactionTagPage.create({super.key}) : tagId = 0;

  @override
  State<TransactionTagPage> createState() => _TransactionTagPageState();
}

class _TransactionTagPageState extends State<TransactionTagPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final TextEditingController _titleController;

  late TransactionTagType _type;

  TransactionTag? _currentlyEditing;

  TransactionTagPayload? _payload;

  bool _locationBusy = false;

  String? _colorSchemeName;

  FlowIconData? _iconData;

  String get iconCodeOrError =>
      _iconData?.toString() ?? FlowIconData.icon(_type.icon).toString();

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    if (widget.isNewTag) {
      _titleController = TextEditingController();
      _type = TransactionTagType.generic;
    } else {
      _currentlyEditing = ObjectBox().box<TransactionTag>().get(widget.tagId);
      _titleController = TextEditingController(text: _currentlyEditing?.title);
      _type = _currentlyEditing?.tagType ?? TransactionTagType.generic;
      _payload = _currentlyEditing?.parsedPayload;
      _colorSchemeName = _currentlyEditing?.colorSchemeName;
      _iconData = _currentlyEditing?.icon;

      if (_type == TransactionTagType.location && _payload?.location != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            _payload!.location!.latLng,
            _mapController.camera.zoom,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String _titleText(BuildContext context) {
    if (widget.isNewTag) {
      return "transaction.tags.new".t(context);
    }
    return _currentlyEditing?.title ?? "transaction.tags.new".t(context);
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16.0);
    final FlowColorScheme? activeScheme = getThemeStrict(_colorSchemeName);

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color screenBackground = isDark ? scheme.surface : Colors.white;
    final Color titleInk =
        isDark ? scheme.onSurface : kFlowHomeTransactionHeadingInk;
    // Note: other parts of this page compute their own card/divider tokens
    // using the same scheme in helper methods below.

    final LatLng center =
        (_type == TransactionTagType.location
            ? _payload?.location?.latLng
            : sukhbaatarSquareCenter) ??
        sukhbaatarSquareCenter;

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40.0,
        leading: FormCloseButton(canPop: () => !hasChanged()),
        title: Text(
          _titleText(context),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.0,
            color: titleInk,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () => save(),
            icon: const Icon(Symbols.check_rounded),
            tooltip: "general.save".t(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16.0),
                Center(
                  child: FlowIcon(
                    _iconData ?? CharacterFlowIcon("T"),
                    size: 80.0,
                    plated: true,
                    colorScheme: activeScheme,
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: contentPadding,
                  child: TextFormField(
                    controller: _titleController,
                    maxLength: TransactionTag.maxTitleLength,
                    validator: validateRequiredField,
                    decoration: InputDecoration(
                      label: Text(switch (_type) {
                        TransactionTagType.generic => "transaction.tags.name".t(
                          context,
                        ),
                        TransactionTagType.location =>
                          "transaction.tags.location.name".t(context),
                        TransactionTagType.contact =>
                          "transaction.tags.contact.name".t(context),
                      }),
                      focusColor: context.colorScheme.secondary,
                      counter: const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Padding(
                  padding: contentPadding,
                  child: _buildIconSourceSection(context, activeScheme),
                ),
                if (_type == TransactionTagType.location) ...[
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: contentPadding,
                    child: Frame(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: OpenStreetMap(
                                mapController: _mapController,
                                interactable: false,
                                onTap: (_) => selectLocation(center),
                                center: center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          InfoText(
                            child: Text(
                              "transaction.location.edit".t(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if ((Platform.isIOS || Platform.isAndroid) &&
                    _type == TransactionTagType.location)
                  ListTile(
                    enabled: !_locationBusy,
                    leading: const Icon(Symbols.my_location_rounded),
                    onTap: _useMyLocation,
                    title: Text(
                      "transaction.tags.location.useCurrent".t(context),
                    ),
                    trailing: const LeChevron(),
                  ),
                if ((Platform.isAndroid || Platform.isIOS) &&
                    _type == TransactionTagType.contact) ...[
                  ListTile(
                    leading: const Icon(Symbols.contact_page_rounded),
                    onTap: _selectContact,
                    title: Text(
                      "transaction.tags.contact.select".t(context),
                    ),
                    trailing: const LeChevron(),
                  ),
                  Padding(
                    padding: contentPadding,
                    child: Frame(
                      child: InfoText(
                        child: Text(
                          "preferences.transactions.tags.contactUsageDescription"
                              .t(context),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24.0),
                Padding(
                  padding: contentPadding,
                  child: _buildThemeColorSection(context, activeScheme),
                ),
                if (_currentlyEditing != null) ...[
                  const SizedBox(height: 36.0),
                  Padding(
                    padding: contentPadding,
                    child: AccountDeleteStyledButton(
                      onTap: _deleteTag,
                      label: Text("transaction.tags.delete".t(context)),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: context.textTheme.titleSmall?.copyWith(
          color: isDark ? scheme.onSurfaceVariant : kFlowPopularCurrenciesSectionHeading,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _editInsetCard(BuildContext context, Widget child) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? scheme.surfaceContainerHigh : Colors.white;
    final Color borderColor =
        isDark ? scheme.outlineVariant : const Color(0xFFE5E7EB);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: child,
      ),
    );
  }

  Widget _buildIconSourceSection(
    BuildContext context,
    FlowColorScheme? activeScheme,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dividerColor =
        isDark ? scheme.outlineVariant : const Color(0xFFF0F0EE);
    final Color basePlateBg = isDark ? scheme.surface : Colors.white;

    final Color symbolPlateBg = activeScheme != null
        ? Color.alphaBlend(
            activeScheme.primary.withValues(alpha: 0.14),
            basePlateBg,
          )
        : _kTagAccentPlateBgNeutral;
    final Color symbolPlateFg =
        activeScheme?.primary ?? _kTagAccentPlateFgNeutral;

    final Color altPlateBg = isDark
        ? scheme.surfaceContainerHighest
        : const Color(0xFFF5F4F2);
    final Color altPlateFg = isDark
        ? scheme.onSurfaceVariant
        : const Color(0xFF57534E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(context, "flowIcon.change".t(context)),
        const SizedBox(height: 8.0),
        _editInsetCard(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconSourceTile(
                context,
                icon: Symbols.interests_rounded,
                plateBg: symbolPlateBg,
                plateFg: symbolPlateFg,
                title: "flowIcon.type.icon".t(context),
                subtitle: "flowIcon.type.icon.search".t(context),
                onTap: _pickMaterialIcon,
                dividerColor: dividerColor,
                showDividerBelow: true,
              ),
              _buildIconSourceTile(
                context,
                icon: Symbols.glyphs_rounded,
                plateBg: altPlateBg,
                plateFg: altPlateFg,
                title: "flowIcon.type.character".t(context),
                subtitle: "flowIcon.type.character.description".t(context),
                onTap: _pickEmojiIcon,
                dividerColor: dividerColor,
                showDividerBelow: true,
              ),
              _buildIconSourceTile(
                context,
                icon: Symbols.image_rounded,
                plateBg: altPlateBg,
                plateFg: altPlateFg,
                title: "flowIcon.type.image".t(context),
                subtitle: "flowIcon.type.image.description".t(context),
                onTap: _pickImageIcon,
                dividerColor: dividerColor,
                showDividerBelow: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconSourceTile(
    BuildContext context, {
    required IconData icon,
    required Color plateBg,
    required Color plateFg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color dividerColor,
    required bool showDividerBelow,
  }) {
    final Widget row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: plateBg,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22.0, color: plateFg, fill: 0.0),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: kFlowAccountEditTitleColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: kFlowPopularCurrenciesSectionHeading,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right_rounded,
                size: 20.0,
                color: kFlowPopularCurrenciesSectionHeading.withValues(
                  alpha: 0.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!showDividerBelow) return row;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        Divider(
          height: 1.0,
          thickness: 1.0,
          indent: 72.0,
          color: dividerColor,
        ),
      ],
    );
  }

  Widget _buildThemeColorSection(
    BuildContext context,
    FlowColorScheme? activeScheme,
  ) {
    final Color plateBg = activeScheme != null
        ? Color.alphaBlend(
            activeScheme.primary.withValues(alpha: 0.14),
            Colors.white,
          )
        : _kTagAccentPlateBgNeutral;
    final Color plateFg = activeScheme?.primary ?? _kTagAccentPlateFgNeutral;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(context, "account.themeColor".t(context)),
        const SizedBox(height: 8.0),
        _editInsetCard(
          context,
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectColorScheme,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 14.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: plateBg,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Symbols.palette_rounded,
                        size: 22.0,
                        color: plateFg,
                        fill: 0.0,
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kFlowAccountEditTitleColor,
                          height: 1.25,
                        ),
                        child: _buildThemeColorValue(context, activeScheme),
                      ),
                    ),
                    Icon(
                      Symbols.chevron_right_rounded,
                      size: 20.0,
                      color: kFlowPopularCurrenciesSectionHeading.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeColorValue(
    BuildContext context,
    FlowColorScheme? scheme,
  ) {
    if (scheme == null) {
      return Text("select.color.none".t(context));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11.0,
          height: 11.0,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Flexible(
          child: Text(
            scheme.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _selectColorScheme() async {
    final FlowColorScheme theme = getTheme(
      UserPreferencesService().themeNameRaw,
      preferDark: Flow.of(context).useDarkTheme,
    );

    final FlowThemeGroup group = getGroupByTheme(theme.name);

    final Optional<FlowColorScheme>? result =
        await showModalBottomSheet<Optional<FlowColorScheme>>(
          context: context,
          isScrollControlled: true,
          builder: (context) => SelectColorSchemeSheet(
            group: group,
            initialScheme: _colorSchemeName,
          ),
        );

    if (result == null) return;

    setState(() {
      _colorSchemeName = result.value?.name;
    });
  }

  void _updateIcon(FlowIconData? data) {
    _iconData = data;
    if (mounted) setState(() {});
  }

  Future<void> _pickMaterialIcon() async {
    final FlowIconData? result = await showModalBottomSheet<FlowIconData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SelectIconFlowIconSheet(initialValue: _iconData),
    );

    if (result != null) {
      _updateIcon(result);
    }
  }

  Future<void> _pickEmojiIcon() async {
    const double pickerIconSize = 88.0;
    final FlowIconData? result = await showModalBottomSheet<FlowIconData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SelectCharFlowIconSheet(
        iconSize: pickerIconSize,
        initialValue: _iconData,
      ),
    );

    if (result != null) {
      _updateIcon(result);
    }
  }

  Future<void> _pickImageIcon() async {
    const double pickerIconSize = 88.0;
    final FlowIconData? result = await showModalBottomSheet<FlowIconData>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SelectImageFlowIconSheet(
        iconSize: pickerIconSize,
        initialValue: _iconData,
      ),
    );

    if (result != null) {
      _updateIcon(result);
    }
  }

  // Used by the hidden Generic / Location / Person chips above.
  // void _updateType(TransactionTagType newType) {
  //   if (newType == _type) return;
  //
  //   if (_iconData == null ||
  //       FlowIconData.icon(_type.icon).toString() == _iconData.toString()) {
  //     _iconData = FlowIconData.icon(newType.icon);
  //   }
  //   _type = newType;
  //
  //   setState(() {});
  // }

  void _updatePayloadLocation(LatLng point) {
    _payload = (_payload ?? const TransactionTagPayload()).copyWith(
      location: TransactionTagLocationPayload(point.latitude, point.longitude),
    );
    if (mounted) setState(() {});
  }

  void _useMyLocation() async {
    if (_locationBusy) return;

    setState(() {
      _locationBusy = true;
    });

    try {
      final PermissionStatus status = await Permission.locationWhenInUse
          .request();

      switch (status) {
        case PermissionStatus.limited:
        case PermissionStatus.granted:
          break;
        default:
          {
            if (mounted) {
              context.showErrorToast(
                error: "preferences.transactions.geo.auto.permissionDenied".t(
                  context,
                ),
              );
            }
            return;
          }
      }

      try {
        final position = await Geolocator.getCurrentPosition();
        final point = LatLng(position.latitude, position.longitude);
        _mapController.move(point, _mapController.camera.zoom);
        _updatePayloadLocation(point);
      } catch (e) {
        // Ignore
      }
    } finally {
      _locationBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _selectContact([bool requestPermission = true]) async {
    if (_type != TransactionTagType.contact) return;

    final PermissionStatus permissionStatus = await Permission.contacts
        .request();

    switch (permissionStatus) {
      case PermissionStatus.limited:
      case PermissionStatus.granted:
        break;
      default:
        {
          if (mounted) {
            context.showErrorToast(
              error:
                  "preferences.transactions.tags.enablePhoneContacts.permissionDenied"
                      .t(context),
            );
          }
          return;
        }
    }

    if (!mounted) return;

    final Optional<Contact>? selectedContact =
        await showModalBottomSheet<Optional<Contact>>(
          context: context,
          isScrollControlled: true,
          builder: (context) => const SelectContactSheet(),
        );

    final Contact? contact = selectedContact?.value;

    if (contact != null) {
      _payload = (_payload ?? const TransactionTagPayload()).copyWith(
        contact: TransactionContactTag(
          id: contact.id,
          name: contact.displayName,
        ),
      );
      _titleController.text = contact.displayName;
      if (_iconData == null ||
          FlowIconData.icon(_type.icon).toString() == _iconData.toString()) {
        final ImageFlowIcon? contactImage = await ImageFlowIcon.tryFromData(
          contact.photo,
        );

        if (contactImage != null) {
          _iconData = contactImage;
        }
      }
    }
  }

  void selectLocation(LatLng center) async {
    final Optional<LatLng>? result =
        await showModalBottomSheet<Optional<LatLng>>(
          context: context,
          builder: (context) => LocationPickerSheet(
            latitude: center.latitude,
            longitude: center.longitude,
          ),
          isScrollControlled: true,
        );

    if (result?.value case LatLng newLatLng) {
      _updatePayloadLocation(newLatLng);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _mapController.move(newLatLng, _mapController.camera.zoom);
      });
    }

    setState(() {});
  }

  bool hasChanged() {
    if (widget.isNewTag) {
      return _titleController.text.isNotEmpty ||
          _payload != null ||
          _colorSchemeName != null ||
          _type != TransactionTagType.generic;
    }

    return _titleController.text != (_currentlyEditing?.title ?? "") ||
        _type != (_currentlyEditing?.tagType ?? TransactionTagType.generic) ||
        _colorSchemeName != _currentlyEditing?.colorSchemeName ||
        _payload != _currentlyEditing?.parsedPayload;
  }

  void update(String formattedName) async {
    if (_currentlyEditing == null) return;

    _currentlyEditing!
      ..title = formattedName
      ..type = _type.value
      ..iconCode = iconCodeOrError
      ..colorSchemeName = _colorSchemeName
      ..payload = _payload?.serialize();

    ObjectBox().box<TransactionTag>().put(
      _currentlyEditing!,
      mode: PutMode.update,
    );

    context.pop();
  }

  void save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final String formattedName = _titleController.text.trim();

    if (!widget.isNewTag) {
      return update(formattedName);
    }

    final TransactionTag tag = TransactionTag(
      title: formattedName,
      type: _type.value,
      payload: _payload?.serialize(),
      colorSchemeName: _colorSchemeName,
      iconCode: iconCodeOrError,
    );

    final int insertedId = ObjectBox().box<TransactionTag>().put(
      tag,
      mode: PutMode.insert,
    );

    context.pop(ObjectBox().box<TransactionTag>().get(insertedId));
  }

  Future<void> _deleteTag() async {
    if (_currentlyEditing == null) return;

    final TransactionFilter filter = TransactionFilter(
      tags: StringMultiFilter.whitelist([_currentlyEditing!.uuid]),
    );

    final int txnCount = TransactionsService().countMany(filter);

    final bool? confirmation = await context.showConfirmationSheet(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(context, _currentlyEditing!.title),
      child: Text("transaction.tags.delete.description".t(context, txnCount)),
    );

    if (confirmation == true) {
      ObjectBox().box<TransactionTag>().remove(_currentlyEditing!.id);

      if (mounted) {
        context.pop();
        GoRouter.of(context).popUntil((route) {
          return route.path != "/transactionTags/:id";
        });
      }
    }
  }
}
