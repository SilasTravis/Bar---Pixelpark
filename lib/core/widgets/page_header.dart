import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

import '../theme/app_text_styles.dart';
import '../theme/nocturne_colors.dart';
import '../../generated/l10n.dart';

/// Header of a pushed page (history, close shift, settings): back + title +
/// optional trailing actions.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: NocturneColors.bg,
        border: Border(bottom: BorderSide(color: NocturneColors.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: AppLocalization.of(context).back,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h4,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
